require "eventmachine"
require "logger"
require "em-logger"
require "forwardmachine/version"
require "forwardmachine/ports_pool"
require "forwardmachine/controller"
require "forwardmachine/controller_connection"
require "forwardmachine/forwarder"
require "forwardmachine/forwarder_connection"
require "forwardmachine/forwarded_connection"

module ForwardMachine
  class << self
    attr_accessor :logger_path
  end
end

def logger
  @logger ||= begin
    logger = Logger.new(ForwardMachine.logger_path)
    EM::Logger.new(logger)
  end
end
