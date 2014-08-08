class AssignmentStatus < ClassyEnum::Base
end

class AssignmentStatus::Unassigned < AssignmentStatus
end

class AssignmentStatus::Proposed < AssignmentStatus
end

class AssignmentStatus::Delegated < AssignmentStatus
end

class AssignmentStatus::Confirmed < AssignmentStatus
end

class AssignmentStatus::CancelledByRider < AssignmentStatus
  def text
    'Cancelled (Rider)'
  end
end

class AssignmentStatus::CancelledByRestaurant < AssignmentStatus
  def text
    'Cancelled (Restaurant)'
  end
end
