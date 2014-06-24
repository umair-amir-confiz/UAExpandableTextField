//
//  UAViewController.m
//  UAExpandableTextFieldExample
//
//  Created by Umair Aamir on 5/7/14.
//  Copyright (c) 2014 Confiz Limited. All rights reserved.
//

#import "UAViewController.h"
#import "UAExpandableTextField.h"

@interface UAViewController ()
{

}
@property (nonatomic, readonly) IBOutlet UAExpandableTextField *expandableTextField;
@end

@implementation UAViewController

@synthesize expandableTextField=_expandableTextField;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupExpandableTextField];
	
}

-(void)setupExpandableTextField
{
    // setting expandable textview properties
    [_expandableTextField becomeFirstResponder];
    [_expandableTextField setPlaceholder:@"Type Here..."];
    [_expandableTextField setTextColor:[UIColor redColor]];
    [_expandableTextField setDelegate:(id)self];
    [_expandableTextField setTextAlignment:NSTextAlignmentLeft];
    [_expandableTextField setBackgroundColor:[UIColor blackColor]];
    [_expandableTextField setMaxNumberOfLines:6];
    [_expandableTextField setFont:[UIFont fontWithName:@"Helvetica" size:19.0f]];
    [_expandableTextField setPlaceholderColor:[UIColor blueColor]];
}


-(IBAction)leftAlign:(id)sender
{
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.text = @"Left Aligned Text";
    [_expandableTextField setTextAlignment:NSTextAlignmentLeft];
}

-(IBAction)centerAlign:(id)sender
{
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.text = @"Center Aligned Text";
    [_expandableTextField setTextAlignment:NSTextAlignmentCenter];
}

-(IBAction)rightAlign:(id)sender
{
    self.label.textAlignment = NSTextAlignmentRight;
    self.label.text = @"Right Aligned Text";
    [_expandableTextField setTextAlignment:NSTextAlignmentRight];
}

@end
