# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Record do
  describe 'constructor and readers' do
    class C1
      include Record
  
      attribute :attr1
      attribute :attr2
      attribute :attr3
    end

    it 'initializes from hash' do
      object = C1.new(attr1: 1, attr2: 2, attr3: 3)
      expect(object.attr1).to eq(1)
      expect(object.attr2).to eq(2)
      expect(object.attr3).to eq(3)
    end

    it 'raises error if some attribute key is missing' do
      expect { C1.new(attr1: 1, attr2: 2) }.to raise_error(ArgumentError)
    end

    it 'raises error if some attribute is nil' do
      expect { C1.new(attr1: 1, attr2: 2, attr3: nil) }.to raise_error(ArgumentError)
    end

    context 'nullables and defaults' do
      class C2
        include Record
    
        attribute :attr1
        attribute :attr2, nullable: true
        attribute :attr3, nullable: true, default: 3
      end

      it 'allows to pass nil to nullable to attributes' do
        expect { C2.new(attr1: 1 ) }.not_to raise_error
        expect(C2.new(attr1: 1).attr1).to eq(1)
      end

      it 'provides specified defaults' do
        expect(C2.new(attr1: 1).attr1).to eq(1)
        expect(C2.new(attr1: 1).attr2).to be_nil
        expect(C2.new(attr1: 1).attr3).to eq(3)
      end
    end
  end

  describe '#== #eql? #hash' do
    class C3
      include Record

      attribute :attr1
      attribute :attr2
      attribute :attr3
    end

    class C4
      include Record

      attribute :attr1
      attribute :attr2
      attribute :attr3
    end

    class C5
      include Record

      attribute :attr1
      attribute :attr2
      attribute :param3
    end

    it 'calculates same hash with records of same type with same attributes' do
      object1 = C3.new(attr1: 1, attr2: 2, attr3: 3)
      object2 = C3.new(attr1: 1, attr2: 2, attr3: 3)
      expect(object1.hash).to eq(object2.hash)
    end

    it 'calculates different hash for objects with same args but different classes' do
      object1 = C3.new(attr1: 1, attr2: 2, attr3: 3)
      object2 = C4.new(attr1: 1, attr2: 2, attr3: 3)
      expect(object1.hash).not_to eq(object2.hash)
    end

    it 'checks equality of two records' do
      object1 = C3.new(attr1: 1, attr2: 2, attr3: 3)
      object2 = C4.new(attr1: 1, attr2: 2, attr3: 3)
      object3 = C5.new(attr1: 1, attr2: 2, param3: 3)

      expect(object1).to eq(object1)
      expect(object1).to eq(C3.new(attr1: 1, attr2: 2, attr3: 3))
      expect(object1).not_to eq(object2)
      expect(object1).not_to eq(object3)
    end

    it 'checks deep equality' do
      object1 = C3.new(
        attr1: C3.new(attr1: 1, attr2: 2, attr3: 3),
        attr2: C4.new(attr1: 1, attr2: 2, attr3: 3),
        attr3: C5.new(
          attr1: 1,
          attr2: 2,
          param3: C3.new(
            attr1: 11,
            attr2: 12,
            attr3: 13
          )
        )
      )

      object2 = C3.new(
        attr1: C3.new(attr1: 1, attr2: 2, attr3: 3),
        attr2: C4.new(attr1: 1, attr2: 2, attr3: 3),
        attr3: C5.new(
          attr1: 1,
          attr2: 2,
          param3: C3.new(
            attr1: 11,
            attr2: 12,
            attr3: 13
          )
        )
      )

      expect(object1).to eq(object2)
    end
  end

  describe '#copy_with' do
    class C6
      include Record

      attribute :attr1
      attribute :attr2
      attribute :attr3
    end

    it 'creates new object with updated params' do
      original_object = C6.new(attr1: 1, attr2: 2, attr3: 3)
      updated_object = original_object.copy_with(attr2: 12, attr3: 13)

      expect(original_object.attr1).to eq(1)
      expect(original_object.attr2).to eq(2)
      expect(original_object.attr3).to eq(3)

      expect(updated_object.attr1).to eq(1)
      expect(updated_object.attr2).to eq(12)
      expect(updated_object.attr3).to eq(13)
    end
  end

  describe 'lenses' do
    class C7
      include Record

      attribute :attr1
      attribute :attr2
      attribute :attr3
    end

    class C8
      include Record

      attribute :attr1
      attribute :attr2
    end

    it 'creates correct lenses for attributes' do
      object = C4.new(attr1: 1, attr2: 2, attr3: 3)
      expect(C4.lens(:attr1).get(object)).to eq(1)
      expect(C4.lens(:attr2).get(object)).to eq(2)
      expect(C4.lens(:attr2).get(object)).to eq(2)
    end

    it 'creates nested lenses' do
      c7 = C7.new(
        attr1: 1,
        attr2: 2,
        attr3: 3
      )

      object = C8.new(
        attr1: 1,
        attr2: c7
      )

      expect(C8.lens(:attr2, :attr1).set(5, object)).to eq(
        C8.new(
          attr1: 1,
          attr2: C7.new(
            attr1: 5,
            attr2: 2,
            attr3: 3
          )
        )
      )
      expect(c7.attr1).to eq(1)
    end
  end
end