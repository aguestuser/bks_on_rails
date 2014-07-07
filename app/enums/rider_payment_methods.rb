class RiderPaymentMethods < ClassyEnum::Base
end

class RiderPaymentMethods::Cash < RiderPaymentMethods
end

class RiderPaymentMethods::Check < RiderPaymentMethods
end
