 class WeekGrid 
  def initialize (week, y_axis, entities, sort_key)

    @y_axis # [ :rider, :restaurant ]
    @header = load_header
    @rows = load_rows week, sort_key
  end

  def load_header
    
  end

  #######
  #NEED TO INCLUDE FIRST COL VAL IN ROW IF I"M GOING TO SORT BY IT!
  #####

  def load_rows week, entities, sort_key
    rows = []
    entities.each_with_index do |entity, i|  
      rows[i][:y_label] = y_axis_label_for entity, i+1
      week_record_hash.each do |day_per, resources|  
        rows[i][day_per] = {
          resources: resources,
          value: cell_values_from resources
          class_str: class_str_from i+1, day_per, entity
        }
      end
    end
    rows.sorty_by{ |row| row[sort_key] } 
  end

  def y_axis_label_from entity, row_num
    entity_class_str = header_to_selector entity.name
    {
      resource: entity,
      value: entity.name,
      class_str: "row_#{row_num} col_1 "
    }
  end

  def y_axis_label_class_str_from entity
    case entity.class
      prefix = 
  end

  def cell_values_from resources
    resources.map{ |r| cell_value_from r }.join(', ') unless resources.empty?
  end

  def cell_value_from resource
    case resource.class
    when Shift
      parse_shift resource
    when Conflict
      parse_conflict resource
    end
      
  end

  def parse_shift s
    case @y_axis
    when :restaurant
      s.assignment.rider.short_name 
    when :rider
      s.restaurant
    end
  end

  def parse_conflict c
    c.nil? ? '[AVAIL]' : "[UNAVAIL]: #{c.grid_time}"
  end

  def data_class_str_from row_num, day_per, entity
    r2_prefix = @y_axis.to_s << '_'
    r2_val = header_to_selector entity
    c_prefix = 'per_'
    col_num = Week.SELECTORS.index(day_num.to_s) + 1
    "row_#{row_num} col_#{col_num} #{r_prefix}#{r2_val}"
  end


end


    # grid = {
    #   header: ,
    #   rows: [
    #     { 
    #       label: ,
    #       entity: ,
    #       {
    #         mon_am: 
    #         {
    #           entity: ,
    #           value: 
    #         },
    #         ..
    #       }
    #      }
    #   ]
    # }

    # class Grid 
    #   def initialize (week, sort_key)
    #   end
    # end

    # rows = rows.sort_by{ |row| row[sort_key] }

    row[col_key]

