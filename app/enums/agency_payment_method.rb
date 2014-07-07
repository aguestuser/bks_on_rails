class AgencyPaymentMethod < ClassyEnum::Base
end

class AgencyPaymentMethod::Cash < AgencyPaymentMethod
end

class AgencyPaymentMethod::Check < AgencyPaymentMethod
end

class AgencyPaymentMethod::SquareApp < AgencyPaymentMethod
end

class AgencyPaymentMethod::Venmo < AgencyPaymentMethod
end
