require 'spec_helper'

RSpec.describe Applicative::ConstInstance do
  describe '.pure' do
    it 'returns value wrapped in const' do
      expect(Applicative::ConstInstance.pure(1)).to eq(Const.new(1))
    end
  end

  describe '.map' do
    it 'returns unchanged const' do
      original = Const.new(1)
      result1 = Applicative::ConstInstance.map(original) { |i| i + 1 }
      result2 = Applicative::ConstInstance.map(original, -> (i) { i + 1 })
      expect(result1).to eq(original)
      expect(result2).to eq(original)
    end
  end

  describe '.map2' do
    it 'ignores function and sums elements inside const' do
      const1 = Const.new("a")
      const2 = Const.new("b")
      result1 = Applicative::ConstInstance.map2(const1, const2) { |a, b| a * b }
      result2 = Applicative::ConstInstance.map2(const1, const2, -> (a, b) { a * b })

      expect(result1).to eq(Const.new("ab"))
      expect(result2).to eq(Const.new("ab"))
    end
  end
end