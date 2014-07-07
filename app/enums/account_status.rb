class AccountStatus < ClassyEnum::Base
end

class AccountStatus::NewAccount < AccountStatus
  def text
    "New account"
  end
end

class AccountStatus::Stable < AccountStatus
end

class AccountStatus::AtRisk < AccountStatus
end

class AccountStatus::AtHighRisk < AccountStatus
end

class AccountStatus::EmergencyOnly < AccountStatus
end

class AccountStatus::VariableNeeds < AccountStatus
end

class AccountStatus::Inactive < AccountStatus
end
