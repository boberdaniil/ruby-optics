require 'spec_helper'

RSpec.describe Functor::ArrayInstance do
  describe '.map' do
    it 'maps elements of array with block' do
      result = Functor::ArrayInstance.map([1, 2, 3]) { |i| i + 1 }
      expect(result).to eq([2, 3, 4])
    end

    it 'maps elements of array with lambda' do
      result = Functor::ArrayInstance.map([1, 2, 3], -> (i) { i + 1 })
      expect(result).to eq([2, 3, 4])
    end
  end
end