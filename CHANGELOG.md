Next
====

* Your contribution here.

2.1.0 (2014-07-23)
==================

* Make :spec default rake task - [@justfalter](https://github.com/justfalter) 
* Add CONTRIBUTING.md - [@justfalter](https://github.com/justfalter) 
* Rename Changes -> CHANGELOG.md - [@justfalter](https://github.com/justfalter) 
* [#2](https://github.com/justfalter/unbound-ruby/pull/2): Add helper for synchronous queries - [@corny](https://github.com/corny)

2.0.0 (2014-03-12)
==================
* Breaking change: Unbound::Query#cancel! no longer cancels the query. Instead, use Unbound::Resolver#cancel_query to cancel queries. - [@justfalter](https://github.com/justfalter) 
* Unbound::Query#async_id will now be set to nil when the query has finished. - [@justfalter](https://github.com/justfalter) 
* Disable autoclose on the return of Context#io object. autoclose is bad news. - [@justfalter](https://github.com/justfalter) 

1.0.1 (2014-03-06)
==================
* Fix issue where the resolver couldn't keep track of in-flight queries on 32-bit systems. - [@justfalter](https://github.com/justfalter) 

1.0.0 (2014-01-31)
==================
* Initial release. - [@justfalter](https://github.com/justfalter) 
