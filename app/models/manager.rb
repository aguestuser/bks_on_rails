# == Schema Information
#
# Table name: managers
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Manager < ActiveRecord::Base
  include User, Contactable # app/model/concerns/
  has_and_belongs_to_many :restaurants
    accepts_nested_attributes_for :restaurants

  def self.select_options
    self.all.joins(:contact).order("contacts.name asc").map{ |r| [ r.name, r.id ] }
  end

  def Manager.import managers_file, accounts_file, contacts_file
    accounts = Account.import accounts_file
    contacts = Contact.import contacts_file
    managers = Manager.import_self managers_file, accounts, contacts
  end

  def Manager.import_self managers_file, accounts, contacts
    path = Rails.env.test? ? "app/io/import/sample/staffers/" : "app/io/import/staffers/"
  
    managers = []
    CSV.foreach(managers_file, headers: true) do |row|
      i = $. - 2 # $. returns the INPUT_LINE_NUMBER, subtracting one produces index number
      attrs = row
        .to_hash
        .reject{ |k,v| k == 'id' }
        .merge( { account: accounts[i], contact: contacts[i] } )
      managers.push( Manager.new attrs )
    end
    managers
  end
end
