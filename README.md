# msgpack.cr

A low-level [msgpack](http://msgpack.org) codec for [Crystal](https://crystal-lang.org)

## TODO

- More specs
- Mapping

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  msgpack:
    github: steakknife/msgpack.cr
```
## Usage

```crystal
require "msgpack"

1.to_msgpack # => Slice[210, 0, 0, 0, 1]

# write 2_i32 to file foo.msgpack
File.open("foo.msgpack", "w") { |f| f.write(2.to_msgpack) }

```

## Extending
### Encoding

Any type can become encodable by including `Msgpack::Encodable` and defining `to_msgpack(io : IO)`
### Decoding

Any type can become decodable by following the [example](spec/foo_spec.cr)

## Development

### Run tests

```shell
crystal spec
```

## Alternate Implementations

- [github: benoist/msgpack-crystal](https://github.com/benoist/msgpack-crystal)

## Contributing

1. Fork it ( https://github.com/steakknife/msgpack.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[steakknife]](https://github.com/steakknife) Barry Allard - creator, maintainer

## License

[MIT](LICENSE)

## Copyright

2016 (c) Copyright Barry Allard
