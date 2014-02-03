# objc-ios-benchmarks

Objective-C iOS benchmarks for better understanding of Objective-C and the Objective-C runtime on iOS.

## BenchmarkInitWithCapacity
As far as I can tell, using `initWithCapacity` instead of simply `init` for an NSArray makes no measurable
performance difference. It may even degrade performance, except for very small arrays. Hard to tell.

* Execution time of Insert 10 elements into array, no capacity: 0.000047
* Execution time of Insert 10 elements into array, WITH capacity: 0.000043
* Execution time of Insert 10 elements into array, WITH 10 extra capacity: 0.000026
* Execution time of Insert 10 elements into array, WITH 2x extra capacity: 0.000024
* Execution time of Insert 100 elements into array, no capacity: 0.000264
* Execution time of Insert 100 elements into array, WITH capacity: 0.000251
* Execution time of Insert 100 elements into array, WITH 10 extra capacity: 0.000261
* Execution time of Insert 100 elements into array, WITH 2x extra capacity: 0.000260
* Execution time of Insert 1000 elements into array, no capacity: 0.003090
* Execution time of Insert 1000 elements into array, WITH capacity: 0.002595
* Execution time of Insert 1000 elements into array, WITH 10 extra capacity: 0.002413
* Execution time of Insert 1000 elements into array, WITH 2x extra capacity: 0.002566
* Execution time of Insert 10000 elements into array, no capacity: 0.024363
* Execution time of Insert 10000 elements into array, WITH capacity: 0.023436
* Execution time of Insert 10000 elements into array, WITH 10 extra capacity: 0.023212
* Execution time of Insert 10000 elements into array, WITH 2x extra capacity: 0.020758
* Execution time of Insert 100000 elements into array, no capacity: 0.196063
* Execution time of Insert 100000 elements into array, WITH capacity: 0.199435
* Execution time of Insert 100000 elements into array, WITH 10 extra capacity: 0.196639
* Execution time of Insert 100000 elements into array, WITH 2x extra capacity: 0.197356
* Execution time of Insert 1000000 elements into array, no capacity: 1.955455
* Execution time of Insert 1000000 elements into array, WITH capacity: 1.990783
* Execution time of Insert 1000000 elements into array, WITH 10 extra capacity: 1.998382
* Execution time of Insert 1000000 elements into array, WITH 2x extra capacity: 1.956192
* Execution time of Insert 10000000 elements into array, no capacity: 19.417706
* Execution time of Insert 10000000 elements into array, WITH capacity: 20.109480
* Execution time of Insert 10000000 elements into array, WITH 10 extra capacity: 19.782185
* Execution time of Insert 10000000 elements into array, WITH 2x extra capacity: **crash**

## BenchmarkWeakVsStrong

Is accessing a weak pointer faster, slower, or the same speed as accessing a strong pointer? Who cares?!
Apparently, I do. If you need a weak pointer, this may be a moot point - but if they incur
significant performance penalties, we may want to treat them differently than strong pointers. As it turns out, they're 
quite a bit slower to access than strong pointers. This implies that Objective-C under iOS does some extra bookwork that might not be immediately intuitive; see [Jody Hagins' comments](https://github.com/JoshuaGross/objc-ios-benchmarks/issues/1). If you use a weak pointer more than once in a particular code block, it makes sense to cast it back to a strong pointer in the lexical scope you're using it, so you only incur that performance penalty once.

### Benchmark Results (iOS 7, iPhone 5)
* Execution time of Weak pointer: 20.823044
* Execution time of Strong pointer: 12.632833

## BenchmarkTryCatch

Predictably, running code in a try/catch block as opposed to outside of a try/catch block is between 2-5 times slower.
 Actually throwing an error is extremely expensive. No surprises here. Don't use NSExceptions for flow control.

### Benchmark Results (iOS 7, iPhone 5)
* Execution time of No try/catch: 0.991090
* Execution time of Try/catch, no exception: 2.226909
* Execution time of Try/catch, exception: 3119.177997

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

### Benchmark Results (iOS 7, iPhone 5)
* Execution time of static character set: 1.799306
* Execution time of rangeOfString: 3.759440
* Execution time of character set: 6.714541
