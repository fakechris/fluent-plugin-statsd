require 'fluent/plugin/out_statsd'
require 'statsd-ruby'

class StatsdOutputTest < Test::Unit::TestCase
  def setup
    super
    Fluent::Test.setup
    @now = Time.now
  end

  def treedown
  end

  CONFIG = %[
    type statsd
  ]

  def create_driver(conf = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::StatsdOutput) {
    }.configure(conf)
  end

  def test_write
    d = create_driver
    time = Time.at(@now.to_i).utc
    d.emit({ :stastd_type => 'timing', :statsd_key => 'test.statsd.t', :statsd_timing => 100 }, time)
    d.emit({ :stastd_type => 'guage', :statsd_key => 'test.statsd.g', :statsd_gauge => 102 }, time)
    d.emit({ :stastd_type => 'increment', :statsd_key => 'test.statsd.i'}, time)

    d.run
  end
end
