require 'rubygems'
require 'bundler/setup'

require 'em-xs'

ENDPOINT = 'inproc://socket'


class Client
  def initialize(context, endpoint, delay)
    @context = context
    @endpoint = endpoint
    @delay = delay
    
    @socket = @context.socket(XS::REQ, self)
    if @socket.connect(endpoint) == -1
      raise XS::Util.error_string
    end
    
    send_query
  end
  
  def on_readable(s, parts)
    puts "Client received: #{parts}"
    send_query
  end
  
private
  def send_query
    EM::add_timer(@delay) do
      @socket.send_msg("ping")
    end
  end
  
end


class EchoServer
  def initialize(context, endpoint)
    @context = context
    @socket = @context.socket(XS::REP, self)
    if @socket.bind(endpoint) == -1
      raise XS::Util.error_string
    end
  end
  
  def on_readable(s, parts)
    puts "Server received: #{parts}"
    s.send_msg("re: #{parts[0]}")
  end
  
end


EM::run do
  context = EM::XS::Context.new
  
  EchoServer.new(context, ENDPOINT)
  Client.new(context, ENDPOINT, 1)
end
