require 'spec_helper'

describe Location do

  let(:location) { FactoryGirl.create(:location) }

  subject { location }

  describe "attributes" do
    it { should respond_to(:address) }
    it { should respond_to(:lat) }
    it { should respond_to(:lng) }
    it { should respond_to(:borough) }
    it { should respond_to(:neighborhood) }
  end

  describe "validation" do
    
    it { should be_valid }

    describe "of address" do
      
      describe "with no value" do
        before { location.address = nil }
        it { should_not be_valid }
      end

      describe "with borough in address" do
        it "should be invalid" do
          boroughs = %w[Brooklyn brooklyn Queens Bronx Manhattan Staten NYC]
          boroughs.each do |borough|
            location.address = "#{location.address} #{borough}" 
            expect(location).not_to be_valid
          end   
        end
      end

      describe "with 'NY' in address" do
        before { location.address = "#{location.address} NY" }
        it { should_not be_valid }
      end
    end

    describe "of lat" do
      before { location.lat = nil }
      it { should be_valid }
    end

    describe "of lng" do
      before { location.lat = nil }
      it { should be_valid } 
    end

    describe "of borough" do
      
      describe "with no value" do
        before { location.borough = nil }
        it { should_not be_valid }
      end

      describe "with incorrect value" do
        before { location.borough = 'long island' }
        it { should_not be_valid }
      end
    end

    describe "of neighborhood" do
      
      describe "with no value" do
        before { location.neighborhood = nil }
        it { should_not be_valid }
      end

      describe "with incorrect value" do
        before { location.neighborhood = 'hoboken' }
        it { should_not be_valid }
      end
    end
  end
end