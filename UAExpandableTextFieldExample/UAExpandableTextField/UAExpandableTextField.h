//
//  UAExpandableTextField.h
//
//  Created by Umair Aamir on 5/7/14.
//  Copyright (c) 2014 Confiz Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 60000
	// UITextAlignment is deprecated in iOS 6.0+, use NSTextAlignment instead.
	// Reference: https://developer.apple.com/library/ios/documentation/uikit/reference/NSString_UIKit_Additions/Reference/Reference.html
	#define NSTextAlignment UITextAlignment
#endif

@class UAExpandableTextField;
@class UATextView;

@protocol UAExpandableTextFieldDelegate

@optional
- (BOOL)growingTextViewShouldBeginEditing:(UAExpandableTextField *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(UAExpandableTextField *)growingTextView;

- (void)growingTextViewDidBeginEditing:(UAExpandableTextField *)growingTextView;
- (void)growingTextViewDidEndEditing:(UAExpandableTextField *)growingTextView;

- (BOOL)growingTextView:(UAExpandableTextField *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)growingTextViewDidChange:(UAExpandableTextField *)growingTextView;

- (void)growingTextView:(UAExpandableTextField *)growingTextView willChangeHeight:(float)height;
- (void)growingTextView:(UAExpandableTextField *)growingTextView didChangeHeight:(float)height;

- (void)growingTextViewDidChangeSelection:(UAExpandableTextField *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(UAExpandableTextField *)growingTextView;
@end

@interface UAExpandableTextField : UIView <UITextViewDelegate, UITextFieldDelegate> {
	UATextView *internalTextView;
	
	int minHeight;
	int maxHeight;
	
	//class properties
	int maxNumberOfLines;
	int minNumberOfLines;
	
	BOOL animateHeightChange;
    NSTimeInterval animationDuration;
	
	//uitextview properties
	NSObject <UAExpandableTextFieldDelegate> *__unsafe_unretained delegate;
	NSTextAlignment textAlignment;
	NSRange selectedRange;
	BOOL editable;
	UIDataDetectorTypes dataDetectorTypes;
	UIReturnKeyType returnKeyType;
	UIKeyboardType keyboardType;
    
    UIEdgeInsets contentInset;
}

//real class properties
@property int maxNumberOfLines;
@property int minNumberOfLines;
@property (nonatomic) int maxHeight;
@property (nonatomic) int minHeight;
@property BOOL animateHeightChange;
@property NSTimeInterval animationDuration;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;
@property (nonatomic, strong) UITextView *internalTextView;
@property (nonatomic, readonly) UITextField *placeHolderLabel;


//uitextview properties
@property(unsafe_unretained) NSObject<UAExpandableTextFieldDelegate> *delegate;
@property(nonatomic,strong) NSString *text;
@property(nonatomic,strong) UIFont *font;
@property(nonatomic,strong) UIColor *textColor;
@property(nonatomic) NSTextAlignment textAlignment;    // default is NSTextAlignmentLeft
@property(nonatomic) NSRange selectedRange;            // only ranges of length 0 are supported
@property(nonatomic,getter=isEditable) BOOL editable;
@property(nonatomic) UIDataDetectorTypes dataDetectorTypes __OSX_AVAILABLE_STARTING(__MAC_NA, __IPHONE_3_0);
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic) UIKeyboardType keyboardType;
@property (assign) UIEdgeInsets contentInset;
@property (nonatomic) BOOL isScrollable;
@property(nonatomic) BOOL enablesReturnKeyAutomatically;

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer;
#endif

//uitextview methods
//need others? use .internalTextView
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (BOOL)isFirstResponder;

- (BOOL)hasText;
- (void)scrollRangeToVisible:(NSRange)range;

// call to force a height change (e.g. after you change max/min lines)
- (void)refreshHeight;

@end
