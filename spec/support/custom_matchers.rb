module CustomMatchers
  RSpec::Matchers.define :have_heading do |heading|
    match do |page|
      expect(page).to have_selector('h1', text: heading)
    end
  end
end

