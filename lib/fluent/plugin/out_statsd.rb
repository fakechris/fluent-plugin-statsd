require 'statsd-ruby'
require 'fluent/output'

module Fluent
  class StatsdOutput < BufferedOutput
    Fluent::Plugin.register_output('statsd', self)

    config_param :flush_interval, :time, :default => 1
    config_param :sample_rate, :float, :default => 1
    config_param :host, :string, :default => 'localhost'
    config_param :port, :string, :default => '8125'

    attr_reader :statsd

    def initialize
      super
    end

    def configure(conf)
      super
      @statsd = Statsd.new(host, port)
    end

    def start
      super
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      record.to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each {|record|
        record['statsd_rate'] = sample_rate unless record.key? 'statsd_rate'

        if statsd_type = record['statsd_type']
          case statsd_type
          when 'timing'
            @statsd.timing record['statsd_key'], record['statsd_timing'].to_f, sample_rate: record['statsd_rate']
          when 'gauge'
            @statsd.gauge record['statsd_key'], record['statsd_gauge'].to_f, sample_rate: record['statsd_rate']
          when 'count'
            @statsd.count record['statsd_key'], record['statsd_count'].to_f, sample_rate: record['statsd_rate']
          when 'set'
            @statsd.set record['statsd_key'], record['statsd_set'], sample_rate: record['statsd_rate']
          when 'increment'
            @statsd.increment record['statsd_key'], sample_rate: record['statsd_rate']
          when 'decrement'
            @statsd.decrement record['statsd_key'], sample_rate: record['statsd_rate']
          end
        end
      }
    end

  end
end
