module Sortable
  extend ActiveSupport::Concern

  included do

    helper_method :sort_column, :sort_direction

    private 
    
      def sort_column
        params[:sort] || "start" # default sort by date
      end

      def sort_direction
        params[:direction] || "asc"
      end
  end

end