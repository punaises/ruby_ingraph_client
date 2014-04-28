# encoding: utf-8

require 'sequel'
require 'database_cleaner'

require 'simplecov'
SimpleCov.start

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))
require 'ingraphrb'

$LOAD_PATH.unshift(File.expand_path('../support', __FILE__))
require 'ingraphrb_seed'

# test support code
module IngraphRBTest
  module_function

  def db
    @db ||= IngraphRB::DBConnection
      .connect('postgres://postgres@localhost/ingraph-test')
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:sequel, connection: IngraphRBTest.db]
      .strategy = :transaction
    DatabaseCleaner[:sequel, connection: IngraphRBTest.db]
     .clean_with(:truncation)
    DatabaseCleaner[:sequel, connection: IngraphRBTest.db].start
    IngraphRBSeed.new(IngraphRBTest.db).seed!
  end

  config.before(:each) do
    DatabaseCleaner[:sequel, connection: IngraphRBTest.db].start
  end

  config.after(:each) do
    DatabaseCleaner[:sequel, connection: IngraphRBTest.db].clean
  end

  config.after(:suite) do
    DatabaseCleaner[:sequel, connection: IngraphRBTest.db].clean
  end
end
