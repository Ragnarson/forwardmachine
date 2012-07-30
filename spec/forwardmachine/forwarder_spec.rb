require 'spec_helper'

describe ForwardMachine::Forwarder do
  around do |example|
    EM.run do
      ports_pool = ForwardMachine::PortsPool.new(23000..23010)
      @forwarder = ForwardMachine::Forwarder.new('localhost',
        'localhost:30000', ports_pool)
      example.run
    end
  end

  describe "#start" do
    before do
      EM.start_server('localhost', 30000, FakeServer)
      EM.run do
        @forward = @forwarder.start
        @host, @port = @forward.split(':')
      end
    end

    it "should create new forwarder server and return port" do
      EM.connect(@host, @port, FakeClient, 'hey') do |socket|
        socket.onmessage do |message|
          socket.send_data('close')
          socket.onmessage { |m| m.should == '> closed' }
          socket.onclose { EM.stop }
        end
      end
    end

    it "should count connections" do
      EM.connect(@host, @port, FakeClient, 'hey') do |socket|
        socket.onmessage do |message|
          @forwarder.connections.should == 1
          socket.send_data('close')
          socket.onmessage { EM.stop }
        end
      end
    end
  end

  context "forwarder server not used for FIRST_USE_TIMEOUT seconds" do
    it "should close forwarder" do
      ForwardMachine::Forwarder.send :remove_const, :FIRST_USE_TIMEOUT
      ForwardMachine::Forwarder::FIRST_USE_TIMEOUT = 0.05
      EM.start_server('localhost', 30000, FakeServer)
      host, port = nil, nil
      EM.run do
        host, port = @forwarder.start.split(':')
      end
      EM.add_timer(0.1) do
        socket = EM.connect(host, port, FakeClient, 'hey')
        socket.onerror { socket.should be_error; EM.stop }
        socket.onmessage { raise }
      end
    end
  end
end
