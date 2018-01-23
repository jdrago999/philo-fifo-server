
SERVER_ENV = ENV.fetch('SERVER_ENV', 'development')

require 'bundler'
Bundler.require(:default, SERVER_ENV)

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'philo/server'

server = Philo::Server.new
server.start(port: 8080)

warn 'Server exiting...'
