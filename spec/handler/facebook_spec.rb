RSpec.describe Rack::Tracker::Facebook do
  describe Rack::Tracker::Facebook::Event do

    subject { described_class.new({id: 'id', foo: 'bar'}) }

    describe '#write' do
      specify { expect(subject.write).to eq(['track', 'id', {foo: 'bar'}].map(&:to_json).join(', ')) }
    end
  end

  def env
    {}
  end

  it 'will be placed in the body' do
    expect(described_class.position).to eq(:body)
    expect(described_class.new(env).position).to eq(:body)
  end

  describe 'with custom audience id' do
    subject { described_class.new(env, custom_audience: 'custom_audience_id').render }

    it 'will push the tracking events to the queue' do
      expect(subject).to match(%r{fbq\("init", "custom_audience_id"\)})
      expect(subject).to match(%r{fbq\("track", "PageView"\)})
    end

    it 'will add the noscript fallback' do
      expect(subject).to match(%r{https://www.facebook.com/tr\?id=custom_audience_id&amp;ev=PageView})
    end
  end

  describe 'with events' do
    def env
      {
        'tracker' => {
        'facebook' =>
          [
            {
              'id' => 'Purchase',
              'value' => '23',
              'currency' => 'EUR',
              'class_name' => 'Event'
            }
          ]
        }
      }
    end
    subject { described_class.new(env).render }

    it 'will push the tracking events to the queue' do
      expect(subject).to match(%r{fbq\("track", "Purchase", \{"value":"23","currency":"EUR"\}\)})
    end

    it 'will add the noscript fallback' do
      expect(subject).to match(%r{tr\?id=&amp;ev=Purchase&amp;value=23&amp;currency=EUR})
    end
  end
end
