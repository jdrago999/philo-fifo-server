
require 'socket'
require 'byebug'

module Philo
  class Server

    attr_accessor :socket, :data, :client_count, :max_clients, :max_stack_depth, :mutex, :condwait

    def initialize(max_clients:100, max_stack_depth:100)
      self.max_clients = max_clients
      self.max_stack_depth = max_stack_depth
      self.client_count = 0
      self.mutex = Mutex.new
      self.condwait = ConditionVariable.new
      reset_data!
    end

    def start(port:)
      self.socket = TCPServer.open(port.to_i)

      warn 'Server started listenting on port %d' % port
      loop do
        Thread.start(socket.accept) do |client|
          # Only allow <= max clients
          if current_client_count <= max_clients
            # Accept
            warn 'accepted'
            increment_client_count!
            accept_client(client: client)
          else
            # Reject
            warn "Client count too high...rejecting"
            reject_client(client: client)
          end
        end
      end
    end

    private

    def current_client_count
      mutex.synchronize do
        client_count
      end
    end

    def increment_client_count!
      warn '[T] about to increment'
      mutex.synchronize do
        warn '[T] synchronized'
        self.client_count += 1
        warn '[T] incremented'
      end
      warn '[T] finished'
    end

    def decrement_client_count!
      warn '[T] about to decrement'
      mutex.synchronize do
        warn '[T] synchronized'
        self.client_count -= 1
        warn '[T] decremented'
      end
      warn '[T] finished'
    end

    def stack_depth
      mutex.synchronize do
        self.data.length
      end
    end

    def accept_client(client:)
      input = client.recv(1)
      header = input.unpack('C1')[0]
warn "HEADER(#{header})..."
warn "HEADER[0]: (#{header[0]})"
warn "CURRENT CLIENT COUNT: #{current_client_count}"
      case header.to_s.unpack('C1')[0][0]
      when 0
        # Push
        message = nil
        loop do
          depth = stack_depth
          warn 'Stack Depth: %d' % depth
          if depth < max_stack_depth
            warn "RECV(#{header} bytes)"
            message ||= client.recv(header)
            warn "Got '#{message}'..."
            raise "Message too long" unless message.length == header

            warn "ADDING(#{message})"
            mutex.synchronize do
              self.data.unshift(message)
            end
            break
          else
            # wait a bit...
            reject_client(client: client)
            next
          end
        end
        client.write([0b000000].pack("C1"))
      when 1
warn "pop........."
        # Pop
        response_data = nil
        loop do
          depth = stack_depth
          warn "DEPTH(#{depth})"
          if depth > 0
            response_data = mutex.synchronize do
              self.data.shift
            end
            break
          else
            sleep 0.1
            next
          end
        end
warn "POP(#{response_data})"
        begin
          client.send([response_data.length, *response_data.bytes].pack('C*'), response_data.length)
        rescue => e
          warn "ERROR: #{e} -- #{e.backtrace.join("\n")}"
        end
warn 'here1'
warn 'here2'
      end

      client.close
      decrement_client_count!
    end

    def reject_client(client:)
      client.recvmsg(128)
      warn "REJECT(#{client})"
      client.write(['\0'].pack('C1'))
    end

    def reset_data!
      self.data = []
    end
  end
end
