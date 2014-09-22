class StafferMailer < ActionMailer::Base
  default from: "brooklynshift@gmail.com"
  helper_method :protect_against_forgery?

  def conflict_notification rider, conflicts, week_start, notes=nil
    @rider = rider
    @conflicts = conflicts
    @week_start = week_start
    @notes = notes

    recipients = [ "brooklynshift@gmail.com", "austin@bkshift.com" ] # [ "brooklynshift@gmail.com", "tess@bkshift.com", "justin@bkshift.com" ] 
    subject = "[CONFLICT SUBMMISSION] #{@rider.name}"

    mail( to: recipients, subject: subject )
  end

  def protect_against_forgery?
      false
    end
end