# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Ralphql::Node do
  subject { described_class.new(:foo) }

  it 'raises error when there are no atts or nodes' do
    expect { subject.query }.to raise_error(Ralphql::EmptyBodyError)
  end

  describe 'camelizing names for' do
    it 'attributes' do
      subject.add(:some_thing)
      expect(subject.query).to eq('{foo{someThing}}')
    end

    it 'nodes' do
      subject.update(name: :some_thing, atts: :foo)
      expect(subject.query).to eq('{someThing{foo}}')
    end

    it 'arguments' do
      subject.update(args: { some_thing: 3 }, atts: :foo)
      expect(subject.query).to eq('{foo(someThing:3){foo}}')
    end
  end

  describe 'creating a query with' do
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
      it 'the query' do
        subject.update(atts: :bar, args: { id: 3 })
        expect(subject.query).to eq('{foo(id:3){bar}}')
      end

      it 'a node' do
        subject.update(atts: :crap, args: { id: 3 })

        subject.add_node(:bar, args: { muh: 'cow' }, atts: :wey, nodes: described_class.new(:baz, atts: %i[id name]))
        subject.add_node(:meh, args: { muh: 'cow' }, nodes: described_class.new(:mih, atts: :moh))

        expect(subject.query).to eq("{foo(id:3){crap bar(muh:'cow'){wey baz{id name}} meh(muh:'cow'){mih{moh}}}}")
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
