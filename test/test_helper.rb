require_relative '../env'
require 'minitest/unit'
require 'minitest/autorun'
require 'shoulda-context'
require 'webmock/minitest'

Bundler.require :default, :test

class MiniTest::Unit::TestCase
  include Shoulda::Context::Assertions
  include Shoulda::Context::InstanceMethods
  extend Shoulda::Context::ClassMethods
end
