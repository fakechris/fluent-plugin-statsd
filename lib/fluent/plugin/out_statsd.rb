require 'statsd-ruby'
require 'ostruct'
require 'fluent/output'

module Fluent
  class StatsdOutput < BufferedOutput
    Fluent::Plugin.register_output('statsd', self)

    config_param :flush_interval, :time, :default => 1
    config_param :host, :string, :default => 'localhost'
    config_param :port, :string, :default => '8125'
    config_param :namespace, :string, :default => nil

    config_section :metric do
      config_param :statsd_type, :string
      config_param :statsd_key, :string
      config_param :statsd_val, :string, default: nil
    end

    attr_reader :statsd

    def initialize
      super
    end

    def configure(conf)
      super
      @statsd = Statsd.new(host, port) {|sd| std.namespace = namespace if namespace }
      @metrics = conf.elements.select {|elem| elem.name == 'metric' }
    end

    def start
      super
    end

    def shutdown
      super
    end

    def format(tag, time, record)
      [tag, record].to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each do |tag, record|
        parser = RubyStringParser.new(record: record, tag: tag)

        @metrics.each do |metric|
          arg_names = %w{statsd_type statsd_key statsd_val}
          send_to_statsd(*metric.values_at(*arg_names).map {|str| parser.parse(str) })
        end
      end
    end


    private

    def send_to_statsd(type, key, val)
      case type
      when 'timing'
        @statsd.timing key, val.to_f
      when 'gauge'
        @statsd.gauge key, val.to_f
      when 'count'
        @statsd.count key, val.to_f
      when 'set'
        @statsd.set key, val
      when 'increment'
        @statsd.increment key
      when 'decrement'
        @statsd.decrement key
      end
    end

    class RubyStringParser
      def initialize(vars = {})
        @obj = Struct.new(*vars.keys).new(*vars.values)
      end

      def parse(string)
        return unless string
        string.gsub(/\$\{.+\}/) {|str| @obj.instance_eval str[2..-2] }
      end
    end
  end
end
