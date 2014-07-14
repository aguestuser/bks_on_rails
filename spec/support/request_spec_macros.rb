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

  def check_nav_links
    links = [
      { text: 'Home' ,    new_page_title: '' },
      { text: 'Manual',   new_page_title: 'Manual' }
    ]
    links.each do |link|
      check_nav_link(link[:text], link[:new_page_title])
    end
  end

  def check_nav_link(link, title)
    click_link link
    expect(page).to have_title(full_title(title))
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

  #custom matchers  
end