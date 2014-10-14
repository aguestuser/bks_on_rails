module Exportable
  extend ActiveSupport::Concern

  included do # instance methods
    def export_values_for col_names
      #input: Arr of Strs
      #output: Arr of Strs
      attrs = self.attributes.values_at(*col_names)
      parse_export_values attrs
    end
  end

  module ClassMethods

    def export scope=:all, start_t=nil, end_t=nil
      file = CSV.generate do |csv|
        csv << ( self::EXPORT_HEADERS + self.child_export_headers )

        records = self.export_records_from scope, start_t, end_t
        records.each_with_index do |record, i|
          csv << self.export_cells_from( record, self::EXPORT_COLUMNS, i )
        end
      end
      puts file
      file
    end

    def export_records_from scope, start_t, end_t
      case scope
      when :all
        self.all
      when :between
        self.where( "start > :start AND start < :end", { start: start_t, :end => end_t } )
      end
    end

    def export_cells_from record, col_names, index
      cells = record.export_values_for col_names
      cells[0] = index + 1
      cells + self.child_export_cells_from(record)
    end
  end
end