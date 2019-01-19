# Fluent event to statsd plugin.

[![Build Status](https://travis-ci.org/imnotjames/fluent-plugin-statsd.svg?branch=master)](https://travis-ci.org/imnotjames/fluent-plugin-statsd)
[![Gem Version](https://badge.fury.io/rb/fluent-plugin-statsd-output.svg)](https://badge.fury.io/rb/fluent-plugin-statsd-output)

# Installation

```
$ fluent-gem install fluent-plugin-statsd-output
```

# Usage

```
<match statsd>
  type statsd
  host localhost # optional
  port 8125 # optional
  namespace a.b.c # optional
  batch_byte_size 512 # optional
  sample_rate 0.9 # optional

  <metric>
    statsd_type timing
    statsd_key my_app.nginx.response_time
    statsd_val ${record['response_time']}
    statsd_rate 0.6 # optional
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
