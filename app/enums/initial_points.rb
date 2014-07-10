class InitialPoints < ClassyEnum::Base
end

class InitialPoints::75 < InitialPoints
  def text
    'No Experience'
  end
end

class InitialPoints::85 < InitialPoints
  def text
    'Some Experience'
  end
end

class InitialPoints::90 < InitialPoints
  def text
    'Lots of Experience'
  end
end

class InitialPoints::100 < InitialPoints
  def text
    'Lots of Experience Plus Rec'
  end
end
