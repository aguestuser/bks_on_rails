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
    it { should have_content('Rider:') }
    it { should have_content(conflict.rider.contact.name) }
    it { should have_content('Start:') }
    it { should have_content(conflict.start.strftime("%m/%d | %I:%M%p")) }
    it { should have_content('End:') }
    it { should have_content(conflict.end.strftime("%I:%M%p")) }
    it { should have_content('Period:') }
    it { should have_content(conflict.period.text) }
  end

  describe "Conflicts#index" do
    before do
      conflicts.each(&:save) 
      other_conflict.save
    end

    describe "from root path" do
      before do
        visit conflicts_path
        # pp page.all("div div.row div div div div a")[0][:href]
      end
      #table headers
      it { should have_h1("Conflicts") }
      it { should have_row_header('Time') }
      it { should have_row_header('Period') }

      #table rows
      it { should have_content(conflicts[0].table_time) }
      it { should have_content(conflicts[1].table_time) }
      it { should have_content(other_conflict.table_time) }

      it { should have_content(conflicts[0].period.text.upcase) }
      it { should have_content(conflicts[1].period.text.upcase) }
      it { should have_content(other_conflict.period.text.upcase) }

      it { should have_link('Edit', href: "/conflicts/#{conflicts[0].id}/edit?root_path=/conflicts/") }
      it { should have_link('Edit', href: "/conflicts/#{conflicts[1].id}/edit?root_path=/conflicts/") }
      it { should have_link('Edit', href: "/conflicts/#{other_conflict.id}/edit?root_path=/conflicts/") }


      it { should have_link('Delete', href: "/conflicts/#{conflicts[0].id}?root_path=/conflicts/") }
      it { should have_link('Delete', href: "/conflicts/#{conflicts[1].id}?root_path=/conflicts/") }
      it { should have_link('Delete', href: "/conflicts/#{other_conflict.id}?root_path=/conflicts/") }

      it "should be able to delete a conflict" do
        expect{ click_link('Delete', href: "/conflicts/#{conflicts[0].id}?root_path=/conflicts/") }.to change(Conflict, :count).by(-1)
      end
    end

    describe "from rider path" do
      before do
        visit rider_conflicts_path rider
        # pp page.all("div div.row div div div div a")[0][:href]
      end
      #table headers
      it { should have_h1("Conflicts for #{rider.contact.name}") }
      it { should have_row_header('Time') }
      it { should have_row_header('Period') }

      #table rows

      it { should have_content(conflicts[0].table_time) }
      it { should have_content(conflicts[1].table_time) }

      it { should have_content(conflicts[0].period.text.upcase) }
      it { should have_content(conflicts[1].period.text.upcase) }

      it { should have_link('Edit', href: "/riders/#{rider.id}/conflicts/#{conflicts[0].id}/edit?root_path=/riders/#{rider.id}/conflicts/") }
      it { should have_link('Edit', href: "/riders/#{rider.id}/conflicts/#{conflicts[1].id}/edit?root_path=/riders/#{rider.id}/conflicts/") }
      it { should have_link('Delete', href: "/riders/#{rider.id}/conflicts/#{conflicts[0].id}?root_path=/riders/#{rider.id}/conflicts/") }
      it { should have_link('Delete', href: "/riders/#{rider.id}/conflicts/#{conflicts[1].id}?root_path=/riders/#{rider.id}/conflicts/") }

      it { should_not have_content(other_conflict.start.strftime("%m/%d | %I:%M%p")) }

      it "should be able to delete a conflict" do
        expect{ click_link('Delete', href: "/riders/#{rider.id}/conflicts/#{conflicts[0].id}?root_path=/riders/#{rider.id}/conflicts/") }.to change(Conflict, :count).by(-1)
      end
    end

    describe "from rider profile page" do
      before { visit rider_path rider }
      
      it { should have_h3("Conflicts") }
      it { should have_content(conflicts[0].table_time) }
      it { should have_link('Edit', href: "/riders/#{rider.id}/conflicts/#{conflicts[0].id}/edit?root_path=/riders/#{rider.id}") }
      it { should have_link('Delete', href: "/riders/#{rider.id}/conflicts/#{conflicts[1].id}?root_path=/riders/#{rider.id}") }

      it "should be able to delete a conflict" do
        expect{ click_link('Delete', href: "/riders/#{rider.id}/conflicts/#{conflicts[0].id}?root_path=/riders/#{rider.id}") }.to change(Conflict, :count).by(-1)
      end
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
          before { make_invalid_conflict_submission }
          it { should have_an_error_message }
        end

        describe "with valid input" do
          before { make_valid_conflict_submission }
          let(:new_counts){ count_models models }

          it "should create a new conflict" do
            check_model_counts_incremented old_counts, new_counts
          end
          it { should have_h1('Conflicts') }
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

        describe "with invalid input" do
          before { make_invalid_conflict_submission }
          it { should have_an_error_message }          
        end

        describe "with valid input" do
          before { make_valid_conflict_submission(:rider) }
          let(:new_counts){ count_models models }

          it "should create a new conflict" do
            check_model_counts_incremented old_counts, new_counts
          end
          it { should have_h1("Conflicts for #{rider.contact.name}") }
          it { should have_success_message("Created conflict for #{rider.contact.name}") }
        end
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
          before { make_invalid_conflict_submission }
          it { should have_an_error_message }
        end

        describe "with valid input" do
          before { make_valid_conflict_edit }

          it { should have_h1('Conflicts') }
          it { should have_success_message("Edited conflict for #{rider.contact.name}") }
          it "should save edit" do
            expect( conflict.reload.start.hour ).to eq 1
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

        describe "with invalid input" do
          before { make_invalid_conflict_submission }
          it { should have_an_error_message }
        end

        describe "with valid input" do
          before { make_valid_conflict_edit }

          it { should have_h1("Conflicts for #{rider.contact.name}") }
          it { should have_success_message("Edited conflict for #{rider.contact.name}") }
          it "should edit the conflict" do
            expect( conflict.reload.start.hour ).to eq 1
          end                    
        end
      end
    end
  end  

  describe "Conflicts#delete redirects" do
    
    before do
      rider
      conflicts.each(&:save)     
    end 

    describe "from (root) conflicts index" do
      before do
        visit conflicts_path
        click_link('Delete', href: "/conflicts/#{conflicts[0].id}?root_path=/conflicts/")
      end

      it { should have_h1('Conflicts') }
    end

    describe "from rider conflicts index" do
      before do 
        visit rider_conflicts_path(rider)
        click_link('Delete', href: "/riders/#{rider.id}/conflicts/#{conflicts[0].id}?root_path=/riders/#{rider.id}/conflicts/") 
      end

      it { should have_h1("Conflicts for #{rider.contact.name}") }
    end
  end
end