require 'forwardmachine'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

def forwardmachine
  controller = ForwardMachine::Controller.new(
    host: "localhost", port: 27000)
  controller.run
end

class FakeServer < EM::Connection
  def receive_data(data)
    if data == 'close'
      send_data('> closed')
      close_connection_after_writing
    else
      send_data("> #{data}")
    end
  end
end

class FakeClient < EM::Connection
  def onclose(&block); @onclose = block; end
  def onmessage(&block); @onmessage = block; end
  def onerror(&block); @onerror = block; end

  def initialize(message = nil)
    @message = message
  end

  def post_init
    send_data(@message) if @message
  end

  def receive_data(data)
    @onmessage.call(data) if @onmessage
  end

  def unbind
    @onerror.call if error? and @onerror
    @onclose.call if @onclose
  end
end
