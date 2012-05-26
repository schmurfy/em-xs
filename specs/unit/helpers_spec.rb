require_relative '../spec_helper'

require 'em-xs'

describe 'Socket' do

  should 'return correct types' do
    EM::XS::Socket.get_class_for_type(XS::REQ).should == EM::XS::Sockets::Request
    EM::XS::Socket.get_class_for_type(XS::REP).should == EM::XS::Sockets::Reply
    
    EM::XS::Socket.get_class_for_type(XS::ROUTER).should == EM::XS::Sockets::Router
    EM::XS::Socket.get_class_for_type(XS::DEALER).should == EM::XS::Sockets::Dealer
    
    EM::XS::Socket.get_class_for_type(XS::PUB).should == EM::XS::Sockets::Publisher
    EM::XS::Socket.get_class_for_type(XS::SUB).should == EM::XS::Sockets::Subscriber
    
    EM::XS::Socket.get_class_for_type(XS::SURVEYOR).should == EM::XS::Sockets::Surveyor
    EM::XS::Socket.get_class_for_type(XS::RESPONDENT).should == EM::XS::Sockets::Respondent
    
    EM::XS::Socket.get_class_for_type(XS::PUSH).should == EM::XS::Sockets::Push
    EM::XS::Socket.get_class_for_type(XS::PULL).should == EM::XS::Sockets::Pull
  end

end
