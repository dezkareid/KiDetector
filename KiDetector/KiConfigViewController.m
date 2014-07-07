//
//  KiConfigViewController.m
//  KiDetector
//
//  Created by Joel Humberto Gómez Paredes on 20/06/14.
//  Copyright (c) 2014 Joel Humberto Gómez Paredes. All rights reserved.
//

#import "KiConfigViewController.h"

@interface KiConfigViewController ()

@end



@implementation KiConfigViewController

@synthesize preferencias;
@synthesize texto;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    preferencias = [NSUserDefaults standardUserDefaults];
    NSString * palabra = [preferencias stringForKey:@"texto"];
    if (palabra.length>0) {
        texto.text = palabra;
    }else{
        texto.text = @"emprendedor";
        [preferencias setObject:@"emprendedor" forKey:@"texto"];
        [preferencias synchronize];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)cambio:(id)sender {
    if (texto.text.length>0) {
        [preferencias setObject:texto.text forKey:@"texto"];
        [preferencias synchronize];
    }
}
@end
