class Urgency < ClassyEnum::Base
end

class Urgency::Weekly < Urgency
end

class Urgency::Extra < Urgency
end

class Urgency::Emergency < Urgency
end
