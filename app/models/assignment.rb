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

  # before_validate :set_assigned_by_id, on: :create
  # before_validate :set_last_modified_by_id

  classy_enum_attr :status, allow_nil: true, enum: 'AssignmentStatus'

  validates :status, presence: true

  # validates :status, :assigned_by, :last_modified_by
  #   presence: true

  # def assigned_by
  #   Account.find(self.assigned_by_id)
  # end

  # def last_modified_by
  #   Account.find(self.last_modified_by_id)
  # end

  # private

  #   def set_assigned_by_id
  #     self.assigned_by_id = current_account.id
  #   end

  #   def set_last_modified_by_id
  #     self.last_modified_by = current_account.contact.name
  #   end

end
