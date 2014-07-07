class RiderPaymentMethod < ClassyEnum::Base
end

class RiderPaymentMethod::Cash < RiderPaymentMethod
end

class RiderPaymentMethod::Check < RiderPaymentMethod
end
