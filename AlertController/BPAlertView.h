//
//  BPAlertView.h
//  Backport
//
//  Created by Bhupendra Singh on 1/6/15.
//  Copyright (c) 2015 iBhupi. All rights reserved.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, BPAlertViewStyle)
{
    BPAlertViewStyleDefault = 0,
    BPAlertViewStyleSecureTextInput,
    BPAlertViewStylePlainTextInput,
    BPAlertViewStyleLoginAndPasswordInput
};

typedef void(^BPAlertViewCompletionBlock)(NSInteger tappedButtonIndex, NSString *tappedButtonTitle);

@interface BPAlertView : NSObject

+ (BPAlertView *)showAlertViewForTitle:(NSString *)title message:(NSString *)message style:(BPAlertViewStyle)bpAlertViewStyle fromViewController:(UIViewController *)fromViewController completionBlock:(BPAlertViewCompletionBlock)completionBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonsTitle:(NSString *)otherButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;

- (void)dismissWithAnimation:(BOOL)animated;

@end
