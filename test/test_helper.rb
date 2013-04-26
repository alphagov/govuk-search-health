require_relative '../env'
require 'minitest/unit'
require 'minitest/autorun'
require 'shoulda-context'

Bundler.require :default, :test

Dir["lib/*.rb"].each {|file| require_relative "../#{file}" }

class MiniTest::Unit::TestCase
  include Shoulda::Context::Assertions
  include Shoulda::Context::InstanceMethods
  extend Shoulda::Context::ClassMethods
end
