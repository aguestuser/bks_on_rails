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
  include BatchUpdatable
  belongs_to :shift #, inverse_of: :assignment
  belongs_to :rider

  classy_enum_attr :status, allow_nil: true, enum: 'AssignmentStatus'

  before_validation :set_status, if: :status_nil?
  # before_validation :set_assigned_by_id, on: :create
  # before_validation :set_last_modified_by_id

  validates :status, presence: true

  # validates :status, :assigned_by, :last_modified_by
  #   presence: true

  # def assigned_by
  #   Account.find(self.assigned_by_id)
  # end

  # def last_modified_by
  #   Account.find(self.last_modified_by_id)
  # end



  #public instance methods

  def Assignment.batch_save_obstacles assignments
    #input: Arr of Assignments
    #output: Arr of Symbols (permitted values: [ :none, :double_booking, :conflict ])
    assignments.map { |a| a.save_obstacles }
  end

  def save_obstacles
    #input: Assignment (self: implicit)
    #output: Sym (permitted values: [ :none, :double_booking, :conflict ])
    conflicts = get_conflicts
    
    if no_conflicts? conflicts
      handle_no_conflicts conflicts
      other_shifts = get_other_shifts

      if no_double_bookings? other_shifts
        handle_no_double_bookings
        :none
      else
        :double_booking
      end
    else
      :conflict
    end
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

  def send_email_from sender_account
    RiderMailer.delegation_email(self.rider, [ self.shift ], [ self.shift.restaurant ], sender_account).deliver
  end

  #public Class Methods

  def Assignment.send_emails assignments, old_assignments, sender_account
    #input: assignments <Arr of Assignments>, old_assignments <Arr of Assignments>, Account
    #does: 
      # (1) constructs array of newly delegated shifts
      # (2) parses list of shifts into sublists for each rider
      # (3) parses list of shifts for restaurants
      # (4) [ SIDE EFFECT ] sends batch shift delegation email to each rider using params built through (1), (2), and (3)
    #output: Int (count of emails sent)
    delegations = delegations_from assignments, old_assignments # (1)
    rider_shifts = RiderShifts.new(delegations).array #(2), (3)
    rider_shifts.each do |rs| # (4)
      RiderMailer.delegation_email( rs[:rider], rs[:shifts], rs[:restaurants], current_account ).deliver
    end
    rider_shifts.count
  end
  

  private

    #instance methods

    def delegations_from assignments, old_assignments
      #input: Arr of Assignments, Arr of Assignments
      #does: builds array of assignments that were newly delegated when being updated from second argument to first
      #output: Arr of Assignments
      delegations = []
      assignments.each_with_index do |a, i| 
        delegations.push(a) if a.status == :delegated && ( old_assignments[i].status != :delegated || @old_assignments[i].rider != a.rider )
      end
      delegations
    end

    def handle_save_success type
      #input: Sym (permitted values: [ :single, :batch ])
      case type
      when :single
        handle_single_save_success
      when :batch
        handle_batch_save_success
      end
    end

    def handle_single_save_success assignment
      email_sent = send_email assignment
      email_alert = email_sent ? " -- Email sent to rider" : ""
      flash[:success] = 
    end



    def status_nil?
      self.status.nil?
    end

    def set_status
      self.status = :unassigned
    end

    def get_conflicts
      #input: self (implicit)
      #output: Arr of Conflicts
      self.rider.conflicts_on assignment.shift.start
    end

    def no_conflicts? conflicts
      #input: Arr of Conflicts, Self (implicit)
      #output: Bool
      if self.rider.nil? || self.override_conflict
        true
      else
        !self.shift.conflicts_with? conflicts
      end
    end

    def handle_no_conflicts conflicts
      conflicts.each(&:destroy) # so these just-overrridedn conflicts won't throw errors in future
      self.override_conflict = false # so other not-yet created conflicts will throw errors
    end


    def get_other_shifts
      self.rider.shifts_on(self.shift.start).reject{ |s| s.id == self.shift.id }
    end

    def no_double_bookings? other_shifts
      if self.rider.nil? || self.override_double_booking
        true
      else
        !self.shift.double_books_with? other_shifts
      end
    end

    def handle_no_double_bookings
      self.override_double_booking = false
    end

  #   def set_assigned_by_id
  #     self.assigned_by_id = current_account.id
  #   end

  #   def set_last_modified_by_id
  #     self.last_modified_by = current_account.contact.name
  #   end

  #class methods

  #Assignment.batch_update (included from BatchUpdatable)

end
