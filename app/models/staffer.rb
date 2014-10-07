# == Schema Information
#
# Table name: staffers
#
#  id         :integer          not null, primary key
#  created_at :datetime
#  updated_at :datetime
#

class Staffer < ActiveRecord::Base
  include User, Contactable, ImportableFirstClass # ../concerns/user.rb

  scope :tess, -> { joins(:contact).where("contacts.email = ?", "tess@bkshift.com").first }

  # def Staffer.email_conflict_notification rider, conflicts, week_start, notes
  #   mailed = StafferMailer.conflict_notification( rider, conflicts, week_start ).deliver
  # end

  def self.import_children path
    #input: none
    #output Hash of Arrays of Staffer children 
      #{ accounts: Arr of Accounts, contacts: Arr of Contacts,  ...}
    { 
      accounts: Account.import( "#{path}accounts.csv" ),
      contacts: Contact.import( "#{path}contacts.csv" )
    }
  end

  def self.import_attrs_from row_hash, c, i
    #input: Hash of Staffer attributes, Hash of Hashes of attributes for children of Restaurants, Int (index)
    #output: Hash of Hashes of attributes for Staffer *and* its children
    row_hash
      .reject{ |k,v| k == 'id' }
      .merge( {
        account: c[:accounts][i],
        contact: c[:contacts][i]
      } )
  end



end
