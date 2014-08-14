 class Grid 
  include TimeboxableHelper

  attr_accessor :headers, :rows

  def initialize (week, y_axis, entities, sort_key)
    # raise week.record_hash.to_yaml
    @y_axis= y_axis # [ :rider, :restaurant ]
    @headers = load_headers
    @rows = load_rows week, entities, sort_key
  end

  private

  #Main Functions

  def load_headers 
    row = [ {
      value: @y_axis.to_s.capitalize,
      id_str: "row_0_col_1",
      class_str: "x_label",
    } ]
    row + Week::SELECTORS.each_with_index.map do |day_per_str, i|
      col_num = i + 2
      {
        value: Week::HEADERS[i],
        id_str: "row_0_col_#{col_num}",
        class_str: "day_per_#{day_per_str}"
      }
    end
  end

  def load_rows week, entities, sort_key
    rows = []
    entities.each_with_index do |entity, i|
      
      entity_class_str = entity_class_str_from entity

      rows[i] = []  
      rows[i][0] = y_label_cell_from entity, i, entity_class_str
      
      Week::SELECTORS.each_with_index do | day_per_str, j| 

        case @y_axis
        when :rider
          entity_hash = { rider: entity }
        when :restaurant
          entity_hash = { restaurant: entity }
        end

        day_per_sym = day_per_str.to_sym
        resources = week.records_for day_per_str, entity_hash

        rows[i][j+1] = data_cell_from day_per_str, resources, i, j, entity_class_str
      end
    end
    rows
  end

  #Helper Functions



  def entity_class_str_from entity
    prefix = @y_axis.to_s
    val = header_to_selector entity.name
    "#{prefix}_#{val}"
  end

  def y_label_cell_from entity, i, entity_class_str
    row_num = i + 1
    {
      resources: [ entity ],
      values: [ entity.name ],
      id_str: "row_#{row_num}_col_1",
      class_str: "#{entity_class_str} y_axis_label"
      # sort_key: 0
    }
  end

  def data_cell_from day_per_str, resources, i, j, entity_class_str
    row_num = i + 1
    col_num = j + 2 
    values = data_cell_vals_from resources
    color = color_from resources
    {
      resources: resources,
      values: values,
      id_str: "row_#{row_num}_col_#{col_num}",
      class_str: "#{entity_class_str} day_per_#{day_per_str} #{color}" 
      # sort_key: sort_key
    }
  end

  def data_cell_vals_from resources
    resources.empty? ? [ '[AVAIL]' ] : resources.map{ |r| data_cell_val_from r }
  end

  def data_cell_val_from resource
    case resource.class.name
    when 'Shift'
      parse_shift_for_val resource
    when 'Conflict'
      parse_conflict_for_val resource
    end
      
  end

  def parse_shift_for_val s
    case @y_axis
    when :restaurant
      s.assignment.rider.short_name.to_s + ' ' + s.assignment.status.short_code
    when :rider
      s.restaurant.name + ' ' + s.assignment.status.short_code
    end
  end

  def parse_conflict_for_val c
    "[NA] #{c.grid_time}"
  end

  def color_from resources
    unless resources.empty? # if so: color will be white in absence of css declaration
      case resources[0].class.name
      when 'Shift'
        parse_shifts_for_color resources
      when 'Conflict'
        'black'
      end
    end
  end

  def parse_shifts_for_color shifts 
    statuses = shifts.map{ |shift| shift.assignment.status.text }
    if statuses.include? 'Confirmed'
      'green'
    elsif statuses.include? 'Delegated'
      'yellow'
    elsif statuses.include? 'Proposed'
      'orange'
    else # if 'Cancelled (Rider)' or 'Cancelled (Restaurant)'
      'gray'
    end
  end

end

