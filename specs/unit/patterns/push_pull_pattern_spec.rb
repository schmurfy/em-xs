require_relative '../../spec_helper'

describe 'Pattern: Push/Pull' do
  before do
    @ctx = EM::XS::Context.new    
  end
    
  describe 'PUSH/PULL' do
    before do
      @client_handler = stub()
      @server_handler = stub()
      @client = @ctx.socket(XS::PUSH, @client_handler)
      @server = @ctx.socket(XS::PULL, @server_handler)
    end
    
    after do
      @client.send(:detach_and_close)
      @server.send(:detach_and_close)
    end
    
    ENDPOINTS.each do |label, endpoint|
      should "works with #{label} endpoints" do
        @server.bind(endpoint).should >= 0
        @client.connect(endpoint).should >= 0
      
        @server_handler.expects(:on_readable).with(@server, ['some message'])
        @client.send_msg("some message")
      
        wait(0.1)
      end  
    end
    
  end
  
end
