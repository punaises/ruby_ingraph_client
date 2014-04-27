# encoding: utf-8

require 'sequel'

module IngraphRB
  # represents a timeframe for keeping data in the database
  class Timeframe
    def self.populate(db)
      @timeframes = {}
      db.fetch('select * from timeframe').map do |row|
        @timeframes[row[:interval]] = new(row)
      end

      @smallest_interval = @timeframes.reduce(nil) do |a, e|
        [a, e.interval].compact.min
      end
    end

    def self.smallest
      self[@smallest_interval]
    end

    def self.[](interval)
      @timeframes[interval]
    end

    attr_reader :id, :interval, :retention_period, :active

    def initialize(row = {})
      @id = row[:id]
      @interval = row[:interval]
      @retention_period = row[:retention_period]
      @active = row[:active]
    end
  end
end
