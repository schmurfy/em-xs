module EventMachine
  module XS
        
    class Context
      READABLES = [ ::XS::SUB, ::XS::PULL, ::XS::ROUTER, ::XS::DEALER, ::XS::REP, ::XS::REQ, ::XS::RESPONDENT, ::XS::SURVEYOR ]
      WRITABLES = [ ::XS::PUB, ::XS::PUSH, ::XS::ROUTER, ::XS::DEALER, ::XS::REP, ::XS::REQ, ::XS::RESPONDENT, ::XS::SURVEYOR ]
      
      def initialize(io_threads = nil)
        @context = ::XS::Context.new
        if io_threads
          rc = @context.setctxopt(::XS::IO_THREADS, io_threads)
          unless ::XS::Util.resultcode_ok?(rc)
            ::XS::raise_error('xs_setctxopt', rc)
          end
        end
      end
      
      
      ##
      # Create a socket in this context.
      # 
      # @param [Integer] socket_type One of ZMQ::REQ, ZMQ::REP, ZMQ::PULL, ZMQ::PUSH,
      #   ZMQ::ROUTER, ZMQ::DEALER
      # 
      # @param [Object] handler an object which respond to on_readable(socket, parts)
      #   and can respond to on_writeable(socket)
      # 
      def socket(socket_type, handler = nil)
        klass = Socket.get_class_for_type(socket_type)
        unless klass
          raise "Unsupported socket type: #{socket_type}"
        end
        
        socket = @context.socket(socket_type)
        
        fd = []
        rc = socket.getsockopt(::XS::FD, fd)
        unless ::XS::Util.resultcode_ok?(rc)
          raise "Unable to get socket FD: #{::XS::Util.error_string}"
        end
        
        EM.watch(fd[0], klass, socket, socket_type, handler).tap do |s|
          s.register_readable if READABLES.include?(socket_type)
          s.register_writable if WRITABLES.include?(socket_type)
          
          yield(s) if block_given?
        end
      end  
    end
    
    
  end
end
