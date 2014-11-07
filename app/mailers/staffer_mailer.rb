class StafferMailer < ActionMailer::Base
  default from: "'BK SHIFT' <brooklynshift@gmail.com>"
  default to: [ "'BK SHIFT' <brooklynshift@gmail.com>", "'Tess Cohen' <tess@bkshift.com>", " 'Justin Lewis' <justin@bkshift.com>" ]
  helper_method :protect_against_forgery?

  def conflict_notification rider, conflicts, week_start, notes=nil
    @rider = rider
    @conflicts = conflicts
    @week_start = week_start
    @notes = notes
 
    subject = "[CONFLICT SUBMMISSION] #{@rider.name}"

    mail( subject: subject )
  end

  def new_rider_notification rider
    @rider = rider

    mail subject: "[NEW RIDER] #{@rider.name}"
  end

  def protect_against_forgery?
    false
  end
end