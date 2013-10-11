//
//  JGAppDelegate.m
//  TryCatchBenchmark
//
//  Created by Joshua Gross on 9/19/13.
//  Copyright (c) 2013 Yahoo! Inc. All rights reserved.
//

#import "JGAppDelegate.h"

@implementation JGAppDelegate

- (void)measureBlockExecutionTime:(void (^)(void))block withFactor:(NSUInteger)cheatFactor withLabel:(NSString *)label
{
    NSDate *before = [NSDate date];
    block();
    NSDate *apres = [NSDate date];
    NSLog(@"Execution time of %@: %f", label, [apres timeIntervalSinceDate:before]*cheatFactor);
}

- (void)measureBlockExecutionTime:(void (^)(void))block withLabel:(NSString *)label
{
    [self measureBlockExecutionTime:block withFactor:1 withLabel:label];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    NSInteger numExecutions = 100000000;

    [self measureBlockExecutionTime:^{
        for (NSInteger i = 0; i < numExecutions; i++) {
            NSInteger j = i+1;
            j += 1;
        }
    } withLabel:@"No try/catch"];

    [self measureBlockExecutionTime:^{
        for (NSInteger i = 0; i < numExecutions; i++) {
            @try {
                NSInteger j = i+1;
                j += 1;
            }
            @catch (NSException *exception) {
                NSLog(@"how did you get here?");
            }
            @finally {
            }
        }
    } withLabel:@"Try/catch, no exception"];

    [self measureBlockExecutionTime:^{
        for (NSInteger i = 0; i < numExecutions/1000; i++) {
            @try {
                NSInteger j = i+1;
                j += 1;
                [NSException raise:@"RAGE" format:@"RAGE RAGE RAGE"];
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
        }
    } withFactor:1000 withLabel:@"Try/catch, exception"];


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
