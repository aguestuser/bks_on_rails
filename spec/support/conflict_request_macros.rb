module ConflictRequestMacros

  def load_conflict_scenario
    let!(:rider){ FactoryGirl.create(:rider) }
    let(:other_rider) { FactoryGirl.create(:rider) }
    let(:start){ Time.local(2014,1,6,12) }
    let(:end_){ Time.local(2014,1,6,18) }
    let!(:conflicts) do
      2.times.map do |n|
        FactoryGirl.build(:conflict, :with_rider, rider: rider, start: start + n.days, :end => end_ + n.days)
      end 
    end
    let(:conflict) { conflicts[0] }
    let(:other_conflict) { FactoryGirl.build(:conflict, :with_rider, rider: other_rider, start: start, :end => end_) }

    let(:staffer) { FactoryGirl.create(:staffer) } 
  end


  def check_conflict_form_contents(action, caller=nil)

    it { should have_label('Start') }
    it { should have_select('conflict_start_1i')}
    it { should have_select('conflict_start_2i')}
    it { should have_select('conflict_start_3i')}
    it { should have_select('conflict_start_4i')}
    it { should have_label('End') }
    it { should have_select('conflict_end_1i')}
    it { should have_select('conflict_end_2i')}
    it { should have_select('conflict_end_3i')}
    it { should have_select('conflict_end_4i')}

    case action
    when :new
      it { should have_button('Create conflict') }      
    when :edit
      it { should have_button('Save changes') }   
    end

    case caller 
    when :rider
      it { should_not have_select('conflict_rider_id') }   
    when nil
      it { should have_select('conflict_rider_id', with_options: [ rider.contact.name ] ) }   
    end
  end

  def make_invalid_conflict_submission
    select '09 AM', from: 'conflict_start_4i'
    select '08 AM', from: 'conflict_end_4i'
    click_button submit       
  end

  def make_valid_conflict_submission(caller=nil)
    select rider.contact.name, from: 'conflict_rider_id' unless caller == :rider
    select '08 AM', from: 'conflict_start_4i'
    select '09 AM', from: 'conflict_end_4i'
    click_button submit    
  end

  def make_valid_conflict_edit
    select '01 AM', from: 'conflict_start_4i'
    click_button submit
  end

  def batch_preview_conflicts_for rider
    conflicts.each(&:save)
    visit '/conflict/build_batch_preview'
    select rider.name, from: 'rider_id'
    fill_in 'week_start', with: 'January 6, 2014'
    click_button 'Submit'
  end

  def check_cloned_conflict_batch new_conflicts, old_conflicts
    new_conflicts.each_with_index do |nc, i|
      expect(nc.rider).to eq old_conflicts[i].rider
      expect(nc.start).to eq old_conflicts[i].start + 1.week
      expect(nc.end).to eq old_conflicts[i].end + 1.week
      expect(nc.id).not_to eq old_conflicts[i].id
      expect(nc.created_at).not_to eq old_conflicts[i].created_at 
    end
  end

  def submit_new_conflicts indices
    indices.each do |i|
      page.within("#period_#{i}"){ check "period_indices_" }
    end
    click_button 'Submit'
  end

  def check_new_conflicts conflicts, indices
    indices.each_with_index do |i,j|
      day = 13 + i/2
      start_h = is_even?(i) ? 12 : 18
      end_h = is_even?(i) ? 18 : 24

      expect(conflicts[j].start).to eq Time.zone.local(2014,1,day,start_h)
      expect(conflicts[j].end).to eq Time.zone.local(2014,1,day,end_h)
      expect(conflicts[j].rider).to eq rider
    end
  end
    
  def is_even? n
    (n+2)%2 == 0
  end


end
