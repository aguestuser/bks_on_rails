module ApplicationHelper
  def full_title(page_title)  #input: String
                              #output: String (with base title appended) 
    base_title = "BK Shift on Rails"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end


end
