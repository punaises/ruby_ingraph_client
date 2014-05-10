# RubyIngraphClient

Ruby client for querying performance data from an
[inGraph](https://www.netways.org/projects/ingraph) database.  Useful
for analyzing system data or creating displays with tools like
[dashing](http://shopify.github.io/dashing/).

Usage example:

```ruby
require 'sequel'
require 'ruby_ingraph_client'

db = Sequel.connect('postgres://postgres@localhost/ingraph')

# fetch cpu usage statistics for servers matching the pattern web_server%
#  (e.g., web_server1, web_server2, web_server3,...)
perfdata = RubyIngraphClient::PerformanceData.new(db, 'web_server%', 'check_cpu_usage')

perfdata.with_timespan(['2 days ago', '1 day ago']).fetch.each do |datum|
  puts datum.inspect
end
```

## PerformanceData

To fetch performance data, first create a PerformanceData object by
calling `RubyIngraphClient::PerformanceData.new(database_connection,
host_description, service_name)` where

* `database_connection` is a [Sequel](http://sequel.jeremyevans.net/)
  connection to the ingraph database.
* `host_description` is a SQL-style string pattern for the host name
  (see below), an array of such patterns, or an array of
  `RubyIngraphClient::Host` objects.
* `service_name` is the name of the service for which performance data
  is requested

(Optionally) Configure the PerformanceData object using the methods
described below, then call `fetch` to query the database.  `fetch`
returns a Sequel-style array of hashes (one for each row).  Each
element will have keys `:plot_id`, `:host_name`, `:timestamp` (in
seconds), and `value`.

For example, to print out a comma-separated list of timestamp and
value pairs, do

```ruby
performance_data.fetch.each do |row|
  puts "#{row[:timestamp]},#{row[:value]}"
end
```

You can map the performance data results to other formats by `map`ing
the results array.  For example, to create a series of (x,y) pairs for
dashing or rickshaw:

```ruby
performance_data.fetch.map do |row|
  { x: row[:timestamp], y: row[:value] }
end
```

### Host selection

The `host_description` argument described above corresponds to a
database query `select * from host where name like
<host_description>`.  So, for example, if you have a cluster of
servers named `web_server1`, `web_server2`, and `web_server3`,
supplying the pattern `web_server%` would allow you to query
performance data for all 3.  This is useful when collecting
performance statistics for a cluster.

You can also provide an array of such strings, so
`['web_server%', 'api_server%']` would fetch data for all web servers
and all api servers, for example.

To select just one server, you can just supply its name.

### Configuration

The following instance functions reply `self` so that they can be chained.

* `with_timespan` - A
  [timespan](https://github.com/kristianmandrup/timespan) object or
  arguments to be passed directly to `Timespan.new` (see below).
* `with_timezone` - When set, the `fetch` query will be prepended with
  `SET TIME ZONE '<timezone>'`.
* `with_timeframe` - A `RubyIngraphClient::Timeframe` object used to
  select data points (see below).

### Timespans

RubyIngraphClient uses the Ruby
[timespan](https://github.com/kristianmandrup/timespan) library.  The
`with_timespan` method can take one of 3 types of arguments:

1. A Timespan object directly (e.g., created using `Timespan.new`)
2. An array with two elements, used to create a timespan spanning
   those elements using the timespan library's syntax.
3. Arguments to be passed directly into `Timespan.new`.

The timespan library can take a variety of human-readable inputs. For
example, to fetch the last week's worth of day, use
`.with_timespan(['one week ago', 'now'])`, `.with_timespan(from: 'one
week ago', to: 'now')`, or `.with_timespan(Timespan.new(from: 'one
week ago', to: 'now'))`.  All three are equivalent.  See the
[timespan](https://github.com/kristianmandrup/timespan) docs for more
details.

### Timeframes

inGraph uses timeframes to reduce the amount of data to store for most
use cases.  Timeframes are defined by their interval (how far between
data points), retention period (how long to keep data for), and
whether or not the timeframe is active.

Upon the first creation of a `RubyIngraphClient::PerformanceData`
object (or by directly calling
`RubyIngraphClient::Timeframe.populate(db)`), RubyIngraphClient
creates an in-memory array of all available timeframes in the
database.

The timeframe with smallest interval can be obtained by calling
`RubyIngraphClient::Timeframe.smallest`.  A timeframe with a
particular interval may be selected by calling
`RubyIngraphClient::Timeframe[<interval>]`.

By default, the timeframe with the smallest interval is used. Note
that inGraph deletes data after the retention period is over, so if
your query does not return results you may want to try querying with a
different timeframe.

RubyIngraphClient makes some assumptions about the timeframes
available in your database - namely that there aren't very many and
that there are no duplicated intervals.  This is true in the default
inGraph configuration.
