module EventMachine
  module XS
    module Sockets
      
      class Publisher < Socket
      
      end
    
      class Subscriber < Socket
      
        def subscribe(what = '')
          raise "only valid on sub socket type (was #{@socket.name})" unless @socket.name == 'SUB'
          @socket.setsockopt(::XS::SUBSCRIBE, what)
        end
      
        def unsubscribe(what)
          raise "only valid on sub socket type (was #{@socket.name})" unless @socket.name == 'SUB'
          @socket.setsockopt(::XS::UNSUBSCRIBE, what)
        end
      
      end
      
    end
  end
end
