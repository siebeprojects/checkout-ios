// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#import "AppDelegate.h"
@import PayoneerCheckout;

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [NSNotificationCenter.defaultCenter postNotificationName:NSNotification.didReceivePaymentResultURL object:url];
    return YES;
}

@end
