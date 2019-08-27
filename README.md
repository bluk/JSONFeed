# JSON Feed

A [Swift][swift] [Codable][codable] model for [JSON Feed][jsonfeed].

## Usage

### Swift Package Manager

Add this package to your `Package.swift` `dependencies` and target's `dependencies`:

```swift
import PackageDescription

let package = Package(
    name: "Example",
    dependencies: [
        .package(
            url: "https://github.com/bluk/JSONFeed",
            from: "0.9.0"
        ),
    ],
    targets: [
        .target(
            name: "YourProject",
            dependencies: ["JSONFeed"]
        )
    ]
)
```

### Code

```swift
import JSONFeed

let jsonFeedData: Data = /* get the JSON feed data */
let jsonDecoder = JSONDecoder()
let feed = try jsonDecoder.decode(JSONFeed.self, from: jsonFeedData)
print(feed.title)
```

## Design Considerations

### `var` vs. `let`

All of the properties are mutable. The reason is that the JSON Feed model types are merely for
serialization and deserialization of data. There is no business logic, invariants, or
other "interesting" code. If you want to get a feed and then modify the data before passing
the value to your business methods, you are free to do so.

All of the model types are structs and not classes. While perhaps not as efficient
(not benchmarked) in some extreme cases, value types are easier to reason about for these
types of simple data transfer models.

### Optional properties

All of the properties are optional. While inconvenient, the reality is that even if
a property is required in a specification, values may be missing in "real" data.
Instead of throwing an error immediately for a missing or invalid required property,
it is up to your application to determine if processing should be stopped.

### Raw (String) values

While there are computed properties which return `URL`s and `Date`s, the raw string values
are available as a `raw(Name)` property. In some cases, the feed's value may be
invalid (e.g. an invalid or uncommon [RFC 3339][rfc3339] date) but you can get the original string
value if needed.

### RFC 3339

There are several variations for an [RFC 3339][rfc3339] date. The current computed `Date`
properties use one of the more common formats. An issue or code contribution can be
made if other date formats are desired.

### JSON Extensions

The JSON Feed Extensions are handled via the use of [AnyCodable][anycodable] which is
a type erased wrapper for `Codable` values. If you have a JSON Feed custom object
extension, it is suggested that you add an extension to `JSONFeed` (or one of the appropriate
nested types) with a computed property accessing the `extensions` property.

## License

[Apache-2.0 License][license]

[license]: LICENSE
[swift]: https://swift.org
[codable]: https://developer.apple.com/documentation/swift/codable
[jsonfeed]: https://jsonfeed.org
[rfc3339]: https://tools.ietf.org/html/rfc3339
[anycodable]: https://github.com/Flight-School/AnyCodable
