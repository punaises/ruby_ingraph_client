# encoding: utf-8

module IngraphRB
  # interface to fetch performance data
  class PerformanceData
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

    attr_reader :plot_ids, :host_name, :service_name

    def initialize(db, hosts, service_name, opts = {})
      @db = db
      @hosts = normalize_hosts(hosts)
      @service_name = service_name
      @timezone = opts[:timezone]
      @limit = opts[:limit]
      @offset = opts[:offset] || 0
      @timeframe = opts[:timeframe] || Timeframe.smallest
      @x = opts[:x_key] || :x
      @y = opts[:y_key] || :y
      find_plot_ids
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
      sql << "SELECT plot_id, (timestamp + #{@offset}) as time, "
      sql << 'timestamp, min as value '
      sql << "FROM datapoint WHERE plot_id in ? "
      sql << self.class.sql_for_time_limit(@limit)
      sql << "AND timeframe_id = #{@timeframe.id} "
      sql << ' ORDER BY timestamp ASC'
      sql
    end

    def fetch
      @db.fetch(sql, @plot_host.keys).all.map do |row|
        row[:host_name] = @plot_host[row[:plot_id]]
        row
      end
    end

    private

    def normalize_hosts(hosts)
      if hosts.is_a? Array
        if hosts.all? { |h| h.is_a? Host }
          hosts
        else
          hosts.map { |h| Host.matching(@db, h) }.flatten
        end
      else
        Host.matching(@db, hosts)
      end
    end

    def find_plot_ids
      sql = <<-SQL
        select plot.id as id, host.name as host_name from plot
        inner join hostservice on plot.hostservice_id = hostservice.id
        inner join service on hostservice.service_id = service.id
        inner join host on hostservice.host_id = host.id
        where service.name = ? and host.id in ?
      SQL
      res = @db.fetch(sql, @service_name, @hosts.map { |h| h.id })
      @plot_host = {}
      res.each do |row|
        @plot_host[row[:id]] = row[:host_name]
      end
      puts @plot_host.inspect
    end
  end
end
