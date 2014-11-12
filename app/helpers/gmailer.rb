class Gmailer
  ## some auth stuff here
  # see: https://github.com/GregBaugues/twilio-rails-gmail-api
  # requires:
  #   (1) following gems:
  #       gem 'google-api-client', require: 'google/api_client'
  #       gem 'omniauth', '~> 1.2.2'
  #       gem 'omniauth-google-oauth2'
  #   (2) a configured omniauth.rb file in config/initalizers/
  #   (3) saving token in session hash
  #   (4) a route for the callback from Google API
  # then:

  

  def create_message body, recipients, subject
    body = # render template as string
    message = Mime::Text.new(body).merge({
      to: recipients.join(','),
      from: Gmailer::FROM,
      subject: helper.subject
    })
    { 'raw' => Base64.urlsafe_encode64(message) }    
  end

  def send message
    client = Google::APIClient.new  
    client.authorization.access_token = Token.access_token  # requires Token class described at above link
    service = client.discovered_api('gmail')
    result = client.execute(
      api_method: service.users.messages.send,
      parameters: { 'userId' => 'me', 'body' => message }
    )
    # maybe add some error handling for HttpError?
  end

  class Rider
    ## some defaults here


    def request_conflicts rider, conflicts, week_start, account
      @rider = rider, @conflicts = conflicts, @staffer = account.user

      @next_week_start = week_start
      @this_week_start = @next_week_start - 1.week

      body = #get html from haml

      message = Gmailer.create_message body, [rider.full_email], helper.subject

    end

  end
end