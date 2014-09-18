# == Schema Information
#
# Table name: conflicts
#
#  id         :integer          not null, primary key
#  period     :string(255)
#  rider_id   :integer
#  created_at :datetime
#  updated_at :datetime
#  start      :datetime
#  end        :datetime
#

class Conflict < ActiveRecord::Base
  include Timeboxable

  belongs_to :rider

  validates :rider_id, presence: true

  def Conflict.send_emails rider_conflicts
    #input: RiderConflicts
    #output: Str (empty if no emails sent, email alert if emails sent)
    alert = ""
    
    count = 0
    RiderConflicts.arr.each do |hash| 
      RiderMailer.conflict_request(hash[:riders], hash[:conflicts]).deliver
      count += 1
    end
    
    alert = "#{count} conflict requests successfully sent" if count > 0
    alert
  end

end
