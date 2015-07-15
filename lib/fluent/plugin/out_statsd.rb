require 'statsd-ruby'

module Fluent
  class StatsdOutput < BufferedOutput
    Fluent::Plugin.register_output('statsd', self)

    config_param :flush_interval, :time, :default => 1
    config_param :host, :string, :default => 'localhost'
    config_param :port, :string, :default => '8125'
    config_param :batch_send, :bool, :default => false

    attr_reader :statsd

    def initialize
      super
    end

    def configure(conf)
      super
      statsd = Statsd.new(host, port)
      @statsd = batch_send ? Statsd::Batch.new(statsd) : statsd
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
        if statsd_type = record['statsd_type']
          case statsd_type
          when 'timing'
            @statsd.timing record['statsd_key'], record['statsd_timing'].to_f
          when 'gauge'
            @statsd.gauge record['statsd_key'], record['statsd_gauge'].to_f
          when 'count'
            @statsd.count record['statsd_key'], record['statsd_count'].to_f
          when 'set'
            @statsd.set record['statsd_key'], record['statsd_set']
          when 'increment'
            @statsd.increment record['statsd_key']
          when 'decrement'
            @statsd.decrement record['statsd_key']
          end
        end
      }
      @statsd.flush if batch_send
    end

  end
end
