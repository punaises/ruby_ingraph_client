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
perfdata = RubyIngraphClient::PerformanceData.new(db, 'server', 'check_cpu_usage')

perfdata.with_timespan(['2 days ago', '1 day ago']).fetch.each do |datum|
  puts datum.inspect
end
```
