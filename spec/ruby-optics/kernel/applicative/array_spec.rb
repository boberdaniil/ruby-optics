require 'spec_helper'

RSpec.describe Applicative::ArrayInstance do
  describe '.pure' do
    it 'returns value wrapped in array' do
      expect(Applicative::ArrayInstance.pure(1)).to eq([1])
    end
  end

  describe '.map' do
    it 'maps elements of array with block' do
      result = Applicative::ArrayInstance.map([1, 2, 3]) { |i| i + 1 }
      expect(result).to eq([2, 3, 4])
    end

    it 'maps elements of array with lambda' do
      result = Applicative::ArrayInstance.map([1, 2, 3], -> (i) { i + 1 })
      expect(result).to eq([2, 3, 4])
    end
  end

  describe '.map2' do
    it 'applies block to each two subsequent elements of sorted cartesian product' do
      result = Applicative::ArrayInstance.map2(["a1", "a2", "a3"], ["b", "c"]) { |a, b| a + b }
      expect(result).to eq(["a1b", "a1c", "a2b", "a2c", "a3b", "a3c"])
    end

    it 'applies lambda to each two subsequent elements of sorted cartesian product' do
      result = Applicative::ArrayInstance.map2(["a1", "a2", "a3"], ["b", "c"], -> (a, b) { a + b })
      expect(result).to eq(["a1b", "a1c", "a2b", "a2c", "a3b", "a3c"])
    end
  end
end