require 'spec_helper'
include CustomMatchers # /spec/support/custom_matchers.rb

describe "Restaurant Pages" do
  let(:restaurant) { FactoryGirl.build(:restaurant) }
  subject { page }

  describe "creating new Restaurant" do
    before do
      visit new_restaurant_path
      fill_in 'Restaurant name',    with: restaurant.name
      fill_in 'Restaurant phone',   with: restaurant.phone
      fill_in 'Street address',     with: restaurant.street_address
      fill_in 'Borough',            with: restaurant.borough
      fill_in 'Neighborhood',       with: restaurant.neighborhood
      fill_in 'Name',               with: restaurant.manager.name
      fill_in 'Title',              with: restaurant.manager.title
      fill_in 'Email',              with: restaurant.manager.email
      fill_in 'Phone',              with: restaurant.manager.phone
      fill_in 'Delivery zone size'  with: restaurant.work_arrangement.zone
      fill_in 'Daytime volume',     with: restaurant.work_arrangement.daytime_volume
      fill_in 'Evening volume',     with: restaurant.work_arrangement.evenging_volume
      check 'extra_work'
      fill_in 'If you checked above, please explain:', 
        with: restaurant.work_arrangement.extra_work_description
      fill_in 'Rider payment method', with: restaurant.work_arrangement.rider_payment_method
      fill_in 'Pay rate',           with: restaurant.work_arrangement.pay_rate
      check 'rider_on_premises'
      check 'bike'
      check 'lock'
      check 'bag'
    end
  end
end