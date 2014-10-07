module Importable
  extend ActiveSupport::Concern

  included do # instance methods
    
  end

  module ClassMethods

    def import filepath
      recs = []
      CSV.foreach( filepath, headers: true ) do |row|
        recs.push( self.new row.to_hash )
      end
      recs
    end
  end
end