module Boroughs
  class Boroughs 
    # include Ruby::Enum
    include Enum
    define :MANHATTAN, 'Manhattan'
    define :BROOKLYN, 'Brooklyn'
    define :QUEENS, 'Queens'
    define :BRONX, 'Bronx'
    define :STATEN_ISLAND, 'Staten Island'
  end
end