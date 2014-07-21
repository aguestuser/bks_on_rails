class ContactsController < ApplicationController

  before_action :load_contact, only: [ :edit, :update ]

  def create
  end

  def show
  end

  def edit
  end

  def update
    @contact.update(contact_params)
    if @contact.save
      flash[:success] = 'Profile updated'
      redirect_to @contact.contactable
    else
      render 'edit'
    end
  end

  private

    def load_contact
      @contact = Contact.find(params[:id])
      @it = @contact
    end

    def contact_params
      params.require(:contact).permit(:contactable_id, :name, :title, :email, :phone)
    end

end
