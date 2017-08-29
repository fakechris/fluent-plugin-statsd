# Fluent event to statsd plugin.

[![Build Status](https://travis-ci.org/lingochamp/fluent-plugin-statsd.svg?branch=master)](https://travis-ci.org/lingochamp/fluent-plugin-statsd)

# Installation

```
$ fluent-gem install fluent-plugin-statsd-output
```

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-statsd.png)](http://badge.fury.io/rb/fluent-plugin-statsd)

# Usage

```
<match statsd>
  type statsd
  host localhost # optional
  port 8125 # optional
  namespace a.b.c # optional
  batch_byte_size 512 # optional

  <metric>
    statsd_type timing
    statsd_key my_app.nginx.response_time
    statsd_key ${record['response_time']}
  </metric>

  <metric>
    statsd_type increment
    statsd_key my_app.nginx.${record['response_code'].to_i / 100}xx # 2xx 4xx 5xx
  </metric>
</match>
```

# Development

```
$ rspec
```

# Copyright

Copyright (c) 2014- Chris Song

# License

Apache License, Version 2.0
