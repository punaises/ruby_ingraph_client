# encoding: utf-8

require 'rspec/its'
require 'sequel'
require 'database_cleaner'

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'ruby_ingraph_client'

$LOAD_PATH.unshift(File.expand_path('../support', __FILE__))
require 'ruby_ingraph_client_seed'

# test support code
module RubyIngraphClientTest
  module_function

  def db
    @db ||= RubyIngraphClient::DBConnection
      .connect('postgres://postgres@localhost/ingraph-test')
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:sequel, connection: RubyIngraphClientTest.db]
      .strategy = :transaction
    DatabaseCleaner[:sequel, connection: RubyIngraphClientTest.db]
     .clean_with(:truncation)
    DatabaseCleaner[:sequel, connection: RubyIngraphClientTest.db].start
    RubyIngraphClientSeed.new(RubyIngraphClientTest.db).seed!
  end

  config.before(:each) do
    DatabaseCleaner[:sequel, connection: RubyIngraphClientTest.db].start
  end

  config.after(:each) do
    DatabaseCleaner[:sequel, connection: RubyIngraphClientTest.db].clean
  end

  config.after(:suite) do
    DatabaseCleaner[:sequel, connection: RubyIngraphClientTest.db].clean
  end
end
