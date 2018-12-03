require 'fluent/plugin/out_statsd'
require 'fluent/test'
require 'fluent/test/helpers'
require 'fluent/test/driver/output'
require 'statsd-ruby'

class StatsdOutputTest < Test::Unit::TestCase
  include Fluent::Test::Helpers

  def setup
    super
    Fluent::Test.setup
    @now = event_time
  end

  def teardown
  end

  CONFIG = %[
    type statsd
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::StatsdOutput) {
    }.configure(conf)
  end

  def test_write
    d = create_driver
    time = @now
    d.run(default_tag: 'test') do
      d.feed(time, { :stastd_type => 'timing', :statsd_key => 'test.statsd.t', :statsd_timing => 100 })
      d.feed(time, { :stastd_type => 'guage', :statsd_key => 'test.statsd.g', :statsd_gauge => 102 })
      d.feed(time, { :stastd_type => 'increment', :statsd_key => 'test.statsd.i'})
    end
  end
end
