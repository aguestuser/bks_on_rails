module Paths
  extend ActiveSupport::Concern

  included do

    helper_method :index_path, :show_path, :edit_path, :new_path
    before_action :load_controller
    before_action :load_resource_str
    before_action :load_resource_key
    before_action :set_teaser

    public

      def index_path(record_type=nil)
        if record_type
          @base_path + "/#{record_type}"
        else
          @base_path
        end
      end 

      def show_path(record, record_type=nil)
        @base_path + rt_str(record, record_type) + "#{record.id}" + base_path_params
      end

      def edit_path(record, record_type=nil)
        @base_path + rt_str(record, record_type) + "#{record.id}/edit" + base_path_params
      end

      def new_path
        @base_path + "new" + base_path_params
      end

    private

      def load_controller
        @controller = params[:controller]
      end

      def load_resource_str
        @resource_str = @controller
      end

      def load_resource_key
        @resource_key = @controller.singularize.to_sym
      end

      def set_teaser
        @teaser = true if @controller == 'riders' || @controller == 'restaurants'
      end
      
      def load_base_path
        if params[:base_path]
          @base_path = params[:base_path]
        elsif params[@resource_key]
          @base_path = params[@resource_key][:base_path] if params[@resource_key][:base_path]
        else
          @base_path = default_base_path
        end
        # raise @base_path.inspect
      end

      def default_base_path
        # raise caller.inspect
        if @caller 
          if caller_is_controller?
            "/#{@caller}s/#{caller.id}/"
          elsif @controller == 'assignments'
            "/#{@caller}s/#{caller.id}/shifts/"
          else
           "/#{@caller}s/#{caller.id}/#{@resource_str}/"
          end
        else
          if @controller == 'grid'
            "/grid/#{params[:action]}"
          elsif @controller == 'assignments'
            "/shifts/"
          else
            "/#{@resource_str}/"
          end
        end
      end

      def caller_is_controller?
        @controller.singularize == @caller.to_s
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

      def rt_str record, record_type
        case record_type
        when :assignments
          "#{record.shift.id}/assignments/"
        when nil
          ""
        else 
          "#{record_type}/"
        end
      end

      def base_path_params
        "?base_path=" + URI.escape(@base_path)
      end

  end
end