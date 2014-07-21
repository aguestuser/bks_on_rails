module AssignmentRequestMacros

  def check_form_contents(action, caller=nil)
    it { should have_content('Shift:') }
    it { should have_content(assignment_start) }
    it { should have_content(assignment_end) }
    it { should have_select( 'Status', options: AssignmentStatus.select_options.map { |pair| pair[0] } ) }
    
    unless caller == :rider
      it { should have_select('assignment_rider_id', with_options: [ rider.name ] ) } unless caller == :rider
    end

    case action
    when :new
      it { should have_button('Assign shift') }  
    when :edit
      it { should have_button('Assign shift') }  
    end
  end

  def make_valid_submission(caller=nil)
    select rider.name, from: 'assignment_rider_id' unless caller == :rider
    select 'Delegated', from: 'Status'
    click_button submit
  end
end