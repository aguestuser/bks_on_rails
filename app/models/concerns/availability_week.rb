class CompoundWeek < Week
  include TimeboxableHelper

  def initialize start_time, end_time, week_arr
      @start = start_time
      @end = end_time

      @records = load_records
      @record_hash = load_record_hash
  end

  public


  private

    def load_records
      records = week_arr.inject([]) { |arr, week| arr << week.records }
      records.sort_by { |record| record.start }
    end

    def load_record_hash
      week_arr.inject({}) { hash.merge!(week.record_hash) }
    end


end