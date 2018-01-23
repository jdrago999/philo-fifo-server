
SERVER_ENV = ENV.fetch('SERVER_ENV', 'development')

require 'bundler'
Bundler.require(:default, SERVER_ENV)

