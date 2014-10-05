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

    # def import_create file
    #   CSV.foreach( file.path, headers: true ) do |row|
    #     self.create! row.to_hash # will probably have to do some parsing here!
    #   end
    # end
  end
end










