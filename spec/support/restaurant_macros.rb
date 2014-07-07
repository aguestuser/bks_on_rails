module RestaurantMacros
  def fill_in_new_restaurant_form
      # contact info
      fill_in 'Restaurant name',    with: restaurant.contact_info.name
      fill_in 'Restaurant phone',   with: restaurant.contact_info.phone
      fill_in 'Street address',     with: restaurant.contact_info.street_address
      select restaurant.contact_info.borough,            
        from: 'Borough'
      select restaurant.contact_info.neighborhood,          
        from: 'Neighborhood'
      # manager
      fill_in 'Name',               with: restaurant.managers.first.name
      fill_in 'Title',              with: restaurant.managers.first.title
      fill_in 'Phone',              with: restaurant.managers.first.phone
      fill_in 'Email',              with: restaurant.managers.first.email
      # working conditions
      fill_in 'Delivery zone size', with: restaurant.work_arrangement.zone
      fill_in 'Daytime volume',     with: restaurant.work_arrangement.daytime_volume
      fill_in 'Evening volume',     with: restaurant.work_arrangement.evening_volume
      check 'extra_work'
      fill_in 'If you checked above, please explain:', with: restaurant.work_arrangement.extra_work_description
      # rider compensation
      select restaurant.work_arrangement.rider_payment_method, 
        from: 'Rider payment method'
      fill_in 'Pay rate',           with: restaurant.work_arrangement.pay_rate
      check 'cash_out_tips'
      # equipment
      check 'bike'
      check 'lock'
      check 'bag'
      # agency compensation
      select restaurant.agency_payment_method,
        from: 'Agency payment method'
  end
end