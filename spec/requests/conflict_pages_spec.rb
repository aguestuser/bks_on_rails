require 'spec_helper'
include CustomMatchers
include RequestSpecMacros
include ConflictRequestMacros

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

  # need specs for redirects from different caller paths
  # need specs for 

  describe "Conflicts#new" do
    before do 
      rider
      conflicts.each(&:save)
    end
    
    let(:models){ [Conflict] }
    let!(:old_counts) { count_models models }
    let(:submit) { 'Create conflict' }

    describe "from root path" do
      before do
        visit conflicts_path
        click_link('Create conflict', match: :first)
      end

      describe "page contents" do
        it { should have_h1('New Conflict') }
        check_conflict_form_contents :new
      end

      describe "form submission" do

        describe "with invalid input" do
          before { click_button submit }
          it { should have_an_error_message }
        end

        describe "with valid input" do
          before do
            select rider.contact.name, from: 'conflict_rider_id'
            click_button submit
          end
          let(:new_counts){ count_models models }

          it "should create a new conflict" do
            check_model_counts_incremented old_counts, new_counts
          end
          it { should have_h1('Conflicts for All Riders') }
          it { should have_success_message("Created conflict for #{rider.contact.name}") }
        end
      end
    end

    describe "from rider path" do
      before do
        visit rider_conflicts_path(rider)
        click_link('Create conflict', match: :first)
      end

      describe "page contents" do
        it { should have_h1("New Conflict for #{rider.contact.name}") }
        check_conflict_form_contents :new, :rider
      end

      describe "form submission" do
        before { click_button submit }
        let(:new_counts){ count_models models }

          it "should create a new conflict" do
            check_model_counts_incremented old_counts, new_counts
          end
          it { should have_h1("Conflicts for #{rider.contact.name}") }
          it { should have_success_message("Created conflict for #{rider.contact.name}") }
      end
    end
  end

  describe "Conflicts#edit" do
    before do 
      rider
      conflict.save
    end

    let(:submit) { 'Save changes' }

    describe "from root path" do
      before { visit edit_conflict_path(conflict) }

      describe "page contents" do
        it { should have_h1('Edit Conflict') }
        check_conflict_form_contents :edit
      end

      describe "form submission" do

        describe "with invalid input" do
          before do 
            select '', from: 'conflict_rider_id'
            click_button submit 
          end
          it { should have_an_error_message }
        end

        describe "with valid input" do
          before do
            select Period::Double.new.text, from: 'Period'
            click_button submit
          end

          it { should have_h1('Conflicts for All Riders') }
          it { should have_success_message("Edited conflict for #{rider.contact.name}") }
          it "should save edit" do
            expect( conflict.reload.period ).to be_an_instance_of Period::Double
          end
        end
      end
    end

    describe "from rider path" do
      before { visit edit_rider_conflict_path(rider, conflict)  }

      describe "page contents" do
        it { should have_h1("Edit Conflict for #{rider.contact.name}") }
        check_conflict_form_contents :edit, :rider
      end

      describe "form submission" do
        before do 
          select Period::Double.new.text, from: 'Period'
          click_button submit
        end

        it { should have_h1("Conflicts for #{rider.contact.name}") }
        it { should have_success_message("Edited conflict for #{rider.contact.name}") }
        it "should edit the conflict" do
          expect( conflict.reload.period ).to be_an_instance_of Period::Double
        end
      end
    end
  end  

  describe "Conflicts#delete" do
    
    before do
      rider
      conflicts.each(&:save)     
    end
    let(:models){ [Conflict] }
    let!(:old_counts) { count_models models }    

    describe "from (root) conflicts index" do
      before do 
        visit conflicts_path
        find(:link_by_href, conflict_path(conflict)).click
      end
      let(:new_counts) { count_models models }

      it { should have_h1('Conflicts for All Riders') }
      it "should delete conflict " do
        check_model_counts_decremented old_counts, new_counts
      end
    end


    describe "from rider conflicts index" do
      before do 
        visit rider_conflicts_path(rider)
        find(:link_by_href, rider_conflict_path(rider, conflict)).click
      end
      let(:new_counts) { count_models models }

      it { should have_h1("Conflicts for #{rider.contact.name}") }
      it "should delete conflict " do
        check_model_counts_decremented old_counts, new_counts
      end
    end
  end
end