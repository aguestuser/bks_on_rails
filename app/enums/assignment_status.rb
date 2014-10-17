class AssignmentStatus < ClassyEnum::Base
  def self.multiselect_options
    [ [ '* All Statuses', 'all' ] ] + self.select_options
  end
end

class AssignmentStatus::Unassigned < AssignmentStatus
  def short_code
    '[u]'
  end
end

class AssignmentStatus::Proposed < AssignmentStatus
  def short_code
    '[p]'
  end
end

class AssignmentStatus::Delegated < AssignmentStatus
  def short_code
    '[d]'
  end
end

class AssignmentStatus::Confirmed < AssignmentStatus
  def short_code
    '[c]'
  end
end

class AssignmentStatus::CancelledByRider < AssignmentStatus
  def text
    'Cancelled (Rider)'
  end
  def short_code
    '[xf]'
  end
end

class AssignmentStatus::CancelledByRestaurant < AssignmentStatus
  def text
    'Cancelled (Restaurant)'
  end
  def short_code
    '[xc]'
  end
end
