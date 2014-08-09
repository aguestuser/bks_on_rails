module TimeboxableHelper
  
  def header_to_selector header
    header.downcase.sub ' ', '_'
  end

  def period_id_to_header id
    id.capitalize.sub(id.last(2), id.last(2).upcase).sub( '_', ' ' )
  end

  def periods
    [ 'Mon AM','Mon PM','Tue AM','Tue PM','Wed AM','Wed PM','Thu AM','Thu PM','Fri AM','Fri PM', 'Sat AM', 'Sat PM', 'Sun AM', 'Sun PM' ]
  end

end

# class Week
#   def initialize start_time, end_time
#     @start = start_time
#     @end = end_time
#   end

#   HEADERS = [ 'Mon AM','Mon PM','Tue AM','Tue PM','Wed AM','Wed PM','Thu AM','Thu PM','Fri AM','Fri PM', 'Sat AM', 'Sat PM', 'Sun AM', 'Sun PM' ]
#   SELECTORS = ;

#   def periods
    
#   end
# end