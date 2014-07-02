module RequestSpecHelper
  
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

  #custom matchers
  RSpec::Matchers.define :have_heading do |heading|
    match do |page|
      expect(page).to have_selector('h1', text: heading)
    end
  end
  
end