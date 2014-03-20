# Fluent event to statsd plugin.

# Installation

```
$ fluent-gem install fluent-plugin-statsd
```

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


# Copyright

Copyright (c) 2014- Chris Song

# License

Apache License, Version 2.0
