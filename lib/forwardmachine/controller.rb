module ForwardMachine
  # Server which listens for forward requests.
  # It should be run on internal address, like localhost
  # because it doesn't have any authentication.
  # Each connection is handled by ControllerConnection
  class Controller
    def initialize(options = {})
      @host = options[:host] || "localhost"
      @port = options[:port] || 8899
      @forwarder_host = options[:forwarder_host] || @host
      @ports = PortsPool.new(options[:ports_range] || (23200..23500))
    end

    def run
      EM.run {
        EM.error_handler { |error|
          logger.error(error.message)
          logger.error(error.backtrace.join("\n"))
        }
        EM.start_server(@host, @port, ControllerConnection,
          @forwarder_host, @ports)
        logger.info("Started controller at #{@host}:#{@port}")
      }
    end
  end
end
