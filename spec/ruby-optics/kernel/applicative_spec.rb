require 'spec_helper'

RSpec.describe Applicative do
  describe '.instance_for' do
    it 'returns instance for default types' do
      expect(Applicative.instance_for(Array)).to eq(Applicative::ArrayInstance)
      expect(Applicative.instance_for(Const)).to eq(Applicative::ConstInstance)
    end
  end
end