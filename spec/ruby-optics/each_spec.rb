# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Each do
  let(:optic) { Each.new }

  describe '#set' do
    it 'it replaces all elements in collection with new value' do
      expect(optic.set(1, [1, 2, 3])).to eq([1, 1, 1])
    end
  end

  describe '#modify_all' do
    it 'maps collection' do
      result = optic.modify_all([1, 2, 3]) { |a| a + 1 }
      expect(result).to eq([2, 3, 4])
    end
  end

  describe '#get_all' do
    it 'returns original collection' do
      expect(optic.get_all([1, 2, 3])).to eq([1, 2, 3])
    end
  end

  context '.with_filter' do
    let(:optic) { Each.with_filter(Optics.hash_lens(:foo)) { |foo| foo < 5 } }

    let(:object) do
      [
        { foo: 2 },
        { foo: 7 },
        { foo: 8 },
        { foo: 4 }
      ]
    end

    describe '#set' do
      it 'it replaces elements matching filter in collection with new value' do
        expect(optic.set(1, object)).to eq([1, { foo: 7 }, { foo: 8 }, 1])
      end
    end
  
    describe '#modify_all' do
      it 'updates elements matching filter' do
        result = optic.modify_all(object) { |hash| hash.merge(bar: 2) }
        expect(result).to eq([
          { foo: 2, bar: 2 },
          { foo: 7 },
          { foo: 8 },
          { foo: 4, bar: 2 }
        ])
      end
    end
  
    describe '#get_all' do
      it 'returns elements matching filter collection' do
        expect(optic.get_all(object)).to eq([
          { foo: 2 },
          { foo: 4}
        ])
      end
    end
  end

  context 'when composed created from lens' do
    let(:optic) { Optics.hash_lens(:foo, :bar).each_lens }

    let(:object) { { foo: { bar: [1, 2, 3] } } }

    describe '#set' do
      it 'it replaces all elements in focused collection with new value' do
        expect(optic.set(1, object)).to eq({ foo: { bar: [1, 1, 1] } })
      end
    end

    describe '#modify_all' do
      it 'maps focused collection' do
        result = optic.modify_all(object) { |a| a + 1 }
        expect(result).to eq({ foo: { bar: [2, 3, 4] } })
      end
    end
  
    describe '#get_all' do
      it 'returns focused collection' do
        expect(optic.get_all(object)).to eq([1, 2, 3])
      end
    end

    context '.with_filter' do
      let(:optic) do
        Optics
          .hash_lens(:foo, :bar)
          .each_lens
          .with_filter(Lens.identity) { |a| a < 5 }
      end

      let(:object) { { foo: { bar: [2, 6, 4, 6] } } }

      describe '#set' do
        it 'it replaces all elements in focused collection matching filter with new value' do
          expect(optic.set(1, object)).to eq({ foo: { bar: [1, 6, 1, 6] } })
        end
      end
  
      describe '#modify_all' do
        it 'updates elements matching filter in focused collection' do
          result = optic.modify_all(object) { |a| a + 1 }
          expect(result).to eq({ foo: { bar: [3, 6, 5, 6] } })
        end
      end
    
      describe '#get_all' do
        it 'returns elements matching filter from focused collection' do
          expect(optic.get_all(object)).to eq([2, 4])
        end
      end
    end
  end

  context 'when composes lens' do
    let(:optic) { Each.new.compose_lens(Optics.hash_lens(:foo, :bar)) }

    let(:object) do
      [
        { foo: { bar: 1 } },
        { foo: { bar: 2 } },
        { foo: { bar: 3 } }
      ]
    end

    describe '#set' do
      it 'it replaces all focused elements in collection with new value' do
        expect(optic.set(1, object)).to eq([
          { foo: { bar: 1 } },
          { foo: { bar: 1 } },
          { foo: { bar: 1 } }
        ])
      end
    end

    describe '#modify_all' do
      it 'modifies focused elements in collection' do
        result = optic.modify_all(object) { |a| a + 1 }
        expect(result).to eq([
          { foo: { bar: 2 } },
          { foo: { bar: 3 } },
          { foo: { bar: 4 } }
        ])
      end
    end
  
    describe '#get_all' do
      it 'returns focused elements in collection' do
        expect(optic.get_all(object)).to eq([1, 2, 3])
      end
    end

    context '.with_filter' do
      let(:optic) do
        bar_lens = Optics.hash_lens(:foo, :bar)

        Each
          .with_filter(bar_lens) { |bar| bar < 5 }
          .compose_lens(bar_lens)
      end

      let(:object) do
        [
          { foo: { bar: 2 } },
          { foo: { bar: 6 } },
          { foo: { bar: 3 } },
          { foo: { bar: 9 } }
        ]
      end

      describe '#set' do
        it 'it replaces focused elements matching filter in collection with new value' do
          expect(optic.set(1, object)).to eq([
            { foo: { bar: 1 } },
            { foo: { bar: 6 } },
            { foo: { bar: 1 } },
            { foo: { bar: 9 } }
          ])
        end
      end
  
      describe '#modify_all' do
        it 'modifies focused elements matching filter in collection' do
          result = optic.modify_all(object) { |a| a + 1 }
          expect(result).to eq([
            { foo: { bar: 3 } },
            { foo: { bar: 6 } },
            { foo: { bar: 4 } },
            { foo: { bar: 9 } }
          ])
        end
      end
    
      describe '#get_all' do
        it 'returns returns focused elements matching filter in collection' do
          expect(optic.get_all(object)).to eq([2, 3])
        end
      end
    end
  end

  context 'when created from lens and composes lens' do
    let(:optic) do
      Optics
        .hash_lens(:foo, :bar)
        .each_lens
        .compose_lens(Optics.hash_lens(:baz, :value))
    end

    let(:object) do
      {
        foo: {
          bar: [
            { baz: { value: 1 } },
            { baz: { value: 2 } },
            { baz: { value: 3 } },
          ]
        }
      }
    end

    describe '#set' do
      it 'it replaces all focused elements in each collection with new value' do
        expect(optic.set(1, object)).to eq({
          foo: {
            bar: [
              { baz: { value: 1 } },
              { baz: { value: 1 } },
              { baz: { value: 1 } },
            ]
          }
        })
      end
    end

    describe '#modify_all' do
      it 'modifies focused elements in each collection' do
        result = optic.modify_all(object) { |a| a + 1 }
        expect(result).to eq({
          foo: {
            bar: [
              { baz: { value: 2 } },
              { baz: { value: 3 } },
              { baz: { value: 4 } },
            ]
          }
        })
      end
    end
  
    describe '#get_all' do
      it 'returns focused elements in each collection' do
        expect(optic.get_all(object)).to eq([1, 2, 3])
      end
    end

    context '.with_filter' do
      let(:optic) do
        Optics
          .hash_lens(:foo, :bar)
          .each_lens
          .with_filter(Optics.hash_lens(:baz, :value2)) { |value2| value2 < 5 }
          .compose_lens(Optics.hash_lens(:baz, :value))
      end
  
      let(:object) do
        {
          foo: {
            bar: [
              { baz: { value: 1, value2: 3 } },
              { baz: { value: 2, value2: 2 } },
              { baz: { value: 3, value2: 7 } },
              { baz: { value: 4, value2: 2 } },
            ]
          }
        }
      end

      describe '#set' do
        it 'it replaces all focused elements matching elements in each collection with new value' do
          expect(optic.set(1, object)).to eq({
            foo: {
              bar: [
                { baz: { value: 1, value2: 3 } },
                { baz: { value: 1, value2: 2 } },
                { baz: { value: 3, value2: 7 } },
                { baz: { value: 1, value2: 2 } },
              ]
            }
          })
        end
      end
  
      describe '#modify_all' do
        it 'modifies focused elements matching filter in each collection' do
          result = optic.modify_all(object) { |a| a + 1 }
          expect(result).to eq({
            foo: {
              bar: [
                { baz: { value: 2, value2: 3 } },
                { baz: { value: 3, value2: 2 } },
                { baz: { value: 3, value2: 7 } },
                { baz: { value: 5, value2: 2 } },
              ]
            }
          })
        end
      end
    
      describe '#get_all' do
        it 'returns focused elements matching filter in each collection' do
          expect(optic.get_all(object)).to eq([1, 2, 4])
        end
      end
    end
  end
end