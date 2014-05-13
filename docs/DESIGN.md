## VENCore

## Users
* Venmo app / VenmoClient
* VENAppSwitchSDK
* VenmoSDK
* Venmo

## Compatibility
* Mac OS X 10.?
* iOS 6+
* ARC Only

## Class hierarchy
### Public interface
* `VENCore` - public facing interface
  * Responsible for:
    * Providing a simple interface for interacting with the Venmo internal API

### Models
* Should we have type-safe representations of Venmo resources? (YES)
* If we do, should we use [Mantle](https://github.com/MantleFramework/Mantle)?
  * Pros:
    * Removes a lot of JSON<->model boilerplate for transforming values
      * i.e. datestamp <-> NSDate, string <-> enum
    * Mantle could be a transition layer between the Venmo API and Core Data
      * This [slide deck](http://www.slideshare.net/GuillermoGonzalez51/better-web-clients-with-mantle-and-afnetworking) is a pretty good overview and shows what using Mantle + AFNetworking could look like.
      * `MTLManagedObjectAdapter` seems to make going from Mantle -> Core Data pretty easy
        * We could turn our existing models into `MTLModel` categories that conform to `<MTLManagedObjectSerializing>`
  * Cons:
    * Additional dependency

### Service
* `VENClientAPI` – translates raw HTTP responses into domain objects
  * Responsible for:
    * API endpoint names
    * access tokens
    * default headers
    * response parsing
