# encoding: utf-8

module IngraphRB
  # interface to fetch performance data
  class PerformanceData
    def self.plot_id(db, host_name, service_name)
      sql = <<-SQL
        select plot.id as id from plot
        inner join hostservice on plot.hostservice_id = hostservice.id
        inner join host on hostservice.host_id = host.id
        inner join service on hostservice.service_id = service.id
        where host.name = ? and service.name = ?
      SQL
      res = db.fetch(sql, host_name, service_name)
      fail "Could not find #{service_name} for host #{host_name}" unless res
      res.first[:id]
    end

    def self.sql_for_time_limit(limit)
      return '' unless limit

      case limit
      when String
        " AND to_timestamp(timestamp) > now() - interval '#{limit}' "
      when Array
        " AND to_timestamp(timestamp) >= now() - interval '#{limit[0]}'" +
          " AND to_timestamp(timestamp) < now() - interval '#{limit[1]}' "
      end
    end

    attr_reader :plot_id, :host_name, :service_name

    def initialize(db, host_name, service_name, opts = {})
      @db = db
      @host_name = host_name
      @service_name = service_name
      @timezone = opts[:timezone]
      @limit = opts[:limit]
      @offset = opts[:offset] || 0
      @timeframe = opts[:timeframe] || Timeframe.smallest
      @x = opts[:x_key] || :x
      @y = opts[:y_key] || :y
      @plot_id = self.class.plot_id(db, host_name, service_name)
    end

    def limit_to(span)
      @limit = span
      self
    end

    def with_timeframe(timeframe)
      @timeframe = timeframe
      self
    end

    def sql
      sql = ''
      sql << "SET TIME ZONE '#{@timezone}'; " if @timezone
      sql << "SELECT (timestamp + #{@offset}) as time, timestamp, min as value "
      sql << "FROM datapoint WHERE plot_id = #{@plot_id} "
      sql << self.class.sql_for_time_limit(@limit)
      sql << "AND timeframe_id = #{@timeframe.id} "
      sql << ' ORDER BY timestamp ASC'
      sql
    end

    def fetch
      @db.fetch(sql).all
    end
  end
end
