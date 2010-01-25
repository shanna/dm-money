root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

require File.join(root, 'gems', 'environment')
Bundler.require_env(:development)
require 'test/unit'

begin
  require 'shoulda'
rescue LoadError
  warn 'Shoulda is required for testing. Use gem bundle to install development gems.'
  exit 1
end

$:.unshift File.join(root, 'lib'), File.dirname(__FILE__)
require 'dm-money'

DataMapper.setup(:default, :adapter => 'in_memory', :database => 'dm_money_test')
class Test::Unit::TestCase
end
