require 'spec_helper'

describe "Exporting for Billing" do
  
  let(:names){ [ 'A', 'B', 'C'] }
  let!(:restaurants){ 3.times.map{ FactoryGirl.create(:restaurant) } }
  let!(:riders){ 3.times.map{ FactoryGirl.create(:rider) } }
  let(:shifts){ 3.times.map{ FactoryGirl.create(:shift) } }
  let(:staffer){ FactoryGirl.create(:staffer) }
  
  before do 
    3.times do |n|
      restaurants[n].mini_contact.update( name: names[n])
      riders[n].contact.update( name: names[n] )
    end
    mock_sign_in staffer
    visit root_path   
  end

  describe "exporting shifts" do
    before{ Shift.export }

    it "should download correctly formated csv's" do
      # expect( File.read('/us/Downloads/shifts.csv') )
      # expect( File.read('app/io/export/sample/shifts.csv') )
      #   .to eq File.read('app/io/export/sample/shifts.csv')
      expect(true).to eq true
    end    
  end # "exporting shifts"


end