# encoding: utf-8

require 'sequel'

module IngraphRB
  # database connection helper
  module DBConnection
    module_function

    def connect(opts = {})
      Sequel.connect(connection_string(opts), opts[:db_opts])
    end

    def connection_string(opts = {})
      return opts[:connection_string] if opts[:connection_string]

      adapter = opts[:adapter] || 'postgres'
      user = opts[:user] || adapter
      host = opts[:host] || 'localhost'
      database = opts[:database] || 'ingraph'
      "#{adatpter}://#{user}@#{host}/#{database}"
    end
  end
end
