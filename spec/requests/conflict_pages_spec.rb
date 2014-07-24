require 'spec_helper'
include CustomMatchers
include RequestSpecMacros

describe "Conflict Requests" do
  let(:rider){ FactoryGirl.create(:rider) }
  let(:other_rider) { FactoryGirl.create(:rider) }
  let(:conflicts) { 2.times.map { FactoryGirl.build(:conflict, :with_rider, rider: rider) } }
  let(:conflict) { conflicts[0] }
  let(:other_conflict) { FactoryGirl.build(:conflict, :with_rider, rider: other_rider) }

  let(:staffer) { FactoryGirl.create(:staffer) }
  before { mock_sign_in staffer }

  subject { page }

  describe "Conflicts#show" do
    before do
      conflict.save
      visit rider_conflict_path(rider, conflict)
    end

    it { should have_h3('Conflict Details') }
    it { should have_content('Date:') }
    it { should have_content(conflict.date.strftime("%m/%d")) }
    it { should have_content('Period:') }
    it { should have_content(conflict.period.text) }
  end

  describe "Conflicts#index" do
    before do
      conflicts.each(&:save) 
      other_conflict.save
      visit rider_conflicts_path rider
    end

    #table headers
    it { should have_h1("Conflicts for #{rider.contact.name}") }
    it { should have_row_header('Date') }
    it { should have_row_header('Period') }

    #table rows
    it { should have_content(conflicts[0].date.strftime("%m/%d")) }
    it { should have_content(conflicts[1].date.strftime("%m/%d")) }
    it { should have_content(conflict.period.text) }
    it { should have_content(conflict.period.text) }
    it { should have_link('Delete', href: rider_conflict_path(rider, conflicts[0])) }
    it { should have_link('Delete', href: rider_conflict_path(rider, conflicts[1])) }

    it { should_not have_content(other_conflict.date.strftime("%m/%d")) }

    it "should be able to delete a conflict" do
      expect{ click_link('Delete', href: rider_conflict_path(rider, conflicts[0])) }.to change(Conflict, :count).by(-1)
    end
  end

end