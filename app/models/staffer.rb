class Staffer < ActiveRecord::Base
  #associations
  has_one :contact_info, as: :contactable

  #methods
  def email
    self.contact_info.email
  end
end
