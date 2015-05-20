require 'honeybadger/util/request_payload'

class TestSanitizer
  def sanitize(data)
    data
  end

  def filter_url(string)
    string
  end
end

describe Honeybadger::Util::RequestPayload do
  let(:sanitizer) { TestSanitizer.new }

  describe "::build" do
    subject { described_class.build }

    Honeybadger::Util::RequestPayload::DEFAULTS.each_pair do |key, value|
      it "defaults #{ key } to default value" do
        expect(subject[key]).to eq value
      end
    end

    it "can be intiailized with a Hash" do
      subject = described_class.build({ component: 'foo' })
      expect(subject[:component]).to eq 'foo'
    end

    it "returns a Hash" do
      expect(subject).to be_a Hash
    end

    it "rejects invalid keys" do
      subject = described_class.build({ foo: 'foo' })
      expect(subject).not_to have_key(:foo)
    end

    it "defaults nil keys" do
      subject = described_class.build({ params: nil })
      expect(subject[:params]).to eq({})
    end

    it "sanitizes payload with injected sanitizer" do
      expect(sanitizer).to receive(:sanitize).with('foo')
      described_class.build({ sanitizer: sanitizer, component: 'foo' })
    end

    it "sanitizes the url key" do
      expect(sanitizer).to receive(:filter_url).with('foo/bar')
      described_class.build({ sanitizer: sanitizer, url: 'foo/bar' })
    end

    it "converts #to_h to JSON" do
      original = subject.to_h
      result = JSON.parse(subject.to_json)

      expect(result.size).to eq original.size
      subject.to_h.each_pair do |k,v|
        expect(result[k.to_s]).to eq v
      end
    end
  end
end
