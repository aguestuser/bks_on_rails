module Paths
  extend ActiveSupport::Concern

  included do

    helper_method :index_path, :show_path, :edit_path, :new_path
    before_action :load_root_key
    before_action :set_teaser

    public

      def index_path(record_type=nil)
        if record_type
          @root_path + "/#{record_type}"
        else
          @root_path
        end
      end 

      def show_path(record, record_type=nil)
        @root_path + rt_str(record_type, record) + "#{record.id}" + root_path_params
      end

      def edit_path(record, record_type=nil)
        @root_path + rt_str(record_type, record) + "#{record.id}/edit" + root_path_params
      end

      def new_path
        @root_path + "new" + root_path_params
      end

    private

      def load_root_key
        @root_key = params[:controller].to_s.singularize.to_sym
      end

      def set_teaser
        @teaser = true if @root_key == :rider || @root_key == :resstaurant
      end
      
      def load_root_path
        #input(implicit): @root_key (Sym), @root_path(Str)
        default = default_root_path
        if params[@root_key]
          @root_path = params[@root_key][:root_path] || default
        else
          @root_path = params[:root_path] || default
        end
      end

      def default_root_path
        # raise caller.inspect
        if @caller 
          if @root_key == :rider || @root_key == :restaurant
            "/#{@caller}s/#{caller.id}"
          else
           "/#{@caller}s/#{caller.id}/#{@root_key}s/"
          end
        else
          "/#{@root_key}s/"
        end
      end

      def caller
        case @caller
        when :restaurant
          @restaurant
        when :rider
          @rider
        when nil
          nil
        end  
      end

      def rt_str record_type, record
        if record_type
          if record_type == :assignments
            "#{record.shift.id}/assignments/"
          else
            "#{record_type}/"
          end
        else
          ""
        end
      end

      def root_path_params
        "?root_path=" + URI.escape(@root_path)
      end

  end
end