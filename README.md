## Synopsis

Ruby FFI bindings for [Unbound](http://www.unbound.net/), a validating, recursive, and caching DNS resolver. Specifically, we are binding to the [libunbound](http://www.unbound.net/documentation/libunbound.html) API, allowing a for a full Unbound DNS resolver to be embedded within a Ruby application. 

These bindings allow for asynchronous and synchronous name resolution. You really should familiarize yourself with [libunbound](http://www.unbound.net/documentation/libunbound.html) in order to leverage this library. The current bindings will support versions of versions of libunbound distributed with Unbound 1.4.2 or newer. 

## Code Example

See the examples directory.

## Motivation

I needed to resolve millions of DNS queries, and didn't want to spend more than 5 seconds waiting for answers to each question. I had found myself subject to timeouts imposed by my recursive resolver, specifically that these were longer than the 5 seconds.My resolver was only capable of handling so many queries concurrently, so it was very easy to knock it over. I needed a way to cancel queries, freeing resources on my resolver, something that is not possible through the typical UDP DNS interface. 

By creating bindings for libunbound, I gained access to the ability to cancel DNS queries (specifically ub_cancel), allowing my name resolution process to move forward at a fair clip.

## Installation

You'll need libunbound for Unbound 1.4.2 or greater. This can typically be achieved by installing the 'unbound' DNS package for your distribution. 

To install this gem:
```
gem install unbound
```

## API Reference


## Tests

```
rake spec
```

## Contributors

* [Mike Ryan](https://github.com/justfalter)

## License

See LICENSE.txt
