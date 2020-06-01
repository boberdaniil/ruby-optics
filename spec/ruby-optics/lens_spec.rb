require 'spec_helper'

RSpec.describe Lens do
  let(:hash_foo_lens) do
    lens = Lens.new(
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
end