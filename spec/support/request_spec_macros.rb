module RequestSpecMacros
  #methods
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
    f[:selects].each_with_index do |select, value|
      select value, from: select
    end
    f[:checkboxes].each do |cb|
      check cb.id if cb.value
    end
  end

  #custom matchers  
end