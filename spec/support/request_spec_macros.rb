module RequestSpecMacros
  
  def mock_sign_in(user, options={})
    if options[:no_capybara]
      remember_token = Account.new_remember_token
      cookies[:remember_token] = remember_token
      user.account.update_attribute(:remember_token, Account.digest(remember_token))
    else
      visit sign_in_path
      fill_in "Email",    with: user.account.contact.email
      fill_in "Password", with: user.account.password
      click_button "Sign in"    
    end
  end

  def get_nav_links
    ['Home', 'Riders', 'Restaurants', 'Staffers', 'Account', 'Settings', 'Sign out']
  end

  def check_no_nav_links(links)
    links.each do |link|
      expect(page).to_not have_link(link)
    end
  end

  def check_nav_links(links)
    links.each do |linke|
      expect(page).to have_link(link)
    end
  end

  def get_paths
    [
      restaurant_path(1), new_restaurant_path, edit_restaurant_path(1), restaurants_path,
      rider_path(1), new_rider_path, edit_rider_path(1), riders_path,
      staffer_path(1), new_staffer_path, edit_staffer_path(1), staffers_path,
      shift_path(1), new_shift_path, edit_shift_path(1), shifts_path,
    ]
  end

  def check_sign_in_redirect(paths)
    paths.each do |path|
      visit path
      expect(page).to have_h1('Sign in')
    end
  end

  def check_fields(fields)
    fields.each do |field|
      expect(page).to have_selector('label', text: field)
    end
  end

  def check_name_subheads(names)
    names.each do |name|
      expect(page).to have_selector('h2', text: name)
    end
  end

  def fill_in_form(f)
    # input: Hash of 3 Hashes:
      # (1) fields: { field_name: field_input}
      # (2) selects: { select_name: select_value }
      # (3) checkboxes: Arr of checkbox hashes:
        #  [ { label: label_name, id: id_name, value: Boolean }, {}, {} ]
    # side efffects: populate form fields
    f[:fields].each do |field, input|
      fill_in field, with: input
    end
    f[:selects].each do |select_name, value|
      select value, from: select_name
    end
    f[:checkboxes].each do |cb|
      if cb[:value]
        check cb[:id]
      else
        uncheck cb[:id]
      end
    end
  end

  def count_models(models)
    #input: Array of Models
    #output: Array of Model.counts
    models.map { |m| m.count }
  end

  def model_counts_incremented?(old_counts, new_counts)
    diffs = new_counts.each_with_index.map do |new_count, i|
      new_count - old_counts[i]
    end 
    if 
      diffs.count(1) == diffs.size
      true
    else
      diffs
    end
  end
end