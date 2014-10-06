class Borough < ClassyEnum::Base
end

class Borough::Manhattan < Borough
end

class Borough::Brooklyn < Borough
end

class Borough::Queens < Borough
end

class Borough::Bronx < Borough
end

class Borough::StatenIsland < Borough
end

class Borough::NewJersey < Borough # I KNOW! NOT A BOROUGH. (Cut me some slack? Naming is hard...)
end

class Borough::NotRecorded < Borough
end

