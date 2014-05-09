# encoding: utf-8

# seed data for tests
class IngraphRBSeed
  def initialize(db)
    @db = db
  end

  def seed!
    seed_hosts
    seed_timeframes
  end

  private

  def seed_hosts
    data = %w[server1 server2 server3 worker1 worker2 backend]
      .each_with_index.map do |name, ix|
      "(#{ix + 1}, '#{name}')"
    end.join(',')
    @db.fetch("INSERT INTO host (id, name) VALUES #{data}").all
    @db.fetch('select * from host').all
  end

  def seed_timeframes
    days = 24 * 60 * 60
    [
     { id: 1, interval: 300, retention_period: 1 * days },
     { id: 2, interval: 1800, retention_period: 30 * days },
     { id: 3, interval: 3600, retention_period: 60 * days }
    ].each do |timeframe|
      @db.fetch("INSERT INTO timeframe " +
                "(id, interval, retention_period, active) " +
                "VALUES (#{timeframe[:id]}, #{timeframe[:interval]}, " +
                "#{timeframe[:retention_period]}, true)").all
    end
  end
end
