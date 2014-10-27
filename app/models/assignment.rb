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

  def Assignment.send_emails new_assignments, old_assignments, sender_account
    #input: assignments <Arr of Assignments>, old_assignments <Arr of Assignments>, Account
    #does: 
      # (1) constructs array of newly delegated shifts
      # (2) parses list of shifts into sublists for each rider
      # (3) parses list of shifts for restaurants
      # (4) [ SIDE EFFECT ] sends batch shift delegation email to each rider using params built through (1), (2), and (3)
    #output: Int (count of emails sent)
    # delegations = Assignment.delegations_from new_assignments, old_assignments # (1)
    # rider_shifts = RiderShifts.new(delegations).hash #(2), (3)
    
    emailable_shifts = Assignment.emailable new_assignments, old_assignments
    rider_shifts = RiderShifts.new(emailable_shifts).hash #(2), (3)
    
    count = 0
    rider_shifts.values.each do |rider_hash| # (4)
      [:emergency, :extra, :weekly].each do |urgency|
        if rider_hash[urgency][:shifts].any?
          Assignment.send_email rider_hash, urgency, sender_account
          count += 1
        end
      end
    end
    count
  end

  def Assignment.send_email rider_hash, urgency, sender_account
    RiderMailer.delegation_email( 
      rider_hash[:rider], 
      rider_hash[urgency][:shifts], 
      rider_hash[urgency][:restaurants],
      sender_account,
      urgency
    ).deliver
  end

  def Assignment.delegations_from new_assignments, old_assignments
    #input: Arr of Assignments, Arr of Assignments
    #does: builds array of assignments that were newly delegated when being updated from second argument to first
    #output: Arr of Assignments
    new_assignments.select.with_index do |a, i|  
      a.status == :delegated && ( old_assignments[i].status != :delegated || old_assignments[i].rider != a.rider )
    end
  end

  def Assignment.emailable new_assignments, old_assignments
    #input: Arr of Assignments, Arr of Assignments
    #does: builds array of assignments that were newly delegated when being updated from second argument to first
    #output: Arr of Assignments
    # raise ( "NEW ASSIGNMENTS: " + new_assignments.inspect + "OLD ASSIGNMENTS: " + old_assignments.inspect )
    new_assignments.select.with_index do |a, i| 
      if a.status == :delegated
        old_assignments[i].status != :delegated || old_assignments[i].rider != a.rider
      elsif a.status == :confirmed
        # raise ( old_assignments[i].rider != a.rider ).inspect
        val = ( a.shift.urgency == :emergency && ( old_assignments[i].status != :confirmed || old_assignments[i].rider != a.rider ) )
        # raise val.inspect
      else
        false
      end 
      # a.status == :delegated && ( old_assignments[i].status != :delegated || old_assignments[i].rider != a.rider ) ||
      # a.status == :confirmed && ( old_assignments[i].status != :confirmed || old_assignments[i].rider != a.rider )
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
