namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_staffers
  end
end

def make_staffers
  
  Staffer.create!(
    contact_info: ContactInfo.new(
      name: 'Austin Guest',
      title: 'IT Director',
      email: 'austin@bkshift.com',
      phone: '831-917-6400'
    )
  )

  Staffer.create!(
    contact_info: ContactInfo.new(
      name: 'Tess Cohen',
      title: 'Accounts Executive',
      email: 'tess@bkshift.com',
      phone: '347-460-6484'
    )
  )

  Staffer.create!(
    contact_info: ContactInfo.new(
      name: 'Justin Lewis',
      title: 'Accounts Manager',
      email: 'justin@bkshift.com',
      phone: '347-460-6484'
    )
  )

  Staffer.create!(
    contact_info: ContactInfo.new(
      name: 'Yagil Kadosh',
      title: 'Partner Relations Director',
      email: 'yagil@bkshift.com',
      phone: '201-341-9442'
    )
  )

end