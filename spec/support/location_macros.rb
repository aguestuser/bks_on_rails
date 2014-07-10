module ContactInfoMacros
  def check_borough_in_address(contact_info)
    boroughs = %w[Brooklyn brooklyn Queens Bronx Manhattan Staten NYC]
    boroughs.each do |borough|
      contact_info.street_address = "#{contact_info.street_address} #{borough}" 
      expect(contact_info).not_to be_valid
    end 
  end
end