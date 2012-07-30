module ForwardMachine
  # Connection to controller server
  # Sets up new forwarder to destination host given by client
  class ControllerConnection < EM::Connection
    attr_reader :host, :ports

    # Internal: Initialize new ForwardConnection
    # host - Host on which forwarders (servers) will be created
    # ports - Ports pool from which ports for forwarders
    #         will be taken
    def initialize(host, ports)
      @host = host
      @ports = ports
    end

    # Internal: Receives destination in format "host:port"
    # from client, creates new forwarder, returns forwarder
    # socket address in format "host:port" back to the client
    # and closes the connection.
    def receive_data(data)
      forwarder = Forwarder.new(host, data.strip, ports)
      send_data(forwarder.start)
      close_connection_after_writing
    end
  end
end
