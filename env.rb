require 'rubygems'
require 'bundler'
Bundler.setup(:default)
Bundler.require(:default)

# Require every .rb file under config
Dir["config/*.rb"].each { |file| require_relative file }

# Require every .rb file under lib
Dir["lib/*.rb"].each { |file| require_relative file }
