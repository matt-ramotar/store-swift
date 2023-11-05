#  Store for iOS

Store is a systematic solution to manage data flow in applications. This library aims to encapsulate fetching, caching, validating, and streaming of data, reducing boilerplate code and facilitating a predictable, debuggable data flow. This design is a port of the MobileNativeFoundation/Store Kotlin Multiplatform library that is backed by The Kotlin Foundation and a standard in the Android community for managing asynchronous data loading and caching.

## Features
- **Unified Data Flow**: Manage all your data sources with a consistent and coherent flow.
- **Reactive Programming**: Built to integrate seamlessly with `Combine`, catering to modern reactive programming paradigms.
- **Concurrency and Thread Safety**: Uses Swift's `async`/`await`, `Task`, and `Combine` APIs for safe, concurrent data operations.
- **Flexible Storage**: Works with any local storage system, for example, `UserDefaults`, `CoreData`, `Realm`, or custom databases.
- **Debuggable**: Designed to make data flows easy to debug and reason about.

## Concepts
- `Store` is responsible for managing a particular read request.
- `StoreReadRequest` defines how data (_output_) will be loaded from `Store`.
- `SourceOfTruth` defines how data (_local_) will be persisted.
- `Fetcher` defines how data (_network_) will be fetched.
- `Validator` defines how data (_output_) will be validated.
- `Converter` defines how to convert between data representations (_network, local, output_).

## Installation

### Swift Package Manager

TODO

## Usage

TODO

## Documentation

TODO

## Contributing

TODO

## Examples

TODO

## FAQ

TODO

## License

TODO
