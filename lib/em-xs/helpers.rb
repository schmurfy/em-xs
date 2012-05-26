module EventMachine
  module XS
    
    class Socket
      TYPES_MAPPING = {
        ::XS::REQ         => Sockets::Request,
        ::XS::REP         => Sockets::Reply,
        ::XS::ROUTER      => Sockets::Router,
        ::XS::DEALER      => Sockets::Dealer,
        ::XS::SUB         => Sockets::Subscriber,
        ::XS::PUB         => Sockets::Publisher,
        ::XS::SURVEYOR    => Sockets::Surveyor,
        ::XS::RESPONDENT  => Sockets::Respondent,
        ::XS::PUSH        => Sockets::Push,
        ::XS::PULL        => Sockets::Pull
      }.freeze
      
      def self.get_class_for_type(socket_type)
        TYPES_MAPPING[socket_type]
      end
    end
    
  end  
end
