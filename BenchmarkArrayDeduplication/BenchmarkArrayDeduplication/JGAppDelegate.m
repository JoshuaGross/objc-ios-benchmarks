//
//  JGAppDelegate.m
//  BenchmarkArrayDeduplication
//
//  Created by Joshua Gross on 10/7/13.
//  Copyright (c) 2013 JGross. All rights reserved.
//

#import "JGAppDelegate.h"

@implementation JGAppDelegate

- (CGFloat)measureBlockExecutionTime:(void (^)(void))block withLabel:(NSString *)label
{
    NSDate *before = [NSDate date];
    block();
    NSDate *apres = [NSDate date];
    CGFloat interval = [apres timeIntervalSinceDate:before];
    NSLog(@"Execution time of %@: %f", label, interval);
    return interval;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    NSUInteger numExecutions = 5000;
    NSUInteger arraySize = 40;

    for (NSUInteger run = 0; run < 2; run++) {
        NSMutableArray *dataMutable = [[NSMutableArray alloc] initWithCapacity:arraySize];
        NSMutableArray *oldDataMutable = [[NSMutableArray alloc] initWithCapacity:arraySize];
        NSString *dupeStatus;

        for (NSUInteger j = 0; j < arraySize; j++) {
            [dataMutable addObject:[NSNumber numberWithInt:j]];
        }

        void (^verifyResult)(NSArray *) = ^(NSArray *dedupedArray) {
//            if (run == 1) NSLog(@"%@", [dedupedArray lastObject]);
            NSAssert([[dedupedArray lastObject] integerValue] == (run == 0 ? arraySize - 1 : (int)(arraySize*0.75 - 1)), @"");
        };

        if (run == 0) {
            dupeStatus = @"no duplicates";
            for (NSUInteger j = 0; j < arraySize; j++) {
                [oldDataMutable addObject:[NSNumber numberWithInt:j+(arraySize*2)]];
            }
        } else {
            dupeStatus = @"with duplicates";
            for (NSUInteger j = 0; j < arraySize; j++) {
                [oldDataMutable addObject:[NSNumber numberWithInt:j+(arraySize*0.75)]];
            }
        }

        NSLog(@"Running suite: %@", dupeStatus);



        NSArray *data = [NSArray arrayWithArray:dataMutable];
        NSArray *oldData = [NSArray arrayWithArray:oldDataMutable];

        [self measureBlockExecutionTime:^(void){
            for (NSUInteger i = 0; i < numExecutions; i++) {
                NSMutableArray *dedupedArray = [[NSMutableArray alloc] initWithCapacity:50];

                // Enumerate over new data, find data that is not duped in the old data
                [data enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
                    __block BOOL dup = NO;
                    [oldData enumerateObjectsUsingBlock:^(NSNumber *obj2, NSUInteger idx, BOOL *stop){
                        if ([obj integerValue] == [obj2 integerValue]) {
                            *stop = YES;
                            dup = YES;
                        }
                    }];
                    if (!dup) {
                        [dedupedArray addObject:obj];
                    }
                }];

                verifyResult(dedupedArray);
            }
        } withLabel:[NSString stringWithFormat:@"Explicit enumeration, O(n^2) %@", dupeStatus]];

        [self measureBlockExecutionTime:^(void){
            for (NSUInteger i = 0; i < numExecutions; i++) {
                NSMutableArray *dedupedArray = [[NSMutableArray alloc] initWithCapacity:50];

                // Enumerate over new data, find data that is not duped in the old data
                [data enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
                    NSUInteger dupIndex = [oldData indexOfObjectPassingTest:^BOOL(NSNumber *obj2, NSUInteger idx, BOOL *stop) {
                        if ([obj integerValue] == [obj2 integerValue]) {
                            *stop = YES;
                        }
                        return *stop;
                    }];
                    BOOL dup = (dupIndex != NSNotFound);
                    if (!dup) {
                        [dedupedArray addObject:obj];
                    }
                }];

                verifyResult(dedupedArray);
            }
        } withLabel:[NSString stringWithFormat:@"Get first matching object with indexOfObjectPassingTest %@", dupeStatus]];

        [self measureBlockExecutionTime:^(void){
            for (NSUInteger i = 0; i < numExecutions; i++) {
                NSMutableArray *dedupedArray = [[NSMutableArray alloc] initWithCapacity:50];

                // Enumerate over new data, find data that is not duped in the old data
                [data enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
                    BOOL dup = [oldData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF = %@", obj]].count > 0;
                    if (!dup) {
                        [dedupedArray addObject:obj];
                    }
                }];

                verifyResult(dedupedArray);
            }
        } withLabel:[NSString stringWithFormat:@"Get all matching objects with predicate %@", dupeStatus]];

        [self measureBlockExecutionTime:^(void){
            for (NSUInteger i = 0; i < numExecutions; i++) {
                NSMutableArray *dedupedArray = [[NSMutableArray alloc] initWithCapacity:50];
                NSSet *oldDataSet = [NSSet setWithArray:oldData];

                // Enumerate over new data, find data that is not duped in the old data
                [data enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
                    BOOL dup = [oldDataSet containsObject:obj];
                    if (!dup) {
                        [dedupedArray addObject:obj];
                    }
                }];

                verifyResult(dedupedArray);
            }
        } withLabel:[NSString stringWithFormat:@"NSSet %@", dupeStatus]];

        [self measureBlockExecutionTime:^(void){
            for (NSUInteger i = 0; i < numExecutions; i++) {
                NSMutableArray *dedupedArray = [[NSMutableArray alloc] initWithCapacity:50];
                NSDictionary *oldDataDict = [NSDictionary dictionaryWithObjects:oldData forKeys:oldData];

                // Enumerate over new data, find data that is not duped in the old data
                [data enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
                    BOOL dup = [oldDataDict objectForKey:obj] != nil;
                    if (!dup) {
                        [dedupedArray addObject:obj];
                    }
                }];

                verifyResult(dedupedArray);
            }
        } withLabel:[NSString stringWithFormat:@"NSDictionary %@", dupeStatus]];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
