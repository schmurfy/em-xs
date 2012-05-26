module EventMachine
  module XS
    module Sockets
      
      class Surveyor < Socket
        map_sockopt(::XS::SURVEY_TIMEOUT, :survey_timeout)
      
      end
    
      class Respondent < Surveyor
      end
      
    end
  end
end
