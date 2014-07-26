# == Schema Information
#
# Table name: assignments
#
#  id         :integer          not null, primary key
#  shift_id   :integer
#  rider_id   :integer
#  status     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Assignment < ActiveRecord::Base
  belongs_to :shift
  belongs_to :rider

  before_validation :set_status, if: :status_nil?
  # before_validation :set_assigned_by_id, on: :create
  # before_validation :set_last_modified_by_id

  classy_enum_attr :status, allow_nil: true, enum: 'AssignmentStatus'

  validates :shift_id, :rider_id, :status, presence: true

  # validates :status, :assigned_by, :last_modified_by
  #   presence: true

  # def assigned_by
  #   Account.find(self.assigned_by_id)
  # end

  # def last_modified_by
  #   Account.find(self.last_modified_by_id)
  # end

  def conflicts_with?(conflicts)
    conflicts.each do |conflict|
      return true if ( conflict.end >= self.shift.end && conflict.start < self.shift.end ) || ( conflict.start <= self.shift.start && conflict.end > self.shift.start ) 
      # ie: if the conflict overlaps with the assignment
    end
    false
  end

  def double_books_with?(assignments)
    assignments.each do |assignment|
      return true if ( assignment.shift.end >= self.shift.end && assignment.shift.start <  self.shift.end ) || ( assignment.shift.start <= self.shift.start && assignment.shift.end > self.shift.start )
      # ie: if the assignment starts before shift end or ends after shift start
    end
    false
  end

  private

    def status_nil?
      self.status.nil?
    end

    def set_status
      self.status = :proposed
    end

  #   def set_assigned_by_id
  #     self.assigned_by_id = current_account.id
  #   end

  #   def set_last_modified_by_id
  #     self.last_modified_by = current_account.contact.name
  #   end

end
