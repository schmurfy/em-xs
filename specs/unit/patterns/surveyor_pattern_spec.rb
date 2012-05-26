require_relative '../../spec_helper'

describe 'Pattern: Surveyor/Respondent' do
  before do
    @ctx = EM::XS::Context.new    
  end
    
  describe 'SURVEYOR/RESPONDENT' do
    before do
      @client_handler = stub()
      
      @server_handler_class = Class.new do
        def initialize(id)
          @id = id
        end
        
        def on_readable(sock, parts)
          p parts
          sock.send_msg("#{parts[0]} : #{@id}")
        end
      end
      
      @server1 = @ctx.socket(XS::RESPONDENT, @server_handler)
      @server2 = @ctx.socket(XS::RESPONDENT, @server_handler)      
      @client = @ctx.socket(XS::SURVEYOR, @client_handler)
    end

    # => CRASH
    # ENDPOINTS.each do |label, endpoint|
    #   should "works with #{label} endpoints" do
    #     @server1.connect(endpoint).should == 0
    #     @server2.connect(endpoint).should == 0
    #     @client.bind(endpoint).should == 0
    #   
    #     @client_handler.expects(:on_readable).with(@server, ['msg : 1'])
    #     @client_handler.expects(:on_readable).with(@server, ['msg : 2'])
    #     @client.send_msg("msg")
    #   
    #   
    #     wait(0.2)
    #   end
    # end
    
  end
  
end

