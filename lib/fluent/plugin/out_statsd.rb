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
    config_param :batch_byte_size, :integer, :default => nil
    config_param :sample_rate, :float, :default => 1.0

    config_section :metric do
      config_param :statsd_type, :string
      config_param :statsd_key, :string
      config_param :statsd_val, :string, default: nil
      config_param :statsd_rate, :float, default: 1.0
    end

    attr_reader :statsd

    def initialize
      super
    end

    def configure(conf)
      super
      @statsd = Statsd::Batch.new(Statsd.new(host, port))
      @statsd.namespace = namespace if namespace

      if batch_byte_size
        @statsd.batch_size = nil
        @statsd.batch_byte_size = batch_byte_size
      end
      log.info(statsd)

      @metrics = conf.elements.select {|elem| elem.name == 'metric' }
      log.info(@metrics)
    end

    def start
      super
    end

    def shutdown
      super
      @statsd.flush
    end

    def format(tag, time, record)
      [tag, record].to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each do |tag, record|
        parser = RubyStringParser.new(record: record, tag: tag)

        @metrics.each do |metric|
          arg_names = %w{statsd_type statsd_key statsd_val statsd_rate}
          send_to_statsd(*metric.values_at(*arg_names).map {|str| parser.parse(str) })
        end
      end
      @statsd.flush
    end


    private

    def send_to_statsd(type, key, val, rate)
      log.debug([type, key, val, rate])

      rate = sample_rate if rate.nil?

      case type
      when 'timing'
        @statsd.timing key, val.to_f, sample_rate: rate.to_f
      when 'gauge'
        @statsd.gauge key, val.to_f, sample_rate: rate.to_f
      when 'count'
        @statsd.count key, val.to_f, sample_rate: rate.to_f
      when 'set'
        @statsd.set key, val, sample_rate: rate.to_f
      when 'increment'
        @statsd.increment key, sample_rate: rate.to_f
      when 'decrement'
        @statsd.decrement key, sample_rate: rate.to_f
      else
        raise "Invalid statsd type '#{type}'"
      end
    end

    class RubyStringParser
      def initialize(vars = {})
        @obj = Struct.new(*vars.keys).new(*vars.values)
      end

      def parse(string)
        return unless string
        string.gsub(/\$\{[^\}]+\}/) {|str| @obj.instance_eval str[2..-2] }
      end
    end
  end
end
