# em-xs

Crossroads EventMachine library, I used em-zeromq as base but turned it into something slightly
different.

## Prerequesites

You need to have libxs installed, on mac os x you can use homebrew:
```bash
brew install crossroads
```


## Example

I decided to go for a long example to be closer than a "real" application, here it is:  
you can view the source [here](https://github.com/schmurfy/em-xs/blob/master/examples/req_rep.rb) too

```ruby
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
```

