//
//  KiConfigViewController.h
//  KiDetector
//
//  Created by Joel Humberto Gómez Paredes on 20/06/14.
//  Copyright (c) 2014 Joel Humberto Gómez Paredes. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KiConfigViewController : UITableViewController
@property (nonatomic, weak) NSUserDefaults *preferencias;
@property (weak, nonatomic) IBOutlet UITextField *texto;
- (IBAction)cambio:(id)sender;


@end
