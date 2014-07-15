module RiderPageMacros
  def get_rider_form_hash(action)
    case action
    when 'new'
      {
        fields: {
          #account
          'Password' => account.password,
          'Password confirmation' => account.password_confirmation,
          #contact
          'Name' => contact.name,
          'Title' => contact.title,
          'Email' => contact.email,
          'Phone' => contact.phone,
          #location
          'Street address' => location.address,
          #qualifications
          'Hiring assessment' => qualifications.hiring_assessment,
          'Experience' => qualifications.experience,
          'Geography' => qualifications.geography,
          'Password' => account.password,
          'Password confirmation' => account.password_confirmation
        },
        selects: { 
          #location
          'Borough' => location.borough.text,
          'Neighborhood' => location.neighborhood.text,
          #rating
          'Reliability' => rating.reliability,
          'Likeability' => rating.likeability,
          'Speed' => rating.speed,
          'Initial points' => rating.initial_points
        },
        checkboxes: [
          #equipment
          { label: 'Bike', id: 'rider_equipment_set_attributes_bike', value: true }, 
          { label: 'Lock', id: 'rider_equipment_set_attributes_lock', value: true },
          { label: 'Helmet', id: 'rider_equipment_set_attributes_helmet', value: true },
          { label: 'Rack', id: 'rider_equipment_set_attributes_rack', value: true },
          { label: 'Bag', id: 'rider_equipment_set_attributes_bag', value: true },
          { label: 'Insulated bag', id: 'rider_equipment_set_attributes_heated_bag', value: true },
          { label: 'Cell phone', id: 'rider_equipment_set_attributes_cell_phone', value: true },
          { label: 'Smart phone', id: 'rider_equipment_set_attributes_smart_phone', value: true },
          { label: 'Car', id: 'rider_equipment_set_attributes_car', value: true },
          #skills
          { label: 'Bike repair', id:'rider_skill_set_attributes_bike_repair', value: true },
          { label: 'Fix flats', id:'rider_skill_set_attributes_fix_flats', value: true },
          { label: 'Early morning', id:'rider_skill_set_attributes_early_morning', value: true },
          { label: 'Pizza', id:'rider_skill_set_attributes_pizza', value: true }
        ]
      }
    when 'edit'
      {
        fields: { 'Name' => 'Poopy Pants' },
        selects: { 'Borough' => 'Staten Island' },
        checkboxes: [ {label: 'Bike', id: 'restaurant_equipment_set_attributes_bike', value: false } ]
      }
    else 
      raise "Invalid action argument passed to get_form_hash, must be 'create' or 'edit'."
    end
  end
end