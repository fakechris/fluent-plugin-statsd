require 'fluent/plugin/out_statsd'
require 'fluent/test'
require 'test/unit'

class StatsdOutputTest < Test::Unit::TestCase
  def setup
    super
    Fluent::Test.setup
    @now = Time.now
  end

  def treedown
  end

  CONFIG = %{
    type statsd

    <metric>
      statsd_type timing
      statsd_key response_time
      statsd_val ${record['response_time']}
    </metric>

    <metric>
      statsd_type increment
      statsd_key response_code_${record['status'].to_i / 100}xx
    </metric>
  }

  def create_driver(conf = CONFIG)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::StatsdOutput) {
    }.configure(conf)
  end

  def test_write
    d = create_driver
    time = Time.at(@now.to_i).utc
    d.emit({'response_time' => 102, 'status' => '200'}, time)
    d.emit({'response_time' => 105, 'status' => '200'}, time)
    d.emit({'response_time' => 112, 'status' => '400'}, time)
    d.emit({'response_time' => 125, 'status' => '500'}, time)

    d.run
  end
end
