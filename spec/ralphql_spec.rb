# frozen_string_literal: true

RSpec.describe Ralphql do
  subject { described_class.new(:foo) }

  it 'has a version number' do
    expect(Ralphql::VERSION).not_to be nil
  end
end
