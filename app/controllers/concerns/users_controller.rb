module UsersController
  extend ActiveSupport::Concern

  included do
    case self.class.name
    when 'StaffersController'
      @user = @staffer
      User = Staffer
    when 'Manager' 
      @user = @manager
      User = Staffer
    when 'Rider' 
      @user = @rider
      User = Rider
    else
      raise Exception, "You tried to pass a non-User class to the UsersController module: #{self.class.name}"
    end
    
    before_action :get_staffer, only: [:show, :edit, :update, :destroy]

    def new
      @user = User.new
      @user.build_contact_info
    end

    def create
      @user = User.new(staffer_params)
      if @user.save
        flash[:success] = "Profile created for #{@user.name}."
        redirect_to @user
      else
        render 'new'
      end
    end

    def index
      @users = User.all
    end

    def show
      @contact = @user.contact_info
    end

    def edit
    end

    def update
      @user.update(staffer_params)
      if @user.save
        flash[:success] = "#{@user.name}'s profile has been updated"
        redirect_to @user
      else
        render 'edit'
      end    
    end

    def destroy
      @user.destroy
      flash[:success] = "All information associated with #{@user} has been deleted"
      redirect_to staffers_url
    end

    private

      def get_staffer
        @user = User.find(params[:id])
      end

      def staffer_params
        params.require(:staffer).permit(contact_info_attributes: [:name, :title, :phone, :email])
      end
  end

  module ClassMethods
  end
end