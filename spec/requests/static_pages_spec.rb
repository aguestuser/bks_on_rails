require 'spec_helper'

describe "Static pages" do
  
  subject { page }

  shared_examples_for 'all static pages' do
    it { should have_h1(expected_heading) }
    it { should have_title(full_title(expected_title)) }
    it "should have correct links in nav bar " do
      check_nav_links
    end
  end  

  describe "Home page" do
    before { visit root_path }
    let(:expected_heading) { 'BK Shift on Rails' }
    let(:expected_title)  { '' }

    it_should_behave_like 'all static pages'
  end

  describe "Manual" do
    before { visit manual_path }
    let(:expected_heading) { 'Manual' }
    let(:expected_title) { expected_heading }

    it_should_behave_like 'all static pages'
  end
end