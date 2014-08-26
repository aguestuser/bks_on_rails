class RiderMailer < ActionMailer::Base
  default from: "brooklynshift@gmail.com"

  def delegation_email rider, shift
    @rider = rider
    @shifts = [ shift ]
    @staffer = staffer
    @confirmation_time = confirmation_time
    mail(to: rider.email, subject: "[EXTRA SHIFT] #{shift.table_time} @ #{shift.restaurant.name}")
  end

  private

  def staffer
    Staffer.tess
    # if current_user
    #   if current_user.account_type == 'Staffer' 
    #     current_user
    #   end
    # else
    #   Staffer.tess
    # end
  end

  def confirmation_time
    "tomorrow at 2pm"
  end

end
