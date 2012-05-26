module EventMachine
  module XS
    class Socket < EventMachine::Connection
      attr_accessor :on_readable, :on_writable, :handler
      attr_reader   :socket, :socket_type      
      
      def initialize(socket, socket_type, handler)
        @socket      = socket
        @socket_type = socket_type
        @handler     = handler
      end
      
      def self.map_sockopt(opt, name, writer = true)
        define_method(name){ getsockopt(opt) }
        if writer
          define_method("#{name}="){|val| @socket.setsockopt(opt, val) }
        end
      end
      
      map_sockopt(::XS::AFFINITY, :affinity)
      map_sockopt(::XS::IDENTITY, :identity)
      map_sockopt(::XS::SNDBUF, :sndbuf)
      map_sockopt(::XS::RCVBUF, :rcvbuf)
      map_sockopt(::XS::TYPE, :type, false)
      map_sockopt(::XS::LINGER, :linger)
      map_sockopt(::XS::RECONNECT_IVL, :reconnect_interval)
      map_sockopt(::XS::RECONNECT_IVL_MAX, :max_reconnect_interval)
      map_sockopt(::XS::BACKLOG, :backlog)
      map_sockopt(::XS::MAXMSGSIZE, :max_msgsize)
      map_sockopt(::XS::SNDHWM, :snd_hwm)
      map_sockopt(::XS::RCVHWM, :rcv_hwm)
      map_sockopt(::XS::RCVTIMEO, :rcv_timeout)
      map_sockopt(::XS::SNDTIMEO, :snd_timeout)
      map_sockopt(::XS::IPV4ONLY, :ipv4only)
      map_sockopt(::XS::KEEPALIVE, :keepalive)
      
      
      # pgm
      map_sockopt(::XS::RATE, :rate)
      map_sockopt(::XS::MULTICAST_HOPS, :max_multicast_hops)
      map_sockopt(::XS::RECOVERY_IVL, :recovery_interval)
      
      # User method
      def bind(address)
        @socket.bind(address)
      end
      
      def connect(address)
        @socket.connect(address)
      end
      
      # send a non blocking message
      # parts:  if only one argument is given a signle part message is sent
      #         if more than one arguments is given a multipart message is sent
      #
      # return: true is message was queued, false otherwise
      #
      def send_msg(*parts)
        parts = Array(parts[0]) if parts.size == 0
        sent = true
        
        # multipart
        parts[0...-1].each do |msg|
          sent = @socket.send_string(msg, ::XS::DONTWAIT | ::XS::SNDMORE)
          if sent == false
            break
          end
        end
        
        if sent
          # all the previous parts were queued, send
          # the last one
          ret = @socket.send_string(parts[-1], ::XS::DONTWAIT)
          if ret < 0
            raise "Unable to send message: #{::XS::Util.error_string}"
          end
        else
          # error while sending the previous parts
          # register the socket for writability
          self.notify_writable = true
          sent = false
        end
        
        notify_readable()
        
        sent
      end
      
      def getsockopt(opt)
        ret = []
        rc = @socket.getsockopt(opt, ret)
        unless ::XS::Util.resultcode_ok?(rc)
          ::XS::Util.raise_error('getsockopt', rc)
        end

        (ret.size == 1) ? ret[0] : ret    
      end
      
      def setsockopt(opt, value)
        @socket.setsockopt(opt, value)
      end
      
      # cleanup when ending loop
      def unbind
        detach_and_close
      end
      
      # Make this socket available for reads
      def register_readable
        if readable?
          notify_readable
        end
        
        # Subscribe to EM read notifications
        self.notify_readable = true
      end

      # Trigger on_readable when socket is readable
      def register_writable
        # Subscribe to EM write notifications
        self.notify_writable = true
      end

      def notify_readable
        # Not sure if this is actually necessary. I suppose it prevents us
        # from having to to instantiate a XS::Message unnecessarily.
        # I'm leaving this is because its in the docs, but it could probably
        # be taken out.
        return unless readable?
         
        loop do
          msg_parts = []
          msg       = get_message
          if msg
            msg_parts << msg
            while @socket.more_parts?
              msg = get_message
              if msg
                msg_parts << msg
              else
                raise "Multi-part message missing a message!"
              end
            end
            
            @handler.on_readable(self, msg_parts)
          else
            break
          end
        end
      end
      
      def notify_writable
        return unless writable?
        
        # once a writable event is successfully received the socket
        # should be accepting messages again so stop triggering
        # write events
        self.notify_writable = false
        
        if @handler.respond_to?(:on_writable)
          @handler.on_writable(self)
        end
      end
      def readable?
        (getsockopt(::XS::EVENTS) & ::XS::POLLIN) == ::XS::POLLIN
      end
      
      def writable?
        true
        # return false
        # (getsockopt(::XS::EVENTS) & ::XS::POLLOUT) == ::XS::POLLOUT
      end
      
      
    private
    
      # internal methods
      def get_message
        msg = ""
        msg_recvd = @socket.recv_string(msg, ::XS::DONTWAIT)
        msg_recvd != -1 ? msg : nil
      end
      
      # Detaches the socket from the EM loop,
      # then closes the socket
      def detach_and_close
        detach
        @socket.close
      end
    end
  end
end
