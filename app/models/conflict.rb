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

  def list_time
    "#{self.start.strftime("%A")} self.period.text.upcase"
  end

  def Conflict.send_emails rider_conflicts, account
    #input: RiderConflicts
    #output: Str (empty if no emails sent, email alert if emails sent)
    alert = ""
    
    count = 0
    rider_conflicts.arr.each do |hash| 
      RiderMailer.conflicts_request(hash[:rider], hash[:conflicts], account).deliver
      count += 1
    end
    
    alert = "#{count} conflict requests successfully sent" if count > 0
    alert
  end

end
