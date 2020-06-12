# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Pattern Matching' do
  describe 'Record' do
    class PatternMatchingRecord__Test
      include Record

      attribute :foo
      attribute :bar
      attribute :baz
    end

    it 'correctly deconstructs keys' do
      case PatternMatchingRecord__Test.new(foo: 1, bar: 2, baz: 3)
      in PatternMatchingRecord__Test(foo: foo, bar: bar, baz: baz)
        result = [foo, bar, baz]
      in PatternMatchingRecord__Test(foo: foo, bar: bar, baz: baz, snafu: snafu)
        result = [foo, bar, baz, snafu]
      else
        result = []
      end

      expect(result).to eq([1, 2, 3])
    end
  end
end