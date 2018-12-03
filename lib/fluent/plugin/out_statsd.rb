require 'statsd-ruby'
require 'fluent/plugin/output'

module Fluent::Plugin
  class StatsdOutput < Output
    Fluent::Plugin.register_output('statsd', self)

    DEFAULT_BUFFER_TYPE = "memory"

    helpers :compat_parameters

    config_param :flush_interval, :time, :default => 1
    config_param :host, :string, :default => 'localhost'
    config_param :port, :string, :default => '8125'

    config_section :buffer do
      config_set_default :@type, DEFAULT_BUFFER_TYPE
    end

    attr_reader :statsd

    def initialize
      super
    end

    def configure(conf)
      compat_parameters_convert(conf, :buffer)
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

    def multi_workers_ready?
      true
    end

    def formatted_to_msgpack_binary?
      true
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
    end

  end
end
