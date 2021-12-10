// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#import "ViewController.h"
@import PayoneerCheckout;

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

    PaymentListViewController *paymentListViewController = [[PaymentListViewController alloc] initWithListResultURL:url];
    paymentListViewController.delegate = self;
    [self.navigationController pushViewController:paymentListViewController animated:true];
}

#pragma mark - PaymentDelegate

- (void)paymentServiceWithDidReceivePaymentResult:(PaymentResult * _Nonnull)paymentResult viewController:(PaymentListViewController * _Nonnull)viewController {
    [self.navigationController popViewControllerAnimated:true];

    NSString *resultInfo = [NSString stringWithFormat:@"ResultInfo: %@", paymentResult.resultInfo];
    NSString *interactionCode = [NSString stringWithFormat:@"Interaction code: %@", paymentResult.interaction.code];
    NSString *interactionReason = [NSString stringWithFormat:@"Interaction reason: %@", paymentResult.interaction.reason];

    // Construct error message
    NSString *paymentErrorText = @"Error: n/a";

    if (paymentResult.cause != nil) {
        paymentErrorText = [NSString stringWithFormat:@"Error: %@", paymentResult.cause];
    }

    NSString *message = [NSString stringWithFormat:@"%@\n%@\n%@\n%@", resultInfo, interactionCode, interactionReason, paymentErrorText];

    // Present alert
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle: @"Payment result" message: message preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle: @"Ok" style: UIAlertActionStyleDefault handler: nil];
    [alertController addAction: okAction];
    [self presentViewController:alertController animated:true completion:nil];
}

@end
