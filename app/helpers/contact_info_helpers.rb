module ContactInfoHelpers
  class Boroughs 
    # include Ruby::Enum
    include Enum
    define :MANHATTAN, 'Manhattan'
    define :BROOKLYN, 'Brooklyn'
    define :QUEENS, 'Queens'
    define :BRONX, 'Bronx'
    define :STATEN_ISLAND, 'Staten Island'
  end

  class Neighborhoods # note: will need to update this set of enums as we add more neighborhoods
    # include Ruby::Enum
    include Enum
    define :PARK_SLOPE, 'Park Slope'
    define :FORT_GREENE, 'Fort Greene'
    define :PROSPECT_HEIGHTS, 'Prospect Heights'
    define :GOWANUS, 'Gowanus'
    define :BOERUM_HILL, 'Boerum Hill'
    define :FINANCIAL_DISTRICT, 'Financial District'
    define :LOWER_EAST_SIDE, 'Lower East Side'
    define :TRIBECA, 'Tribeca'
    define :CHELSEA, 'Chelsea'
    define :EAST_VILLAGE, 'East Village'
    define :WEST_VILLAGE, 'West Village'
    define :MIDTOWN_EAST, 'Midtown East'
    define :MIDTOWN_WEST, 'Midtown West'
    define :EAST_HARLEM, 'East Harlem'
    define :LONG_ISLAND_CITY, 'Long Island City'
  end 
end