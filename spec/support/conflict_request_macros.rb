module ConflictRequestMacros

  def check_conflict_form_contents(action, caller=nil)

    it { should have_select('Period') } #, options: Period.select_options) }
    it { should have_select('conflict_date_1i')}
    it { should have_select('conflict_date_2i')}
    it { should have_select('conflict_date_3i')}

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
end
