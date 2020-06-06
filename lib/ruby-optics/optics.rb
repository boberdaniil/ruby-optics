# frozen_string_literal: true

require_relative 'lens'
require_relative 'nullable'
require_relative 'each'

module Optics
  def self.hash_lens(*keys)
    head, *tail = keys

    [build_hash_lens(head), *tail].reduce { |result_lens, key|
      result_lens.compose_lens(build_hash_lens(key))
    }
  end

  def self.indiffirent_access_hash_lens(*keys)
    head, *tail = keys
    opts = { indiffirent_access: true }

    [build_hash_lens(head, opts), *tail].reduce { |result_lens, key|
      result_lens.compose_lens(build_hash_lens(key, opts))
    }
  end

  def self.struct_lens(*method_names)
    head, *tail = method_names

    [build_struct_lens(head), *tail].reduce { |result_lens, key|
      result_lens.compose_lens(build_struct_lens(key))
    }
  end

  private

  def self.build_hash_lens(key, indiffirent_access: false)
    ::Lens.new(
      -> (hash) {
        if indiffirent_access
          case key
          when String
            val = hash[key]
            val.nil? ? hash[key.to_sym] : val
          when Symbol
            val = hash[key]
            val.nil? ? hash[key.to_s] : val
          else
            hash[key]
          end
        else
          hash[key]
        end
      },
      -> (new_value, hash) { hash.merge(key => new_value) }
    ).nullable
  end

  def self.build_struct_lens(method_name)
    ::Lens.new(
      -> (struct) { struct[method_name] },
      -> (new_value, struct) {
        struct.class.new(
          *struct.members.map { |member|
            (member == method_name) ? new_value : struct[member]
          }
        )
      }
    )
  end
end