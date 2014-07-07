class BillingRate < ClassyEnum::Base
end

class BillingRate::Normal < BillingRate
end

class BillingRate::Extra < BillingRate
end

class BillingRate::EmergencyExtra < BillingRate
end

class BillingRate::Free < BillingRate
end
