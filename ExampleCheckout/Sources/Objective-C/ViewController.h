// Copyright (c) 2021 Payoneer Germany GmbH
// https://www.payoneer.com
//
// This file is open source and available under the MIT license.
// See the LICENSE file for more information.

#import <UIKit/UIKit.h>
@import PayoneerCheckout;

@interface ViewController: UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
- (IBAction)sendRequest:(UIButton *)sender;

@end

