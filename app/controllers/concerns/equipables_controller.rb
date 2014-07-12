 module EquipablesController
  include ControllerHelpers
  extend ActiveSupport::Concern

  included do 

    before_action :get_equipment, only: [ :show, :edit, :update, :destroy ]

    def get_equipment
      @equipment = get_klass.find(params[:id]).equipment_set
    end

    def equipment_params
      {
        equipment_set_attributes: [ :equipable_id, :equipable_type, :id, :bike, :lock, :helmet, :rack, :bag, 
                                    :heated_bag, :cell_phone, :smart_phone, :car ]
      }
    end


  end

  module ClassMethods
  end
end