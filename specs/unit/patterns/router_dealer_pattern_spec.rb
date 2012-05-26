require_relative '../../spec_helper'

describe 'Pattern: Router/Dealer' do
  before do
    @ctx = EM::XS::Context.new    
  end

  describe 'XREQ/XREP' do
    before do
      @client_handler = stub()
      
      @server_handler = Class.new do
        def on_readable(sock, parts)
          id, *parts = parts
          sock.send_msg(id, "re: #{parts[0]}")
        end
      end.new
      
      @client = @ctx.socket(XS::XREQ, @client_handler)
      @server = @ctx.socket(XS::XREP, @server_handler)
    end
    
    after do
      @client.send(:detach_and_close)
      @server.send(:detach_and_close)
    end
    
    ENDPOINTS.each do |label, endpoint|
      should "works with #{label} endpoints" do
        @server.bind(endpoint).should >= 0        
        @client.connect(endpoint).should >= 0
      
        @client_handler.expects(:on_readable).with(@client, ['re: first question'])
        @client.send_msg("first question")
      
        @client_handler.expects(:on_readable).with(@client, ['re: second question'])
        @client.send_msg("second question")
      
        wait(0.2)
      end
    end
    
  end
  
end
