 class Grid 
  include TimeboxableHelper

  attr_accessor :headers, :rows

  def initialize (week, y_axis, entities, sort_key)
    @y_axis= y_axis # [ :rider, :restaurant ]
    @headers = load_headers
    @rows = load_rows week, entities, sort_key
  end

  private

  #Main Functions

  def load_headers 
    row = [ y_label_header_cell ]
    row.concat header_cells
  end

  def load_rows week, entities, sort_key
    entities.each_with_index.map do |entity, i|
      row = [ y_label_data_cell_from(entity, i) ]
      row.concat data_cells_from(entity, i, week)
    end
  end

  #Main Helper Functions

  def y_label_header_cell
    {
      value: @y_axis.to_s.capitalize,
      id_str: "row_0_col_1",
      class_str: "x_label",
    }
  end

  def header_cells
    Week::SELECTORS.each_with_index.map do |day_per_str, i|
      col_num = i + 2
      {
        value: Week::HEADERS[i],
        id_str: "row_0_col_#{col_num}",
        class_str: "day_per_#{day_per_str}"
      }
    end
  end

  def y_label_data_cell_from entity, i
    row_num = i + 1
    entity_class_str = entity_class_str_from entity
    {
      resources: [ entity ],
      values: [ entity.name ],
      id_str: "row_#{row_num}_col_1",
      class_str: "#{entity_class_str} y_axis_label"
    }
  end

  def data_cells_from entity, i, week
    Week::SELECTORS.each_with_index.map do | day_per_str, j| 
      entity_hash = {}
      entity_hash[@y_axis] = entity
      entity_class_str = entity_class_str_from entity
      resources = week.records_for day_per_str, entity_hash

      data_cell_from day_per_str, resources, i, j, entity_class_str
    end
  end

  #Sub Helper Functions

  def entity_class_str_from entity
    prefix = @y_axis.to_s
    val = header_to_selector entity.name
    "#{prefix}_#{val}"
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
    }
  end

  def data_cell_vals_from resources
    if resources.empty?
      @y_axis == :rider ? [ '[AVAIL]' ] : [ '--' ]
    else
      resources.map{ |r| data_cell_val_from r }
    end
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
      prefix = s.assigned? ? s.assignment.rider.short_name.to_s : '--'
      prefix + ' ' + s.assignment.status.short_code
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
    elsif statuses.include? 'Unassigned'
      'red'
    else # if 'Cancelled (Rider)' or 'Cancelled (Restaurant)'
      'gray'
    end
  end
end

