require 'rubygems'
require 'bundler'
Bundler.setup(:default)
Bundler.require(:default)

Dir["config/*.rb"].each {|file| require_relative "#{file}" }
