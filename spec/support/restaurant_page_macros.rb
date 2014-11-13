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
          'Name' => restaurant.managers.first.contact.name,
          'Title' => restaurant.managers.first.contact.title,
          'Phone' => restaurant.managers.first.contact.phone,
          'Email' => restaurant.managers.first.contact.email,
          #manager.acccount
          'restaurant_managers_attributes_1_account_attributes_password' => 'changeme123',
          'restaurant_managers_attributes_1_account_attributes_password_confirmation' => 'changeme123',
          #rider_payment,
          'Pay rate' => rider_payment.rate
          # excluded for Restaurants#new
          # 'Brief' => restaurant.brief
        },
        selects: {
          #location
          'Borough' => location.borough.text,
          'Neighborhood' => location.neighborhood.text,
          #rider_payment
          'Rider payment method' => rider_payment.method.text
          #excluded for Restaurants#new
          # 'Status' => "is a newly signed up account. They say it gets busy. Let us know how it goes!"     
        },
        checkboxes: [
          #restaurant
          # excluded for Restaurants#new
          # { label: 'Active', id: 'restaurant_active', value: true },
         #rider_payment
          { label: 'Shift meal provided?', id: 'restaurant_rider_payment_info_attributes_shift_meal', value: true },
          { label: 'Cash out tips at end of each shift?', id: 'restaurant_rider_payment_info_attributes_cash_out_tips', value: true }
        ]
      }
    when 'edit'
      {
        fields: { 
          #contact
          'Restaurant name' => 'Poop Palace', 
          #manager.acccount
          # 'restaurant_managers_attributes_0_account_attributes_password' => 'changeme123',
          # 'restaurant_managers_attributes_0_account_attributes_password_confirmation' => 'changeme123',
          # 'restaurant_managers_attributes_1_account_attributes_password' => 'changeme123',
          # 'restaurant_managers_attributes_1_account_attributes_password_confirmation' => 'changeme123',
          #work_spec,
          'Delivery zone size' => work_spec.zone,
          'Daytime volume' => work_spec.daytime_volume,
          'Evening volume' => work_spec.evening_volume,
          'If you checked above, please explain:' => work_spec.extra_work_description,
          # 'Password' => manager.account.password,
          # 'Password confirmation' => manager.account.password_confirmation
        },
        selects: { 
          #location
          'Borough' => 'Staten Island', 
          #agency_payment
          'Agency payment method' => agency_payment.method.text
        },
        checkboxes: [ 
          #equipment
          { label: 'Do you provide a bike?', id: 'restaurant_equipment_need_attributes_bike_provided', value: true }, 
          { label: 'Do you require a rack?', id: 'restaurant_equipment_need_attributes_rack_required', value: true },
          #work_spec
          { label: 'Riders expected to do non-delivery work?', id: 'restaurant_work_specification_attributes_extra_work', value: true },
          #agency_payment
          { label: 'In-person payment collection requested?', id: 'restaurant_agency_payment_info_attributes_pickup_required', value: true }
 
        ]
      }
    else 
      raise "Invalid action argument passed to get_form_hash, must be 'create' or 'edit'."
    end
  end
end