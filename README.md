#  Store

Store is a data loading and caching library that simplifies fetching, caching, and managing data.


## Concepts

1. `Store` is responsible for managing a particular read request.
2. `StoreReadRequest` defines how data (_output_) will be loaded from `Store`.
3. `SourceOfTruth` defines how data (_local_) will be persisted.
4. `Fetcher` defines how data (_network_) will be fetched.
5. `Validator` defines how data (_output_) will be validated.
6. `Converter` defines how to convert between data representations (_network, local, output_).

## Building a Store

```swift

let fetcher
    

```
