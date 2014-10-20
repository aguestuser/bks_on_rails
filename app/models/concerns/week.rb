class Week
  include TimeboxableHelper

  attr_accessor :start, :end, :klass, :records, :record_hash

  def initialize start_time, end_time, record_klass
    @start = start_time.beginning_of_day
    @end = end_time.beginning_of_day + 24.hours
    @klass = record_klass
    
    @records = load_records
    @record_hash = load_record_hash
  end

  DAYS = [ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' ]
  PERIODS = [ 'AM', 'PM' ]

  HEADERS = [ 'Mon AM','Mon PM','Tue AM','Tue PM','Wed AM','Wed PM','Thu AM','Thu PM','Fri AM','Fri PM', 'Sat AM', 'Sat PM', 'Sun AM', 'Sun PM' ]
  SELECTORS = [ 'mon_am','mon_pm','tue_am','tue_pm','wed_am','wed_pm','thu_am','thu_pm','fri_am','fri_pm', 'sat_am', 'sat_pm', 'sun_am', 'sun_pm']

  def records_for day_period, entity_hash 

    entity_key = entity_hash.keys[0]
    entity = entity_hash.values[0]
    rh_key = day_period.to_sym

    records = @record_hash[rh_key]

    if records.nil?
      matches = []
    else
      matches = records.select do |r| 
        r.send(entity_key) == entity 
      end
    end
    matches
  end

  def bg_color_for status
    case status
    when AssignmentStatus::Unassigned
      'red'
    when AssignmentStatus::Proposed
      'orange'
    when AssignmentStatus::Delegated
      'yellow'
    when AssignmentStatus::Confirmed
      'green'
    when AssignmentStatus::CancelledByRider
      'gray'
    when AssignmentStatus::CancelledByRestaurant  
      'gray'
    end
  end

  private

    def load_records
      @klass.where("start > :start AND start < :end", 
        { start: @start, :end => @end })
        .order("start asc")
        .to_a
    end

    def load_record_hash
      hash = {}
      DAYS.each_with_index do |day, i|
        PERIODS.each do |period|
          key = day_and_period_to_selector(day, period).to_sym
          hash[key] = select_records_by_period period, i
        end
      end
      hash
    end

    def select_records_by_period period, offset
      selection = @records.select do |record|
        ( record.start > @start + offset.days ) && 
        ( record.start < @end - 6.days + offset.days) && 
        ( 
          record.period.text.upcase == period ||
          record.period.text == 'Double'
        )
      end
      # selection == [] ? nil : selection
    end
end