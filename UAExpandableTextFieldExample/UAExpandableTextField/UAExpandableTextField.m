//
//  UAExpandableTextField.m
//
//  Created by Umair Aamir on 5/7/14.
//  Copyright (c) 2014 Confiz Limited. All rights reserved.
//

#import "UAExpandableTextField.h"
#import "UATextView.h"
#import "UITextField+PlaceholderColor.h"

@interface UAExpandableTextField() {
    
}
-(void)commonInitialiser;
-(void)resizeTextView:(NSInteger)newSizeH;
-(void)growDidStop;
@end

@implementation UAExpandableTextField
@synthesize internalTextView;
@synthesize delegate;
@synthesize maxHeight;
@synthesize minHeight;
@synthesize font;
@synthesize textColor;
@synthesize textAlignment;
@synthesize selectedRange;
@synthesize editable;
@synthesize dataDetectorTypes;
@synthesize animateHeightChange;
@synthesize animationDuration;
@synthesize returnKeyType;
@synthesize placeHolderLabel=_placeHolderLabel;
@dynamic placeholder;
@dynamic placeholderColor;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInitialiser];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInitialiser];
    }
    return self;
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
- (id)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    if ((self = [super initWithFrame:frame])) {
        [self commonInitialiser:textContainer];
    }
    return self;
}

-(void)commonInitialiser {
    [self commonInitialiser:nil];
}

-(void)commonInitialiser:(NSTextContainer *)textContainer
#else
-(void)commonInitialiser
#endif
{
    // Initialization code
    CGRect r = self.frame;
    r.origin.y = 0;
    r.origin.x = 0;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    internalTextView = [[UATextView alloc] initWithFrame:r textContainer:textContainer];
#else
    internalTextView = [[UATextView alloc] initWithFrame:r];
#endif
    internalTextView.delegate = self;
    internalTextView.scrollEnabled = NO;
    internalTextView.font = [UIFont fontWithName:@"Helvetica" size:13];
    internalTextView.contentInset = UIEdgeInsetsZero;
    internalTextView.showsHorizontalScrollIndicator = NO;
    internalTextView.text = @"-";
    internalTextView.contentMode = UIViewContentModeRedraw;
    [self addSubview:internalTextView];
    
    minHeight = internalTextView.frame.size.height;
    minNumberOfLines = 1;
    
    animateHeightChange = YES;
    animationDuration = 0.1f;
    
    internalTextView.text = @"";
    
    [self setMaxNumberOfLines:3];
    
    [self addSubview:self.placeHolderLabel];
    [self setPlaceholderColor:[UIColor lightGrayColor]];
    self.placeHolderLabel.hidden = NO;
    
}

-(CGSize)sizeThatFits:(CGSize)size
{
    if (self.text.length == 0) {
        size.height = minHeight;
    }
    return size;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
	CGRect r = self.bounds;
	r.origin.y = 0;
	r.origin.x = contentInset.left;
    r.size.width -= contentInset.left + contentInset.right;
    internalTextView.frame = r;
}

-(void)setContentInset:(UIEdgeInsets)inset
{
    contentInset = inset;
    
    CGRect r = self.frame;
    r.origin.y = inset.top - inset.bottom;
    r.origin.x = inset.left;
    r.size.width -= inset.left + inset.right;
    
    internalTextView.frame = r;
    
    [self setMaxNumberOfLines:maxNumberOfLines];
    [self setMinNumberOfLines:minNumberOfLines];
}

-(UIEdgeInsets)contentInset
{
    return contentInset;
}

-(void)setMaxNumberOfLines:(int)n
{
    if(n == 0 && maxHeight > 0) return; // the user specified a maxHeight themselves.
    
    // Use internalTextView for height calculations, thanks to Gwynne <http://blog.darkrainfall.org/>
    NSString *saveText = internalTextView.text, *newText = @"-";
    
    internalTextView.delegate = nil;
    internalTextView.hidden = YES;
    
    for (int i = 1; i < n; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    internalTextView.text = newText;
    
    maxHeight = [self measureHeight];
    
    internalTextView.text = saveText;
    internalTextView.hidden = NO;
    internalTextView.delegate = self;
    
    [self sizeToFit];
    
    maxNumberOfLines = n;
}

-(int)maxNumberOfLines
{
    return maxNumberOfLines;
}

- (void)setMaxHeight:(int)height
{
    maxHeight = height;
    maxNumberOfLines = 0;
}

-(void)setMinNumberOfLines:(int)m
{
    if(m == 0 && minHeight > 0) return; // the user specified a minHeight themselves.
    
    NSString *saveText = internalTextView.text, *newText = @"-";
    
    internalTextView.delegate = nil;
    internalTextView.hidden = YES;
    
    for (int i = 1; i < m; ++i)
        newText = [newText stringByAppendingString:@"\n|W|"];
    
    internalTextView.text = newText;
    
    minHeight = [self measureHeight];
    
    internalTextView.text = saveText;
    internalTextView.hidden = NO;
    internalTextView.delegate = self;
    
    [self sizeToFit];
    
    minNumberOfLines = m;
}

-(int)minNumberOfLines
{
    return minNumberOfLines;
}

- (void)setMinHeight:(int)height
{
    minHeight = height;
    minNumberOfLines = 0;
}

- (NSString *)placeholder
{
    return self.placeHolderLabel.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    [self.placeHolderLabel setPlaceholder:placeholder];
}

- (UIColor *)placeholderColor
{
    return self.placeHolderLabel.textColor;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    [self.placeHolderLabel setPlaceholderColor:placeholderColor];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self refreshHeight];
}

- (void)refreshHeight
{
	//size of content, so we can set the frame of self
	NSInteger newSizeH = [self measureHeight];
	if (newSizeH < minHeight || !internalTextView.hasText) {
        newSizeH = minHeight; //not smalles than minHeight
    }
    else if (maxHeight && newSizeH > maxHeight) {
        newSizeH = maxHeight; // not taller than maxHeight
    }
    
	if (internalTextView.frame.size.height != newSizeH)
	{
        // if our new height is greater than the maxHeight
        // sets not set the height or move things
        // around and enable scrolling
        if (newSizeH >= maxHeight)
        {
            if(!internalTextView.scrollEnabled){
                internalTextView.scrollEnabled = YES;
                [internalTextView flashScrollIndicators];
            }
            
        } else {
            internalTextView.scrollEnabled = NO;
        }
        
		if (newSizeH <= maxHeight)
		{
            if(animateHeightChange) {
                
                if ([UIView resolveClassMethod:@selector(animateWithDuration:animations:)]) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
                    [UIView animateWithDuration:animationDuration
                                          delay:0
                                        options:(UIViewAnimationOptionAllowUserInteraction|
                                                 UIViewAnimationOptionBeginFromCurrentState)
                                     animations:^(void) {
                                         [self resizeTextView:newSizeH];
                                     }
                                     completion:^(BOOL finished) {
                                         if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                                             [delegate growingTextView:self didChangeHeight:newSizeH];
                                         }
                                     }];
#endif
                } else {
                    [UIView beginAnimations:@"" context:nil];
                    [UIView setAnimationDuration:animationDuration];
                    [UIView setAnimationDelegate:self];
                    [UIView setAnimationDidStopSelector:@selector(growDidStop)];
                    [UIView setAnimationBeginsFromCurrentState:YES];
                    [self resizeTextView:newSizeH];
                    [UIView commitAnimations];
                }
            } else {
                [self resizeTextView:newSizeH];
                
                if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
                    [delegate growingTextView:self didChangeHeight:newSizeH];
                }
            }
		}
	}
    // Display (or not) the placeholder string
    self.placeHolderLabel.hidden = self.internalTextView.text.length != 0;
    if (!self.placeHolderLabel.hidden) {
        [self.placeHolderLabel becomeFirstResponder];
    }
    
    
    // scroll to caret (needed on iOS7)
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        [self performSelector:@selector(resetScrollPositionForIOS7) withObject:nil afterDelay:0.1f];
    }
    
    // Tell the delegate that the text view changed
    if ([delegate respondsToSelector:@selector(growingTextViewDidChange:)]) {
		[delegate growingTextViewDidChange:self];
	}
}

- (CGFloat)measureHeight
{
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        return ceilf([self.internalTextView sizeThatFits:self.internalTextView.frame.size].height);
    }
    else {
        return self.internalTextView.contentSize.height;
    }
}

- (void)resetScrollPositionForIOS7
{
    CGRect r = [internalTextView caretRectForPosition:internalTextView.selectedTextRange.end];
    CGFloat caretY =  MAX(r.origin.y - internalTextView.frame.size.height + r.size.height + 8, 0);
    if (internalTextView.contentOffset.y < caretY && r.origin.y != INFINITY)
        internalTextView.contentOffset = CGPointMake(0, caretY);
}

-(void)resizeTextView:(NSInteger)newSizeH
{
    if ([delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
        [delegate growingTextView:self willChangeHeight:newSizeH];
    }
    
    CGRect internalTextViewFrame = self.frame;
    internalTextViewFrame.size.height = newSizeH; // + padding
    self.frame = internalTextViewFrame;
    
    internalTextViewFrame.origin.y = contentInset.top - contentInset.bottom;
    internalTextViewFrame.origin.x = contentInset.left;
    
    if(!CGRectEqualToRect(internalTextView.frame, internalTextViewFrame)) internalTextView.frame = internalTextViewFrame;
}

- (void)growDidStop
{
    // scroll to caret (needed on iOS7)
    if ([self respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        [self resetScrollPositionForIOS7];
    }
    
	if ([delegate respondsToSelector:@selector(growingTextView:didChangeHeight:)]) {
		[delegate growingTextView:self didChangeHeight:self.frame.size.height];
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [internalTextView becomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [super becomeFirstResponder];
    if (![self.internalTextView hasText])
    {
        [self.placeHolderLabel becomeFirstResponder];
        return YES;
    }
    return [self.internalTextView becomeFirstResponder];
}

-(BOOL)resignFirstResponder
{
	[super resignFirstResponder];
    // if placeholder textfield has keyboard focus
    [self.placeHolderLabel resignFirstResponder];
	return [internalTextView resignFirstResponder];
}

-(BOOL)isFirstResponder
{
    return [self.internalTextView isFirstResponder];
}



///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITextView properties
///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setText:(NSString *)newText
{
    internalTextView.text = newText;
    
    // include this line to analyze the height of the textview.
    // fix from Ankit Thakur
    [self performSelector:@selector(textViewDidChange:) withObject:internalTextView];
}

-(NSString*) text
{
    return internalTextView.text;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setFont:(UIFont *)afont
{
	internalTextView.font= afont;
    self.placeHolderLabel.font = afont;
	
	[self setMaxNumberOfLines:maxNumberOfLines];
	[self setMinNumberOfLines:minNumberOfLines];
}

-(UIFont *)font
{
	return internalTextView.font;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setTextColor:(UIColor *)color
{
	internalTextView.textColor = color;
}

-(UIColor*)textColor{
	return internalTextView.textColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
	internalTextView.backgroundColor = backgroundColor;
    self.placeHolderLabel.backgroundColor = backgroundColor;
    [self.placeHolderLabel setSelectedTextRange:[self.placeHolderLabel textRangeFromPosition:self.placeHolderLabel.beginningOfDocument toPosition:self.placeHolderLabel.beginningOfDocument]];
}

-(UIColor*)backgroundColor
{
    return internalTextView.backgroundColor;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setTextAlignment:(NSTextAlignment)aligment
{
	internalTextView.textAlignment = aligment;
    self.placeHolderLabel.textAlignment = aligment;
}

-(NSTextAlignment)textAlignment
{
	return internalTextView.textAlignment;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setSelectedRange:(NSRange)range
{
	internalTextView.selectedRange = range;
}

-(NSRange)selectedRange
{
	return internalTextView.selectedRange;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setIsScrollable:(BOOL)isScrollable
{
    internalTextView.scrollEnabled = isScrollable;
}

- (BOOL)isScrollable
{
    return internalTextView.scrollEnabled;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setEditable:(BOOL)beditable
{
	internalTextView.editable = beditable;
}

-(BOOL)isEditable
{
	return internalTextView.editable;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setReturnKeyType:(UIReturnKeyType)keyType
{
	internalTextView.returnKeyType = keyType;
}

-(UIReturnKeyType)returnKeyType
{
	return internalTextView.returnKeyType;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setKeyboardType:(UIKeyboardType)keyType
{
	internalTextView.keyboardType = keyType;
}

- (UIKeyboardType)keyboardType
{
	return internalTextView.keyboardType;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically
{
    internalTextView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
}

- (BOOL)enablesReturnKeyAutomatically
{
    return internalTextView.enablesReturnKeyAutomatically;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

-(void)setDataDetectorTypes:(UIDataDetectorTypes)datadetector
{
	internalTextView.dataDetectorTypes = datadetector;
}

-(UIDataDetectorTypes)dataDetectorTypes
{
	return internalTextView.dataDetectorTypes;
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)hasText{
	return [internalTextView hasText];
}

- (void)scrollRangeToVisible:(NSRange)range
{
	[internalTextView scrollRangeToVisible:range];
}

/////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)]) {
		return [delegate growingTextViewShouldBeginEditing:self];
		
	} else {
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	if ([delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)]) {
		return [delegate growingTextViewShouldEndEditing:self];
		
	} else {
		return YES;
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if ([delegate respondsToSelector:@selector(growingTextViewDidBeginEditing:)]) {
		[delegate growingTextViewDidBeginEditing:self];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidEndEditing:(UITextView *)textView
{
	if ([delegate respondsToSelector:@selector(growingTextViewDidEndEditing:)]) {
		[delegate growingTextViewDidEndEditing:self];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)atext
{
	if(![textView hasText] && [atext isEqualToString:@""]) return NO;
	
    if ([delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)])
        return [delegate growingTextView:self shouldChangeTextInRange:range replacementText:atext];
	
	if ([atext isEqualToString:@"\n"]) {
		if ([delegate respondsToSelector:@selector(growingTextViewShouldReturn:)]) {
			if (![delegate performSelector:@selector(growingTextViewShouldReturn:) withObject:self]) {
				return YES;
			} else {
				[textView resignFirstResponder];
				return NO;
			}
		}
	}
	
	return YES;
	
    
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)textViewDidChangeSelection:(UITextView *)textView
{
	if ([delegate respondsToSelector:@selector(growingTextViewDidChangeSelection:)])
    {
		[delegate growingTextViewDidChangeSelection:self];
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // passing the focus to main textview from placeholder textfield
    self.text = string;
    [self.internalTextView becomeFirstResponder];
    return NO;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
-(UITextField*)placeHolderLabel
{
    if (!_placeHolderLabel)
    {
        _placeHolderLabel = [[UITextField alloc] initWithFrame:CGRectZero];
        _placeHolderLabel.font = self.font;
        _placeHolderLabel.textAlignment = self.textAlignment;
        _placeHolderLabel.delegate = (id)self;
    }
    CGRect frame = CGRectMake(self.contentInset.left, self.contentInset.top, self.internalTextView.frame.size.width - 2*self.contentInset.left, self.internalTextView.frame.size.height);
    _placeHolderLabel.frame = frame;
    return _placeHolderLabel;
}


@end
