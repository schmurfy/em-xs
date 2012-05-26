require_relative '../spec_helper'

require 'em-xs/context'

describe 'Context' do
  before do
    @ctx = EM::XS::Context.new
  end
  
  it 'can create socket' do
    s = @ctx.socket(XS::ROUTER)
    s.class.should == EM::XS::Sockets::Router
    s.socket_type.should == XS::ROUTER
  end
  
  should 'set io threads count' do
    proc{
      EM::XS::Context.new(2)
    }.should.not.raise
  end
  
  should 'raise an error if socket type is unsupported' do
    err = proc {
      @ctx.socket(99)
    }.should.raise(RuntimeError)
    
    err.message.should == "Unsupported socket type: 99"
    
  end
  
end

