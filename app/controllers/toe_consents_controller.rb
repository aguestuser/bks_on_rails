class ToeConsentsController < ApplicationController

  def new
    @rider = Rider.find(params[:rider_id])
  end

  def create
    rider = Rider.find(params[:rider_id])
    if rider.has_toe_consent?
      flash[:error] = "You have already completed a Terms of Employment Form"
      redirect_to "/riders/#{rider.id}/toe_consent/complete"
    else
      ip = request.remote_ip
      ToeConsent.create!(rider: rider, ip: ip)
      flash[:success] = "Thank you for completing the Terms of Employment Form"
      redirect_to "/riders/#{rider.id}/toe_consent/complete"
    end
  end

  def complete
    @rider = Rider.find(params[:rider_id])
  end
end
