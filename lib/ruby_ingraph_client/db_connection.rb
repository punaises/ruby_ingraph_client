# encoding: utf-8

require 'sequel'

module RubyIngraphClient
  # database connection helper
  module DBConnection
    module_function

    def connect(opts = {})
      Sequel.connect(connection_string(opts), db_opts(opts))
    end

    private

    module_function

    def db_opts(opts = {})
      return {} if opts.is_a? String
      opts[:db_opts]
    end

    def connection_string(opts = {})
      return opts if opts.is_a? String
      return opts[:connection_string] if opts[:connection_string]

      adapter = opts[:adapter] || 'postgres'
      user = opts[:user] || adapter
      host = opts[:host] || 'localhost'
      database = opts[:database] || 'ingraph'
      "#{adatpter}://#{user}@#{host}/#{database}"
    end
  end
end
