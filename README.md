# Fluent event to statsd plugin.

# Installation

```
$ fluent-gem install fluent-plugin-statsd
```

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-statsd.png)](http://badge.fury.io/rb/fluent-plugin-statsd)

# Usage

```
<match statsd>
  type statsd
  host localhost # optional
  port 8125# optional
</match>
```

```ruby
fluent_logger.post('statsd',
  :statsd_type => 'timing',
  :statsd_key => 'org.foo.timing',
  :statsd_timing => 0.234
)

fluent_logger.post('statsd',
  :statsd_type => 'gauge',
  :statsd_gauge => 10,
  :statsd_key => 'org.foo.gauge'
)

fluent_logger.post('statsd',
  :statsd_type => 'count',
  :statsd_gauge => 10,
  :statsd_key => 'org.foo.gauge'
)

fluent_logger.post('statsd',
  :statsd_type => 'set',
  :statsd_gauge => 10,
  :statsd_key => 'org.foo.gauge'
)

fluent_logger.post('statsd',
  :statsd_type => 'increment',
  :statsd_key => 'org.foo.counter'
)


fluent_logger.post('statsd',
  :statsd_type => 'decrement',
  :statsd_key => 'org.foo.counter'
)
```

# td-agent.conf demo

worked with record_reformer to transform access log request_time into statsd

```
<match accesslog.reformer>
  type copy
  <store>
    type statsd
    host 127.0.0.1
    port 8125
    flush_interval 1s 
  </store>
  # other stores...
</match>
<match accesslog>
  type record_reformer
  output_tag ${tag}.reformer
  # transform /url1/url2/url3 --> url.urlNN.urlNN
  statsd_key ${"url"+request_uri.gsub(/((\/[^\/]+){2}).*/, '\1').gsub(/([^\?]*)\?.*/,'\1').gsub(/[0-9]+/, "NN").gsub(/\//, ".");}
  statsd_timing ${request_time}
  statsd_type ${"timing"}
</match>
```


# Copyright

Copyright (c) 2014- Chris Song

# License

Apache License, Version 2.0
