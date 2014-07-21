module AssignmentRequestMacros

  def check_assignment_form_contents(action, caller=nil)
    it { should have_content('Shift:') }
    it { should have_content(assignment_start) }
    it { should have_content(assignment_end) }
    it { should have_select( 'Status', options: AssignmentStatus.select_options.map { |pair| pair[0] } ) }

    it { should have_select('assignment_rider_id', with_options: [ rider.name ] ) } unless caller == :rider
    it { should_not have_select('assignment_rider_id') } if caller == :rider

    case action
    when :new
      it { should have_button('Assign shift') }  
    when :edit
      it { should have_button('Save changes') }  
    end
  end

  def make_valid_assignment_submission(caller=nil)
    select rider.name, from: 'assignment_rider_id' unless caller == :rider
    select 'Delegated', from: 'Status'
    click_button submit
  end

  def make_valid_assignment_edit(caller=nil)
    select Rider.first.name, from: 'assignment_rider_id' unless caller == :rider
    select 'Cancelled (Rider)', from: 'Status' 
    click_button submit 
  end

  def make_invalid_assignment_submission(caller=nil)
    select '', from: 'assignment_rider_id' unless caller == :rider
    click_button submit
  end
end