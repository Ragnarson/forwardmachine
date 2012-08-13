module ForwardMachine
  # Server which accepts traffic on available port taken from
  # ports pool. Each connection is handled by ForwarderConnection object
  class Forwarder
    # How long server will be open, waiting for the first connetion.
    FIRST_USE_TIMEOUT = 60

    attr_reader :host, :destination, :ports_pool, :port, :connections

    # Public: Initialize new Forwarder server
    #
    # host        - Host as String on which server will listen
    # destination - Destination socket as String where traffic will
    #               be forwarded (in format host:port)
    # ports       - PortsPool object with ports numbers from which port
    #               for forwarder will be taken
    def initialize(host, destination, ports_pool)
      @host = host
      @ports_pool = ports_pool
      @port = ports_pool.reserve
      @destination = destination
      @connections = 0
    end

    # Public: Start forwarding server on given host and port taken from PortsPool.
    # Returns: Socket address of the server in format "host:port" as String
    def start
      @server = EM.start_server(host, port, ForwarderConnection, destination, self) {
        @connections += 1
        @inactivity_timer.cancel
      }
      @inactivity_timer = EM::PeriodicTimer.new(FIRST_USE_TIMEOUT) { stop }
      logger.info("Started forwarder #{socket_address} to #{destination}")
      socket_address
    end

    # Internal: Callback which is called from connection to Forwarder when
    # client disconnects. Stops Forwarder server if it's not used by any
    # connection.
    def forwarder_connection_closed
      stop if (@connections -= 1).zero?
    end

    # Public: Fowarder socket address
    # Returns: String with host and port on which forwarder listens
    def socket_address
      "#{host}:#{port}"
    end

    def to_s
      socket_address
    end

    private

    def stop
      logger.info("Stopped forwarder #{socket_address} to #{destination}")
      @inactivity_timer.cancel
      EM.stop_server(@server)
      ports_pool.release(port)
    end
  end
end
