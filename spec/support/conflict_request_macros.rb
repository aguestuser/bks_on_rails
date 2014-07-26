module ConflictRequestMacros

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


end
