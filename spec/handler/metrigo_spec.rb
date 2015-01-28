RSpec.describe Rack::Tracker::Metrigo do
  describe Rack::Tracker::Metrigo::Event do

    subject { described_class.new({ function_name: 'logHomepage' }) }

    it 'should always have a has for #arguments' do
      expect(subject.arguments).to eql({})
    end

    describe '#write' do
      specify { expect(subject.write).to eq "DELIVERY.DataLogger.logHomepage()" }
    end

    describe '#write_arguments' do
      context 'nil' do
        it 'should return nothing' do
          expect(subject.write_arguments).to be_nil
        end
      end

      context 'with arguments hash' do
        subject { described_class.new({ arguments: { categories: ["cat1", "cat2"], shop_id: 7 } }) }
        it 'should return the hash as JSON' do
          expect(subject.write_arguments).to eq '{"categories":["cat1","cat2"],"shop_id":7}'
        end
      end
    end
  end

  it 'will be placed in the body' do
    expect(described_class.position).to eq(:body)
    expect(described_class.new({}).position).to eq(:body)
  end

  describe '#events' do
    let(:env) {
      {
        'tracker' => {
        'metrigo' =>
          [
            {
              function_name: 'logHomepage',
              class_name: 'Event'
            }
          ]
        }
      }
    }

    subject { described_class.new(env, { shop_id: 1999 }).render }

    it 'will add shop_id and push the tracking events to the queue' do
      expect(subject).to include 'DELIVERY.DataLogger.logHomepage({"shop_id":1999})'
    end
  end
end