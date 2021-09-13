// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#import "ViewController.h"
#import <PayoneerCheckout/PayoneerCheckout-Swift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)sendRequest:(UIButton *)sender {
    NSURL *url = [[NSURL alloc] initWithString:self.urlTextField.text];

    PaymentListViewController *paymentListViewController = [[PaymentListViewController alloc] initWithListResultURL:url];
    [self.navigationController pushViewController:paymentListViewController animated:true];
}

@end
