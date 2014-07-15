module RestaurantPageMacros
  def get_restaurant_form_hash(action)
    #input: (Str)
    #output: Hash of 3 Hashes -- 
      # (1) fields: { field_name: field_input}
      # (2) selects: { select_name: select_value }
      # (3) checkboxes: { <Arr of checkboxes> [label: label_name, id: id_name, value: Boolean }
    case action
    when 'new'
      {  
        fields: {
          #mini_contact
          'Restaurant name' => contact.name,
          'Restaurant phone' => contact.phone,
          #location,
          'Street address' => location.address,
          #manager,
          'Name' => restaurant.managers.first.account.contact.name,
          'Title' => restaurant.managers.first.account.contact.title,
          'Phone' => restaurant.managers.first.account.contact.phone,
          'Email' => restaurant.managers.first.account.contact.email,
          #rider_payment,
          'Pay rate' => rider_payment.rate,
          #work_spec,
          'Delivery zone size' => work_spec.zone,
          'Daytime volume' => work_spec.daytime_volume,
          'Evening volume' => work_spec.evening_volume,
          'If you checked above, please explain:' => work_spec.extra_work_description
          # excluded for Restaurants#new
          # 'Brief' => restaurant.brief
        },
        selects: {
          #location
          'Borough' => location.borough.text,
          'Neighborhood' => location.neighborhood.text,
          #rider_payment
          'Rider payment method' => rider_payment.method.text,
          #agency_payment
          'Agency payment method' => agency_payment.method.text
          #excluded for Restaurants#new
          # 'Status' => "is a newly signed up account. They say it gets busy. Let us know how it goes!"     
        },
        checkboxes: [
          #restaurant
          # excluded for Restaurants#new
          # { label: 'Active', id: 'restaurant_active', value: true },
          #equipment
          { label: 'Bike', id: 'restaurant_equipment_set_attributes_bike', value: true }, 
          { label: 'Lock', id: 'restaurant_equipment_set_attributes_lock', value: true },
          { label: 'Helmet', id: 'restaurant_equipment_set_attributes_helmet', value: true },
          { label: 'Rack', id: 'restaurant_equipment_set_attributes_rack', value: true },
          { label: 'Bag', id: 'restaurant_equipment_set_attributes_bag', value: true },
          { label: 'Insulated bag', id: 'restaurant_equipment_set_attributes_heated_bag', value: true },
          { label: 'Cell phone', id: 'restaurant_equipment_set_attributes_cell_phone', value: true },
          { label: 'Smart phone', id: 'restaurant_equipment_set_attributes_smart_phone', value: true },
          { label: 'Car', id: 'restaurant_equipment_set_attributes_car', value: true },
          #rider_payment
          { label: 'Shift meal provided?', id: 'restaurant_rider_payment_info_attributes_shift_meal', value: true },
          { label: 'Cash out tips at end of each shift?', id: 'restaurant_rider_payment_info_attributes_cash_out_tips', value: true },
          { label: 'Riders expected to do non-delivery work?', id: 'restaurant_work_specification_attributes_extra_work', value: true },
          { label: 'In-person payment collection requested?', id: 'restaurant_agency_payment_info_attributes_pickup_required', value: true }
        ]
      }
    when 'edit'
      {
        fields: { 'Restaurant name' => 'Poop Palace' },
        selects: { 'Borough' => 'Staten Island' },
        checkboxes: [ {label: 'Bike', id: 'restaurant_equipment_set_attributes_bike', value: false } ]
      }
    else 
      raise "Invalid action argument passed to get_form_hash, must be 'create' or 'edit'."
    end
  end
end