objc-ios-benchmarks
===================

Objective-C iOS benchmarks for better understanding of Objective-C and the Objective-C runtime on iOS.

benchmark-objc-duplicate-filter
-------------------------------

Benchmarks for different ways of filtering duplicates in Objective-C (specifically on iOS).

The basic problem is that we have an NSArray of IDs. When we update our data source, we first want to
filter out any duplicate data already in our NSArray. What's the fastest method?

Conclusion: use NSSets to filter duplicate data. Even if your data needs to be ordered, it's faster
 to construct an NSSet from the original NSArray and throw the NSSet away afterwards.

Benchmark Results (iOS 7, iPhone 5)
-----------------------------------
no duplicates:
* Explicit enumeration, O(n^2), using fast enumeration: 6.677434
* Get first matching object with indexOfObjectPassingTest: 5.670303
* Get all matching objects with predicate: 14.675398
* Convert NSArray to NSSet: 0.483276
* Convert NSArray to NSDictionary: 0.568170

with duplicates:
* Explicit enumeration, O(n^2), using fast enumeration: 5.321357
* Get first matching object with indexOfObjectPassingTest: 4.540622
* Get all matching objects with predicate: 14.671595
* Convert NSArray to NSSet: 0.449793
* Convert NSArray to NSDictionary: 0.539544
