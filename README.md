# ruby-optics

Simple library with common functional optics for Ruby.

## Supported Ruby versions

This library officially supports the following Ruby versions:

* MRI = `2.5.0`

## Installation

Add this to your Gemfile
```ruby
gem 'ruby-optics'
```

and then run

```
bundle install
```

Or install it manually

```
gem install ruby-optics
```

## Usage

Lens - is an object which encapsulates getter/setter functionality for immutable data in composable way. 
Any lens consist of two functions `set` and `get`. `get` describes how can retrieve a value from a whole object, and `set` - how to update this value without mutating the object.

Example for getting/setting value by key from hash:
```ruby
def hash_get(key)
  -> (hash) { hash[key] }
end

def hash_set(key)
  -> (new_value, hash) { hash.merge(key => new_value) }
end
```

To create lens you need to specify both these functions:

```ruby
lens = Lens.new(hash_get(:foo), hash_set(:foo))
```

Then you can use the lens to retrieve, set and modify value by the key in arbitrary hash:

```ruby
object = { foo: 1, bar: 2 }

lens.get(object)
=> 2

lens.set(3, object)
=> { foo: 3, bar: 2 }

lens.modify(object) { |foo| foo * 10 }
=> { foo: 10, bar: 2 }

object
=> { foo: 1, bar: 2 }
```

Note that `set` and `modify` operations don't mutate original value, thus keeping it unchanged.

The real power of lens comes from their compositional properties, which allows to creates lenses that works with arbitrary nested
objects by composing them from simpler ones.

```ruby
foo_lens = Lens.new(hash_get(:foo), hash_set(:foo))
bar_lens = Lens.new(hash_get(:bar), hash_set(:bar))

lens = foo_lens.compose_lens(bar_lens)

object = { foo: { bar: 1 } }

lens.get(object)
=> 1

lens.set(3, object)
=> { foo: { bar: 3 } }

lens.modify(object) { |foo| foo * 10 }
=> { foo: { bar: 10 } }

object
=> { foo: { bar: 1 } }
```

The library provides lens constructors for common cases, so you don't need to composes lenses yourself
```ruby
lens = Optics.hash_lens(:foo, :bar)
```


## License

See `LICENSE` file.
