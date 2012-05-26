require_relative '../../spec_helper'

describe 'Pattern: Request/Reply' do
  before do
    @ctx = EM::XS::Context.new    
  end
    
  describe 'REQ/REP' do
    before do
      @client_handler = stub()
      @server_handler = stub()
      @client = @ctx.socket(XS::REQ, @client_handler)
      @server = @ctx.socket(XS::REP, @server_handler)
    end
    
    after do
      @client.send(:detach_and_close)
      @server.send(:detach_and_close)
    end
    
    ENDPOINTS.each do |label, endpoint|
      should "works with #{label} endpoints" do
        @server.bind(endpoint).should >= 0
        @client.connect(endpoint).should >= 0
      
        @server_handler.expects(:on_readable).with(@server, ['hello server'])
        @client.send_msg("hello server")
      
        EM::add_timer(0.1) do
          @client_handler.expects(:on_readable).with(@client, ['yo !'])
          @server.send_msg("yo !")
        end
      
        wait(0.3)
      end  
    end
    
  end
  
end

