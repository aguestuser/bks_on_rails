module StafferMailerMacros

  #CONFLICT NOTIFICATION

  def check_conflict_notification_email_metadata mail, rider
    expect(mail.from).to eq [ "brooklynshift@gmail.com" ]
    expect(mail.to).to eq [ "brooklynshift@gmail.com", "tess@bkshift.com", "justin@bkshift.com" ] 
    expect(mail.subject).to eq "[CONFLICT SUBMMISSION] #{rider.name}"
  end

  def check_conflict_notification_email_body mail, rider, type
      # puts ">>>>>> MAIL"
      # print mail.body
    actual_body = parse_body_from mail
    expected_body = expected_conflict_notification_body_for rider, type

    expect(actual_body).to eq expected_body
  end

  def expected_conflict_notification_body_for rider, type
    str = File.read( "spec/mailers/sample_emails/conflict_notification_#{type}.html" )
    str.gsub('RIDER_NAME', "#{rider.name}")
  end

  # NEW RIDER NOTIFICATION

  def check_new_rider_notification_email_metadata mail, rider
    expect(mail.from).to eq [ "brooklynshift@gmail.com" ]
    expect(mail.to).to eq [ "brooklynshift@gmail.com", "tess@bkshift.com", "justin@bkshift.com" ] 
    expect(mail.subject).to eq "[NEW RIDER] #{rider.name}"
  end

  def check_new_rider_notification_email_body mail, rider
    actual_body = parse_body_from mail
    expected_body = expected_new_rider_notification_body_for rider
      # puts ">>>>>> MAIL"
      # print mail.body

    expect(actual_body).to eq expected_body
  end

  def expected_new_rider_notification_body_for rider
    File.read( "spec/mailers/sample_emails/new_rider_notification.html" )
      .gsub('RIDER_NAME', "#{rider.name}")
      .gsub('RIDER_ID', "#{rider.id}")
      .gsub('RIDER_EMAIL', "#{rider.email}")
  end

  #HELPER

  def parse_body_from mail
    mail.body.encoded.gsub("\r\n", "\n")
  end
  
end