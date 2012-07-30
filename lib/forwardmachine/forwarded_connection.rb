module ForwardMachine
  # Connection between forwarder machine
  # and a service on destination host
  class ForwardedConnection < EM::Connection
    def initialize(forwarder_connection)
      @forwarder_connection = forwarder_connection
    end

    # Internal: Sets both ways proxy between forwarder server
    # and client (on destination host)
    def post_init
      EM.enable_proxy(self, @forwarder_connection)
      EM.enable_proxy(@forwarder_connection, self)
    end
  end
end
