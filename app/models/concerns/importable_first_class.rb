module ImportableFirstClass
  extend ActiveSupport::Concern

  included do # instance methods
    
  end

  module ClassMethods

    def import
      sub_path = self.name.downcase << 's'
      path = Rails.env.test? ? "app/io/import/sample/#{sub_path}/" : "app/io/import/#{sub_path}/"
      children = self.import_children path # .import_children is class-specific class method

      results = self.import_self path, sub_path, children
      self.print_import results, sub_path
    end

    def import_self path, sub_path, children
      csv_path = "#{path}#{sub_path}.csv"
      results = { num_recs: ( CSV.read(csv_path).count - 1 ), num_errors: 0, error_ids: [], errors: [], id_discrepancies: {} }

      CSV.foreach(csv_path, headers: true) do |row|
        i = $. - 2 # $. returns the INPUT_LINE_NUMBER, subtracting one produces index number
        row_hash = row.to_hash
        old_id = row_hash['id']    
        attrs = self.import_attrs_from row_hash, children, i # .import_attrs_from is a class-specific class method
          # puts ">>> ATTRS"
          # pp attrs
        record = self.new attrs

        if record.save
          results[:id_discrepancies][i+1] = record.id if i+1 != record.id
        else
          results[:num_recs] -= 1
          results[:num_errors] += 1
          results[:error_ids].push(old_id)
          results[:errors].push({ old_id => record.errors)
        end
      end
      results
    end

    def print_import results, sub_path
      puts "IMPORTED: #{results[:num_recs]} #{sub_path}"
      puts "ERRORS: #{results[:num_errors]}"
      if results[:errors].any?
        puts "ERROR IDS: #{results[:error_ids].join(', ')}"
        puts "ERRORS MESSAGES: "
        pp results[:errors]
      else 
        puts "ID DISCREPANCIES:"
        pp results[:id_discrepancies]
        # puts "NEW #{sub_path.upcase}:"
        # pp self.last(results[:num_recs]).map(&:contact)
      end
      # results
    end 
  end
end










