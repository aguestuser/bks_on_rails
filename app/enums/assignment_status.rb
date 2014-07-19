class AssignmentStatus < ClassyEnum::Base
end

class AssignmentStatus::Proposed < AssignmentStatus
end

class AssignmentStatus::Delegated < AssignmentStatus
end

class AssignmentStatus::Confirmed < AssignmentStatus
end

class AssignmentStatus::CancelledByRider < AssignmentStatus
end

class AssignmentStatus::CancelledByRestaurant < AssignmentStatus
end
