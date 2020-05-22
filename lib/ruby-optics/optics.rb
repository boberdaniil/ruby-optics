require_relative 'lens'
require_relative 'nullable'
require_relative 'optional_lens'
require_relative 'traversal'

module Optics
  def self.hash_lens(*keys)
    head, tail = *keys

    [build_hash_lens(head), *tail].reduce { |result_lens, key|
      result_lens.compose_lens(build_hash_lens(key))
    }
  end

  def self.struct_lens_chained(*method_names)
    head, tail = *method_names

    [struct_lens(head), *tail].reduce { |result_lens, key|
      result_lens.compose_lens(struct_lens(key))
    }
  end

  def self.struct_lens(method_name)
    ::Lens.new(
      -> (struct) { struct[method_name] },
      -> (new_value, struct) {
        struct.class.new(
          struct.members.map { |member|
            if member == method_name
              new_value
            else
              struct[member]
            end
          }
        )
      }
    )
  end

  private

  def self.build_hash_lens(key)
    ::Lens.new(
      -> (hash) { hash[key] },
      -> (new_value, hash) { hash.merge(key => new_value) }
    ).nullable
  end
end