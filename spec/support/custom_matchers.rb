module CustomMatchers
  RSpec::Matchers.define :have_heading do |heading|
    match do |page|
      expect(page).to have_selector('h1', text: heading)
    end
  end

  RSpec::Matchers.define :have_success_message do |heading|
    match do |page|
      expect(page).to have_selector('h1', text: heading)
    end
  end

  RSpec::Matchers.define :have_a_success_message do
    match do |page|
      expect(page).to have_selector('div.alert.alert-success')
    end
  end


  RSpec::Matchers.define :have_success_message do |message|
    match do |page|
      expect(page).to have_selector('div.alert.alert-success', text: message)
    end
  end

end

