module TimeboxableHelper

  def header_to_selector header
    header.downcase.sub ' ', '_'
  end

  def day_and_period_to_selector day, period
    day.first(3).downcase << '_' << period.downcase
  end

  def selector_to_header id
    id.capitalize.sub(id.last(2), id.last(2).upcase).sub( '_', ' ' )
  end

  def selector_to_day selector
    prefix = selector.first(3).capitalize
    prefix + suffix_from_prefix(prefix)
  end

  def suffix_from_prefix prefix
    case prefix
    when 'Mon'
      'day'
    when 'Tue'
      'sday'
    when 'Wed'
      'nesday'
    when 'Thu'
      'rsday'
    when 'Fri'
      'day'
    when 'Sat'
      'urday'
    when 'Sun'
      'day'
    end
  end

  def periods
    [ 'Mon AM','Mon PM','Tue AM','Tue PM','Wed AM','Wed PM','Thu AM','Thu PM','Fri AM','Fri PM', 'Sat AM', 'Sat PM', 'Sun AM', 'Sun PM' ]
  end

end




# def load_week
#   @week = Week.new(@filter[:start], @filter[:end])
# end
