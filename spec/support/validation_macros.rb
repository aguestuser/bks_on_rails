module ValidationMacros
  def check_required_attributes(model, attributes)
    attributes.each do |attr|
      model[attr] = nil
      expect(model).not_to be_valid    
    end
  end
end