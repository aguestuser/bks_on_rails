 module LocatablesController
  include ControllerHelpers
  extend ActiveSupport::Concern

  included do 

    before_action :get_location, only: [:show, :edit, :update, :destroy]

    def get_location
      @location = get_klass.find(params[:id]).location
    end

    def location_params
      {
        location_attributes: [ [ :locatable_id, :locatable_type, :id, :address, :borough, :neighborhood ] ]
      }
    end


  end

  module ClassMethods
  end
end