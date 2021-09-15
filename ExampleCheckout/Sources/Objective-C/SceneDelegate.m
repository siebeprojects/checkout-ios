// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#import "SceneDelegate.h"
#import <PayoneerCheckout/PayoneerCheckout-Swift.h>

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *url = URLContexts.allObjects.firstObject.URL;
    if (url != nil) {
        [NSNotificationCenter.defaultCenter postNotificationName:NSNotification.didReceivePaymentResultURL object:url];
    }
}

@end
