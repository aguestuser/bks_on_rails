class Unavailability
  attr_accessor :record, :type
  def initialize record
    @record = record
    @type = record.class.to_s.downcase.to_sym
  end
end