# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Ralphql::Node do
  subject { described_class.new(:foo) }

  after do
    begin
      expect(subject.query.count('{')).to eql(subject.query.count('}'))
    rescue Ralphql::EmptyNodeError
      expect(true).to eql(true)
    end
  end

  it 'raises error when there are no atts or nodes' do
    expect { subject.query }.to raise_error(Ralphql::EmptyNodeError)
  end

  describe 'camelizing names for' do
    it 'attributes' do
      subject.add(:some_thing)
      expect(subject.query).to eq('{foo{someThing}}')
    end

    it 'nodes' do
      subject.replace(name: :some_thing, atts: :foo)
      expect(subject.query).to eq('{someThing{foo}}')
    end

    it 'arguments' do
      subject.replace(args: { some_thing: 3 }, atts: :foo)
      expect(subject.query).to eq('{foo(someThing:3){foo}}')
    end
  end

  describe 'pagination' do
    before { subject.replace(paginated: true, atts: :id) }

    described_class::PAGINATION_ATTS.each do |att|
      it "includes #{att} in the query" do
        expect(subject.query).to include(att.to_s)
      end
    end

    it 'includes pageInfo node' do
      expect(subject.query).to include('pageInfo{')
    end

    it 'includes edges node' do
      expect(subject.query).to include('edges{')
    end

    it 'includes node node' do
      expect(subject.query).to include('node{')
    end
  end

  describe 'creating a query with' do
    it 'complex attributes' do
      node = described_class.new(:url, args: { sizes: [{ width: 30, height: 30 }, { width: 100, height: 200 }] })
      subject.add(node)
      expect(subject.query).to eql('{foo{url(sizes:[{width:30, height:30}, {width:100, height:200}])}}')
    end

    describe 'a root node' do
      it 'with one attribute' do
        subject.add(:bar)
        expect(subject.query).to eq('{foo{bar}}')
      end

      it 'with multiple attributes' do
        subject.add(%i[baz meh])
        expect(subject.query).to eq('{foo{baz meh}}')
      end

      it 'with an attribute and another node' do
        subject.add(:bar)
        subject.add_node(:baz, atts: %i[id name])
        expect(subject.query).to eq('{foo{bar baz{id name}}}')
      end
    end

    describe 'a nested node' do
      it 'with one attribute' do
        subject.add_node(:bar, atts: :baz)
        expect(subject.query).to eq('{foo{bar{baz}}}')
      end

      it 'with multiple attributes' do
        subject.add_node(:bar, atts: %i[baz meh])
        expect(subject.query).to eq('{foo{bar{baz meh}}}')
      end

      it 'with multiple mixed attributes' do
        node = subject.add_node(:meh, atts: :bar)
        node.add_node(:baz, atts: %i[id name])
        expect(subject.query).to eq('{foo{meh{bar baz{id name}}}}')
      end
    end

    describe 'a multi-nested node' do
      it 'with one attribute each' do
        subject.add_node(:bar, atts: :baz)
        subject.add_node(:meh, atts: :wey)
        expect(subject.query).to eq('{foo{bar{baz} meh{wey}}}')
      end

      it 'with multiple attributes each' do
        subject.add_node(:bar, atts: %i[baz meh])
        subject.add_node(:meh, atts: %i[baz meh])
        expect(subject.query).to eq('{foo{bar{baz meh} meh{baz meh}}}')
      end

      it 'with multiple mixed attributes' do
        subject.add_node(:bar, atts: :wey, nodes: described_class.new(:baz, atts:  %i[id name]))
        subject.add_node(:meh, atts: :wey, nodes: described_class.new(:baz, atts:  %i[id name]))
        expect(subject.query).to eq('{foo{bar{wey baz{id name}} meh{wey baz{id name}}}}')
      end
    end

    describe 'arguments on' do
      before { subject.replace(atts: :crap, args: { id: 3 }) }

      it 'the query' do
        expect(subject.query).to eq('{foo(id:3){crap}}')
      end

      it 'a node' do
        subject.add_node(:bar, args: { muh: 'cow' }, atts: :wey, nodes: described_class.new(:baz, atts: %i[id name]))
        subject.add_node(:meh, args: { muh: 'cow' }, atts: :wey, nodes: described_class.new(:mih, atts: :moh))

        expect(subject.query).to eq("{foo(id:3){crap bar(muh:'cow'){wey baz{id name}} meh(muh:'cow'){wey mih{moh}}}}")
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
