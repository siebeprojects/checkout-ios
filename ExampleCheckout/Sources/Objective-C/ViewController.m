// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#import "ViewController.h"
@import PayoneerCheckout;
@import IovationRiskProvider;

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
    
    CheckoutConfiguration *configuration = [[CheckoutConfiguration alloc] initWithListURL:url appearance:NULL riskProviderClasses:@[[IovationRiskProvider class]] error:NULL];

    Checkout *checkout = [[Checkout alloc] initWithConfiguration:configuration];
    [checkout presentPaymentListFrom:self completion:^(CheckoutResult * _Nonnull result) {
        [self presentAlertWithResult:result];
    }];
}

- (void)presentAlertWithResult:(CheckoutResult * _Nonnull)result {
    NSString *resultInfo = [NSString stringWithFormat:@"ResultInfo: %@", result.resultInfo];
    NSString *interactionCode = [NSString stringWithFormat:@"Interaction code: %@", result.interaction.code];
    NSString *interactionReason = [NSString stringWithFormat:@"Interaction reason: %@", result.interaction.reason];

    // Construct error message
    NSString *paymentErrorText = @"Error: n/a";

    if (result.cause != nil) {
        paymentErrorText = [NSString stringWithFormat:@"Error: %@", result.cause];
    }

    NSString *message = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", resultInfo, interactionCode, interactionReason, paymentErrorText];

    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Payment Result" message: message preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"OK" style: UIAlertActionStyleDefault handler: nil];
        [alertController addAction: okAction];
        [self presentViewController:alertController animated:true completion:nil];
    }];
}

@end
