require_relative '../../spec_helper'

describe 'Pattern: Publisher/Subscriber' do
  before do
    @ctx = EM::XS::Context.new    
  end
  
  describe 'PUB/SUB' do
    before do
      @client_handler = stub()
      @server1_handler = stub()
      @server2_handler = stub()
      @client = @ctx.socket(XS::PUB, @client_handler)
      @server1 = @ctx.socket(XS::SUB, @server1_handler)
      @server2 = @ctx.socket(XS::SUB, @server2_handler)
    end
    
    after do
      @client.send(:detach_and_close)
      @server1.send(:detach_and_close)
      @server2.send(:detach_and_close)
    end
    
    ENDPOINTS.each do |label, endpoint|
      should "works with #{label} endpoints" do
        @client.bind(endpoint).should >= 0
        @server1.connect(endpoint).should >= 0
        @server2.connect(endpoint).should >= 0
        
        @server1.subscribe('')
        @server2.subscribe('')
        
        @server1_handler.expects(:on_readable).with(@server1, ['1: some message'])
        @server2_handler.expects(:on_readable).with(@server2, ['3: some message'])
        
        EM::add_timer(0.1) do
          @client.send_msg("1: some message")
          # @client.send_msg("2: some message")
        end
      
        wait(0.2)
      end  
    end
    
  end
  
end
