class StaffersController < ApplicationController
  
  def new
    @staffer = Staffer.new
    @staffer.build_contact_info
  end

  def create
    # @staffer = Staffer.create!(staffer_params)
    # @contact_info = @staffer.contact_info.new(contact_info_params)
    # if @contact_info.save
    #   flash[:success] = "New staffer created!"
    #   redirect_to @staffer
    # else
    #   render 'new'
    # end

    # @contact_info = ContactInfo.new(params[:contact_info])
    
    # if @contact_info.save
    #   @staffer = Staffer.create!({contact_info: @contact_info.id})
    #   flash[:success] = "New staffer created!"
    #   redirect_to @staffer
    # else
    #   render 'new'
    # end

    # @staffer = Staffer.new
    # @contact_info = @staffer.build_contact_info(params[:staffer][:contact_info])
    # if @contact_info.save
    #   @staffer.save
    #   flash[:success] = "New staffer created!"
    #   redirect_to @staffer
    # else
    #   render 'new'
    # end

    @staffer = Staffer.new(staffer_params)
    if @staffer.save
      flash[:success] = 'Micropost created!'
      redirect_to @staffer
    else
      render 'new'
    end

  end

  def index
    
  end

  def show
    @staffer = Staffer.find(params[:id])
    @contact = @staffer.contact_info
  end

  def edit
    
  end

  def update
    
  end

  def destory
    
  end

  private

    def staffer_params
      params.require(:staffer).permit(contact_info_attributes: [:name, :title, :phone, :email])
    end

    # def staffer_params
    #   params.require(:staffer, { :contact_info_id => @contact_info.id })
    # end

    # def contact_info_params
    #   # params[:contact_info].require(:name, :phone, :email, :title).permit(:street_address, :borough, :neighborhood)
    #   params.require(:staffer, contact_info: [:name, :phone, :email, :title]).permit(contact_info: [:street_address, :borough, :neighborhood])
    # end
end