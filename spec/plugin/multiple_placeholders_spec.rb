require 'fluent/plugin/out_statsd'
require 'fluent/test'

RSpec.describe Fluent::StatsdOutput do
  let(:config) do
    %{
      type statsd

      <metric>
        statsd_type increment
        statsd_key res_code_${record['hostname']}_${record['status'].to_i / 100}xx
      </metric>
    }
  end
  let(:driver) { create_driver(config) }
  let(:statsd) { double('statsd', increment: true,
                                  flush: true,
                                  'namespace=' => true,
                                  'batch_size=' => true,
                                  'batch_byte_size' => true)

               }
  let(:time) { Time.now.utc }

  before :all do
    Fluent::Test.setup
  end

  def create_driver(conf)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::StatsdOutput) {
    }.configure(conf)
  end

  def emit_events(events)
    events.each {|e| driver.emit(e, time) }
  end


  it 'should call statsd with events data and correctly handle multiple placeholders' do
    allow(Statsd).to receive(:new).and_return(statsd)

    expect(statsd).to receive(:increment).with('res_code_localhost_2xx', sample_rate: 1.0).twice.times
    expect(statsd).to receive(:increment).with('res_code_localhost_4xx', sample_rate: 1.0).once.times
    expect(statsd).to receive(:increment).with('res_code_localhost_5xx', sample_rate: 1.0).once.times

    emit_events([
      {'hostname' => 'localhost', 'response_time' => 102, 'status' => '200'},
      {'hostname' => 'localhost', 'response_time' => 105, 'status' => '200'},
      {'hostname' => 'localhost', 'response_time' => 112, 'status' => '400'},
      {'hostname' => 'localhost', 'response_time' => 125, 'status' => '500'}
    ])

    driver.run
  end
end
