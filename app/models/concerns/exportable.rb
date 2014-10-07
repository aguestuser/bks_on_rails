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

    def export
      CSV.generate do |csv|
        csv << ( self::EXPORT_HEADERS + self.child_export_headers )

        self.all.each do |record|
          csv << self.export_cells_from( record, self::EXPORT_COLUMNS )
        end
      end
    end

    def export_cells_from record, col_names
      cells = record.export_values_for col_names
      cells + self.child_export_cells_from(record)
    end
  end
end