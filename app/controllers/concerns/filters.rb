 module Filters
  extend ActiveSupport::Concern

  included do #InstanceMethods

    def load_filters lf_params
      #input: Hash of params with following form:
        # { subject: Symbol corresponding to Timeboxable class name }
          # permitted values: :shifts, :conflicts, :assignments
        # { view: Symbol corresponding to view rendering filtered records }
          # permitted values: :shift_table, :shift_grid, :conflict_table, :availability_grid
        # { by: [ Arr of Symbols corresponding to filter keys ]}
          # permitted values: :time, :restaurants, :riders, :status
      #does: builds hash of filter params based on object type and filter keys passed as args
      #output: Hash of filter params

      if params[:filter]
        fp = params[:filter]
        context = :request
      else
        context = :load
      end



      lf_params[:by].each do |by|
        @filter ||= {}
        @filter.merge!(load_filter by, context, fp, lf_params[:view]) ## <-- breaks up filter retrieval to component parts
      end
    end

    def filters
      # input: @filter instance variable (implicit)
      # does: builds Array of SQL filtering query arguments
        # to be splatted into list of arguments for
        # .where method in <caller>.load_<caller_records>  
      # output: Array of form:
        # [ String (valid SQL query), Hash (corresponding to @filter hash)]
      [ filter_sql_str, filter_ref_hash ]
      # raise [ filter_sql_str, filter_ref_hash ].inspect
    end

    private

      #helpers for load_filters

      def load_filter by, context, fp, view
        #input: 
          # Sybmol for filter type(: time, :restaurants, :riders, or :status), 
          # Symbol for context (:load or :request)
          # Hash of client-loaded filter params (params[:filter])
        # does: determines filter type and routes to filter-specific retrieval method
        # output: Hash with following structure:
          # { <filter_name>: <filter_query> } 
          # to be appended to master filter hash next level up
        if by == :time
          load_time_filter context, fp, view
        else
          load_resource_filter by, context, fp
        end
      end

      def load_time_filter context, fp=nil, view=nil
        #input: Symbol (:load or :request), Hash of filter params (optional), Symbol naming view (:table, :grid) (optional)
        #does: retrieves correct filter query based on context and appends it to hash
        #output: Hash of filter key/value pairs to be appended to master filter hash
        
        case context
        
        when :load 
          start_value = Time.zone.now.beginning_of_week
          end_value = start_value + 6.days + 23.hours + 59.minutes
        
        when :request
          start_value = parse_time_filter_params( fp[:start] )
          
          case view
          
          when :table
            end_value = parse_time_filter_params( fp[:end] )
          when :grid
            end_value = start_value + 6.days + 23.hours + 59.minutes
          end
        end

        { start: start_value, :end => end_value }
      end

      def parse_time_filter_params p
        #input: value of either @filter[:start] or @filter[:end]
        #does: determine source of param construction (via reflection)
          # if String, assumes source is server load
          # if Hash of ActionController::Parameters, assumes source is user request
        #output: correct filter query based on context
        case p.class.name
        when 'Time'
          p
        when 'String' # from server load
          Time.zone.parse p
        when 'ActionController::Parameters' # from user request
          Time.zone.local( p[:year].to_i, p[:month].to_i, p[:day].to_i, 0 )
        end
      end

      def load_resource_filter by, context, fp=nil
        #input: Symbol (:load or :request), Hash of filter params (optional)
        #does: retrieves correct filter query based on context and appends it to hash
        #output: Hash of filter key/value pairs to be appended to master filter hash
        
        case by            
        when :restaurants
          it = @restaurant
          caller_key = :restaurant
        when :rider
          it = @rider
          caller_key = :rider
        end

        if it && @caller == caller_key # it will only be defined for by == :restaurants || :riders
          value = [ it.id ]
        elsif context == :load || fp[by].include?( 'all' )
          value = [ 'all' ]
        else
          value = parse_resource_filter_vals fp[by], by
        end

        { by => value }
      end

      def parse_resource_filter_vals vals, by
        if by == :status
          vals
        else
          vals.map(&:to_i)
        end
      end      

      #helpers for filters

      def filter_sql_str
        #input: @filter (implicit)
        #does: builds a SQL query by appending queries for each filter present in @filter hash
        #output: SQL query string
        @filter.keys.map{ |key| filter_sql_str_for(key) }.join( " AND " )
      end

      def filter_sql_str_for key
        #input: Symbol corresponding to key in @filter (:start, :end, :restaurants, :riders)
        #does: returns correct SQL query string for given key
        #output: SQL query string
        case key
        when :start
          "start > :start"
        when :end
          "start < :end"
        when :restaurants
          "restaurants.id IN (:restaurants)"
        when :riders
          if @filter[:riders] == [ 'all' ] || @filter[:riders].include?(0)
            "(riders.id IN (:riders) OR riders.id IS null)"
          else
            "riders.id IN (:riders)"
          end 
        when :status
          "assignments.status IN (:status)"
        end
      end

      def filter_ref_hash
        #input: @filter (implicit)
        #does: maps @filter hash onto a hash referenced by the queries retrieved by filter_sql_str
        #output: Hash with keys corresponding to keys in @filter
        hash = {}
        @filter.each do | key, val |
          if val == [ 'all' ]
            hash[key] = all_selected_for key
          else
            hash[key] = val
          end
        end
        hash
      end

      def all_selected_for key
        if key == :status
          AssignmentStatus.select_options.map(&:last)
        else
          klass = key.to_s.capitalize.singularize.constantize
          arr = klass.all.map(&:id).map(&:to_i)
          arr.push(0) if key == :riders
          arr
        end
      end

  end

  module ClassMethods
  end
  
end