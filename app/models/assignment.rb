# == Schema Information
#
# Table name: assignments
#
#  id                      :integer          not null, primary key
#  shift_id                :integer
#  rider_id                :integer
#  status                  :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  override_conflict       :boolean
#  override_double_booking :boolean
#

class Assignment < ActiveRecord::Base
  include BatchUpdatable, Importable
  belongs_to :shift #, inverse_of: :assignment
  belongs_to :rider

  classy_enum_attr :status, allow_nil: true, enum: 'AssignmentStatus'

  before_validation :set_status, if: :status_nil?
  before_save :auto_unassign

  validates :status, presence: true
  validate :no_emergency_shift_delegation

  #instance methods

  def no_emergency_shift_delegation
    if self.shift
      if self.shift.urgency == :emergency
        errors.add(:base, 'Emergency shifts cannot be delegated') unless self.status != :delegated
      end
    end
  end

  def conflicts
    #input: self (implicit)
    #output: Arr of Conflicts
    if self.rider.nil?
      []
    else
      rider_conflicts = get_rider_conflicts 
      rider_conflicts.select { |conflict| self.shift.conflicts_with? conflict }
    end
  end

  def double_bookings 
    rider_shifts = get_rider_shifts
    if self.rider.nil?
      []
    else 
      rider_shifts.select { |shift| self.shift.double_books_with? shift }
    end
  end

  def resolve_obstacle
    self.conflicts.each(&:destroy) if self.conflicts.any?
    self
  end

  def save_success_message
    self.rider.nil? ? "Assignment updated (currently unassigned)." : "Assignment updated (Rider: #{self.rider.contact.name}, Status: #{self.status.text})"
  end

  def try_send_email old_assignment, sender_account
    if self.status == :delegated && ( old_assignment.status != :delegated || old_assignment.rider != self.rider )
      send_email_from sender_account
      true
    else 
      false
    end 
  end

  #Class Methods

  def Assignment.send_emails rider_shifts, sender_account
    #input: RiderShifts, Account
    #does: sends shift assignment email to each rider
    #output: Int (count of emails sent)
  
    count = 0
    
    rider_shifts.values.each do |rider_hash| # (4)
      RiderShifts::URGENCIES.each do |urgency|
        RiderShifts::EMAIL_TYPES.each do |email_type|
          
          if rider_hash[urgency][email_type][:shifts].any?
            here = rider_hash[urgency][email_type]
            RiderMailer.delegation_email(
              sender_account,
              rider_hash[:rider],
              urgency,
              email_type,
              here[:shifts],
              here[:restaurants]
            ).deliver
            count += 1
          end
        
        end
      end
      count
    end
  end # Assignment.send_emails

  def Assignment.emailable new_assignments, old_assignments
    #input: Arr of Assignments, Arr of Assignments
    #does: builds array of assignments that were newly delegated or confirmed when being updated from second argument to first
    #output: Arr of Assignments
    new_assignments.select.with_index do |a, i| 
      if a.status == :delegated || a.status == :confirmed
        old_assignments[i].status != a.status || old_assignments[i].rider != a.rider
      else
        false
      end 
    end
  end
  

  private

    #instance method helpers

    def status_nil?
      self.status.nil?
    end

    def set_status
      self.status = :unassigned
    end

    def get_rider_conflicts
      self.rider.conflicts_on self.shift.start
    end

    def get_rider_shifts
      if self.rider
        self.rider.shifts_on(self.shift.start).reject{ |s| s.id == self.shift.id }
      else
        []
      end
    end

    def send_email_from sender_account
      RiderMailer.delegation_email(self.rider, [ self.shift ], [ self.shift.restaurant ], sender_account).deliver
    end

    def auto_unassign
      self.rider_id = nil if self.status == :unassigned
      self.status = :unassigned if self.rider_id == nil
    end

end
