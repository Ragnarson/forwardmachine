require 'set'

module ForwardMachine
  # PortsPool from which ports will be taken for creating
  # port forwards.
  class PortsPool < SortedSet
    # Public: Initialize pool with range of ports
    def initialize(range)
      super(range.to_a)
    end

    # Public: Reserve one port
    # Returns: Port number as Integer
    #          nil if no port is available
    def reserve
      delete(elem = first)
      elem
    end

    # Public: Release given port, puts it back in the pool
    # makes it available for later reservation
    def release(port)
      self << port
    end
  end
end
