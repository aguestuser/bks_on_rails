class Staffer < ActiveRecord::Base
  #associations
  has_one :contact_info, as: :contactable
end
