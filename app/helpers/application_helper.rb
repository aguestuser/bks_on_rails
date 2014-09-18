module ApplicationHelper
  include SessionsHelper, TimeboxableHelper, TableHelper

  def full_title(page_title)  #input: String
                              #output: String (with base title appended) 
    base_title = "BK Shift on Rails"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def current_path
    response.request.env["PATH_INFO"]
  end

  def gravatar_for(user, options = { size: 50 }) #input: User, output: String (html img tag for user's gravatar) [http://gravatar.com/]
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end 

  def format_start start
    start.strftime "%m/%d | %I:%M%p"
  end

  def format_end end_time
    end_time.strftime "%I:%M%p"
  end

  def num_select_options n, m
    (n..m).map{ |num| [ num, num ] }
  end

  def now_unless_test
    Rails.env.test? ? Time.zone.local(2014,1,6,11) : Time.zone.now
  end

end
