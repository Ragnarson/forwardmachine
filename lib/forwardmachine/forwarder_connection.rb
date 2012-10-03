require 'socket'

module ForwardMachine
  # Connection between client and forwarder server.
  class ForwarderConnection < EM::Connection
    def initialize(destination, forwarder)
      @destination = destination
      @destination_host, @destination_port = destination.split(":")
      @forwarder = forwarder
      # Number of seconds server will wait for TCP connection in pending state
      self.pending_connect_timeout = 60
      # Number of seconds server connection remain open waiting for data
      self.comm_inactivity_timeout = 60 * 30
    end

    # Internal: After client is connected to forwarder, open connection
    # to destination host and port
    def post_init
      logger.info("Client #{peer} connected to forwarder #{@forwarder}")
      EM.connect(@destination_host, @destination_port,
        ForwardedConnection, self)
    rescue RuntimeError => e
      logger.error("Client #{peer} on #{@forwarder} couldn't be connected with destination")
      close_connection
    end

    # Internal: After forwarder destination disconnected
    # terminate forwarder connection
    def proxy_target_unbound
      logger.info("Destination disconnected from forwarder #{@forwarder}")
      close_connection
    end

    # Internal: After client disconnects from forwarder
    # notify forwarder server about it.
    def unbind
      logger.info("Client #{peer} disconnected from forwarder #{@forwarder}")
      @forwarder.forwarder_connection_closed
    end

    private

    def peer
      @peer ||= begin
                  port, ip = Socket.unpack_sockaddr_in(get_peername)
                  "#{ip}:#{port}"
                end
    end
  end
end
