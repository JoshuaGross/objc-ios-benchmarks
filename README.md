# objc-ios-benchmarks

Objective-C iOS benchmarks for better understanding of Objective-C and the Objective-C runtime on iOS.

## BenchmarkArrayDeduplication

Benchmarks for different ways of filtering duplicates in Objective-C (specifically on iOS).

The basic problem is that we have an NSArray of IDs. When we update our data source, we first want to
filter out any duplicate data already in our NSArray. This is not for
 arrays that contain duplicated data; rather, we have an array `old` and an array `new` and only want to process
 data in `new` if it is not duplicated in `old`. What's the fastest method?

Conclusion: use NSSets to filter duplicate data. Even if your data needs to be ordered, it's faster
 to construct an NSSet from the original NSArray and throw the NSSet away afterwards. `NSPredicate` is
 extremely slow! Avoid using it, if at all possible.

### Benchmark Results (iOS 7, iPhone 5)
No actual duplicates found in data:
* Convert NSArray to NSSet: 0.483276
* Convert NSArray to NSDictionary: 0.568170
* Get first matching object with indexOfObjectPassingTest: 5.670303
* Explicit enumeration, O(n^2), using fast enumeration: 6.677434
* Get all matching objects with predicate: 14.675398

With duplicated data:
* Convert NSArray to NSSet: 0.449793
* Convert NSArray to NSDictionary: 0.539544
* Get first matching object with indexOfObjectPassingTest: 4.540622
* Explicit enumeration, O(n^2), using fast enumeration: 5.321357
* Get all matching objects with predicate: 14.671595

## BenchmarkCharacterRange
What's the fastest way to find the first occurrence of a character in a string? If you can create an NSCharacterSet once and reuse it, `rangeOfCharacterFromSet` is
fastest. Otherwise, `rangeOfString` is the way to go.

### Benchmark Results (iOS 7 ,iPhone 5)
* Execution time of static character set: 1.799306
* Execution time of rangeOfString: 3.759440
* Execution time of character set: 6.714541
