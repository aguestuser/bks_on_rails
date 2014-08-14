class CompoundWeek < Week
  include TimeboxableHelper

  attr_accessor :records, :record_hash

  def initialize start_time, end_time, week_arr
      @start = start_time
      @end = end_time

      @records = load_records week_arr
      @record_hash = load_record_hash week_arr
  end

  public


  private

    def load_records week_arr
      records = week_arr.inject([]) { |arr, week| arr + week.records }
      records.sort_by { |record| record.start }
    end

    def load_record_hash week_arr
      week_arr.inject({}) do |hash, week| 
        hash = hash.merge!(week.record_hash) { |key, v1, v2| v1 + v2 }
      end
    end


end