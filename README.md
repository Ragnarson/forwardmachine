# ForwardMachine

Port forwarding service configurable in runtime.

# How does it work?

ForwardMachine listens on TCP port for forward requests.
These requests are simple, they consist of host:port, e.g. host.example.com:3000
As response, host and port where forwarding has been set up is returned.

## Installation

    $ gem install forwardmachine

## Usage

1. Start forwarder for host proxy.example.com

    $ forwardmachine --forwarder-host proxy.example.com --ports-range 8000..9000

2. Control server by default will listen on localhost:8899.
Connect to it and create a new forwarder (here we use nc tool).
Below we have created two ports forwards.

    $ nc localhost 8899
    internal1.example.com:7777
    proxy.example.com:8000

    $ nc localhost 8899
    internal2.example.com:9999
    proxy.example.com:8001

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
