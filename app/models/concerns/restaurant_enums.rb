module RestaurantEnums
  class Statuses
    include Enum
    define :ACTIVE, 'new account'
    define :INACTIVE, 'emergency only'
    define :AT_RISK, 'at risk'
    define :AT_HIGH_RISSK, 'at high risk'
    define :STABLE, 'stable'
    define :VARIABLE_NEEDS, 'variable needs'
  end
end