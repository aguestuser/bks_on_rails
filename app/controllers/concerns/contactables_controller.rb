 module ContactablesController
  extend ActiveSupport::Concern

  included do  

    private

    # def build_contact
    #   @it.build_contact
    # end

    # def refresh_account
    #   @account = @it.contact
    # end

    def contact_params
      { 
        contact_attributes: [
          :id, :contact_id, :name, :title, :email, :phone
        ]
      }
    end
  end

  # module ClassMethods
  # end
end