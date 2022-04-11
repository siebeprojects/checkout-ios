// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#import "ViewController.h"
#import "CheckoutObjC-Swift.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    [self.urlTextField becomeFirstResponder];
}

- (IBAction)sendRequest:(UIButton *)sender {
    NSURL *url = [[NSURL alloc] initWithString:self.urlTextField.text];

    Checkout *checkout = [[Checkout alloc] init];

    [checkout presentPaymentListFrom:self listURL:url completion:^(CheckoutResult * _Nonnull result) {
        [self presentAlertWithResult:result];
    }];
}

- (void)presentAlertWithResult:(CheckoutResult * _Nonnull)result {
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Payment Result" message: result.text preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil];
        [alertController addAction: okAction];
        [self presentViewController:alertController animated:true completion:nil];
    }];
}

@end
