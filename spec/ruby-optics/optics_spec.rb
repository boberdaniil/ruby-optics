# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Optics do
  describe '.hash_lens' do
    it 'builds proper lens for shallow hash' do
      lens = Optics.hash_lens(:foo)
      expect(lens.get({ foo: :bar })).to eq(:bar)
      expect(lens.set(:baz, { foo: :bar })).to eq({ foo: :baz })
      expect(lens.modify({ foo: :bar }) { |v| v.to_s }).to eq({ foo: "bar" })
    end

    it 'builds proper composable lens for shallow hash' do
      foo_lens = Optics.hash_lens(:foo)
      bar_lens = Optics.hash_lens(:bar)
      lens = foo_lens.compose_lens(bar_lens)

      object = { foo: { bar: :baz } }
      expect(lens.get(object)).to eq(:baz)
      expect(lens.set(:bazzed, object)).to eq({ foo: { bar: :bazzed } })
      expect(lens.modify(object) { |v| v.to_s }).to eq({ foo: { bar: "baz" } })
    end

    it 'builds lens that does not mutate' do
      lens = Optics.hash_lens(:foo)
      object = { foo: :bar }
      lens.modify(object) { |val| val.to_s }
      expect(object).to eq({ foo: :bar })
    end

    it 'builds lens that does not throw error if key is missing' do
      lens = Optics.hash_lens(:foo)
      expect { lens.get({ bar: :baz }) }.not_to raise_error
      expect { lens.set(:bazz, { bar: :baz }) }.not_to raise_error
      expect { lens.modify({ bar: :baz }) { |v| v.to_s } }.not_to raise_error
      expect {
        lens.compose_lens(Optics.hash_lens(:barz)).get({ bar: :baz })
      }.not_to raise_error
      expect {
        lens.compose_lens(Optics.hash_lens(:barz)).set(:bazzed, { bar: :baz })
      }.not_to raise_error
      expect {
        lens.compose_lens(Optics.hash_lens(:barz)).modify({ bar: :baz }) { |v| v.to_s }
      }.not_to raise_error
    end

    it 'builds lens for nested objects' do
      lens = Optics.hash_lens(:foo, :bar, :baz)
      object = {
        foo: {
          bar: {
            baz: 1,
            bax: 2,
          },
          snafu: 3
        }
      }
      expect(lens.get(object)).to eq(1)
      expect(lens.set(5, object)).to eq({
        foo: {
          bar: {
            baz: 5,
            bax: 2,
          },
          snafu: 3
        }
      })
      expect(lens.modify(object) { |a| a + 10 }).to eq({
        foo: {
          bar: {
            baz: 11,
            bax: 2,
          },
          snafu: 3
        }
      })
    end
  end

  describe '.struct_lens' do
    class Foo1 < Struct.new(:a1, :b1)
      def ==(another)
        self.a1 == another.a1 && self.b1 == another.b1
      end
    end

    class Foo2 < Struct.new(:foo1)
      def ==(another)
        self.foo1 == another.foo1
      end
    end

    class Foo3 < Struct.new(:foo2, :a2, :b2)
      def ==(another)
        foo2_eq = self.foo2 == another.foo2
        a2_eq = self.a2 == another.a2
        b2_eq = another.a2 && self.b2 == another.b2
        foo2_eq && a2_eq && b2_eq
      end
    end

    it 'builds proper lens for shallow struct' do
      lens = Optics.struct_lens(:a1)
      struct = Foo1.new(:foo, :bar)
      expect(lens.get(struct)).to eq(:foo)
      expect(lens.set(:baz, struct)).to eq(Foo1.new(:baz, :bar))
      expect(lens.modify(struct) { |v| v.to_s }).to eq(Foo1.new("foo", :bar))
    end

    it 'builds proper composable lens for shallow hash' do
      foo1_lens = Optics.struct_lens(:foo1)
      a1_lens = Optics.struct_lens(:a1)
      lens = foo1_lens.compose_lens(a1_lens)

      object = Foo2.new(Foo1.new(:foo, :bar))
      expect(lens.get(object)).to eq(:foo)
      expect(lens.set(:bazzed, object)).to eq(Foo2.new(Foo1.new(:bazzed, :bar)))
      expect(lens.modify(object) { |v| v.to_s }).to eq(Foo2.new(Foo1.new("foo", :bar)))
    end

    it 'builds lens that does not mutate' do
      lens = Optics.struct_lens(:a1)
      object = Foo1.new(:foo, :bar)
      lens.modify(object) { |val| val.to_s }
      expect(object).to eq(Foo1.new(:foo, :bar))
    end


    it 'builds lens for nested objects' do
      lens = Optics.struct_lens(:foo2, :foo1, :a1)
      object = Foo3.new(Foo2.new(Foo1.new(:a1, :b1)), :a2, :b2)

      expect(lens.get(object)).to eq(:a1)
      expect(lens.set(:aa1, object)).to eq(Foo3.new(Foo2.new(Foo1.new(:aa1, :b1)), :a2, :b2))
      expect(lens.modify(object) { |a| a.to_s }).to eq(
        Foo3.new(Foo2.new(Foo1.new("a1", :b1)), :a2, :b2)
      )
    end
  end
end