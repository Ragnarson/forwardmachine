require 'spec_helper'

describe ForwardMachine do
  around do |example|
    EM.run { forwardmachine; example.run }
  end

  it "should listen on control port and return forwarder port number" do
    socket = EM.connect('localhost', 27000, FakeClient, 'localhost:30000')
    socket.onmessage { |m| m.should == 'localhost:23200' }
    socket.onclose { EM.stop }
  end

  it "should forward connection to destination host and port" do
    EM.start_server('localhost', 30000, FakeServer)
    control_socket = EM.connect('localhost', 27000, FakeClient, 'localhost:30000')
    control_socket.onmessage do |forward|
      host, port = forward.split(':')
      socket = EM.connect(host, port, FakeClient, 'hey')
      socket.onmessage { |m| m.should == '> hey' }
      EM.add_timer(0.1) do
        socket.send_data('close')
        socket.onmessage { |m| m.should == '> closed'; EM.stop }
      end
    end
  end

  it "should close forwarded when destination host disconnected" do
    EM.start_server('localhost', 30000, FakeServer)
    control_socket = EM.connect('localhost', 27000, FakeClient, 'localhost:30000')
    control_socket.onmessage do |forward|
      host, port = forward.split(':')
      EM.connect(host, port, FakeClient, 'close') do |c|
        c.onmessage { |m| m.should == '> closed' }
        c.should_not be_error
        c.onclose do
          EM.connect('localhost', port, FakeClient) do |c|
            c.should be_error
            EM.stop
          end
        end
      end
    end
  end

  it "should not close forwarder when any connection is ongoing" do
    EM.start_server('localhost', 30000, FakeServer)
    control_socket = EM.connect('localhost', 27000, FakeClient, 'localhost:30000')
    control_socket.onmessage do |forward|
      host, port = forward.split(':')
      EM.connect(host, port, FakeClient, 'first') do |first|
        first.onmessage { |m| m.should == '> first' }
        second = EM.connect(host, port, FakeClient, 'second') do |second|
                   second.onmessage { |m| m.should == '> second' }
                 end

        EM.add_timer(0.1) { first.close_connection }
        EM.add_timer(0.2) do
          # second still operational, after first one is closed
          second.send_data('close')
          second.onmessage { |m| m.should == '> closed' }
          second.onclose { EM.stop }
        end
      end
    end
  end
end
