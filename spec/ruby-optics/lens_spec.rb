# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lens do
  let(:hash_foo_lens) do
    Lens.new(
      -> (a) { a[:foo] },
      -> (a, s) { s.merge(foo: a) }
    )
  end

  describe '#get & #set' do
    it 'retrieves and set values' do
      lens = hash_foo_lens

      expect(lens.get({ foo: 1 })).to eq(1)

      expect(lens.set(2, { foo: 1 })).to eq({ foo: 2})
    end
  end

  describe '#modify' do
    it 'modifies value' do
      lens = hash_foo_lens

      expect(lens.modify({ foo: 2 }) { |i| i + 5 }).to eq({ foo: 7})
    end
  end

  describe '#compose_lens' do
    it 'allows modification of nested structures' do
      lens1 = Lens.new(
        -> (a) { a[:foo] },
        -> (a, s) { s.merge(foo: a) }
      )

      lens2 = Lens.new(
        -> (a) { a[:bar] },
        -> (a, s) { s.merge(bar: a) }
      )

      composed_lens = lens1.compose_lens(lens2)
      expect(composed_lens.get({ foo: { bar: 1 } })).to eq(1)
      expect(composed_lens.get(composed_lens.set(2, { foo: { bar: 1 } }))).to eq(2)
      expect(composed_lens.modify({ foo: { bar: 2 } }) { |i| i + 3 }).to eq({ foo: { bar: 5 } })
    end
  end

  context 'identity lens' do
    let(:lens) { Lens.identity }

    describe '#get' do
      it 'returns passed value' do
        expect(lens.get(10)).to eq(10)
      end
    end

    describe '#set' do
      it 'returns new value' do
        expect(lens.set(20, 10)).to eq(20)
      end
    end

    describe '#modify' do
      it 'applies block to passed value' do
        expect(lens.modify(10) { |i| i + 5 }).to eq(15)
      end
    end
  end
end