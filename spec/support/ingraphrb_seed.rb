# encoding: utf-8

# seed data for tests
class IngraphRBSeed
  attr_reader :hosts

  def initialize(db)
    @db = db
  end

  def seed!
    @hosts = seed_hosts
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
end
