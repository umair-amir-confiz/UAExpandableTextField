//
//  UAViewController.h
//  UAExpandableTextFieldExample
//
//  Created by Umair Aamir on 5/7/14.
//  Copyright (c) 2014 Confiz Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UAViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *label;

-(IBAction)leftAlign:(id)sender;
-(IBAction)centerAlign:(id)sender;
-(IBAction)rightAlign:(id)sender;


@end
