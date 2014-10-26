module IoMacros

  def load_imported_assignment_attrs
    let(:imported_assignment_attrs){
      [
        { 'shift_id' => Shift.last(3)[0], 'rider_id' => 3, 'status' => 'delegated' },
        { 'shift_id' => Shift.last(3)[1], 'rider_id' => 2, 'status' => 'confirmed' },
        { 'shift_id' => Shift.last(3)[2], 'rider_id' => nil, 'status' => 'unassigned' }
      ]
    }
  end

  def filter_uniq_attrs attrs
    attrs.reject{ |k,v| k == 'id' || k == 'created_at' || k == 'updated_at' }
  end
end