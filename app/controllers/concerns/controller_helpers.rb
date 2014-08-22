 module ControllerHelpers
  extend ActiveSupport::Concern

  included do 
    private
      def get_klass
        params[:controller].singularize.capitalize.constantize      
      end
  end
  
  module ClassMethods
  end
  
end  