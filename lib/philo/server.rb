
require 'socket'

module Philo
  class Server

    attr_accessor :socket, :data, :clients, :max_clients

    def initialize(max_clients:100)
      self.max_clients = max_clients
      self.clients = []
      reset_data!
    end

    def start(port:)
      self.socket = TCPServer.open(port.to_i)

      warn 'Server started listenting on port %d' % port
      loop do
        Thread.start(socket.accept) do |client|
          # Only allow <= max clients
          if clients.length <= max_clients
            # Accept
            warn 'accepted'
            accept_client(client: client)
          else
            # Reject

          end
        end
      end
    end

    private

    def accept_client(client:)
      header = client.recv(1).unpack("C1")[0]
      warn "HEADER: '#{header}'"
    end

    def reject_client(client:)
    end

    def reset_data!
      self.data = []
    end
  end
end
