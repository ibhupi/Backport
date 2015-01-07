//
//  BPAlertView.m
//  Backport
//
//  Created by Bhupendra Singh on 1/6/15.
//  Copyright (c) 2015 iBhupi. All rights reserved.
//
// CAJMacros
// https://github.com/carlj/CJAMacros/blob/master/CJAMacros/CJAMacros.h
//

#import "BPAlertView.h"

#define BP_SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define BP_SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define BP_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define BP_SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define BP_SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

BPAlertView *bpAlertView;

@interface BPAlertView () <UIAlertViewDelegate>

@property (nonatomic, strong) BPAlertViewCompletionBlock completionBlock;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *cancelButtonTitle;
@property (strong, nonatomic) NSArray  *otherButtonTitles;

@property (nonatomic) BPAlertViewStyle bpAlertViewStyle;

@property (strong, nonatomic) UIAlertView *alertView;
@property (strong, nonatomic) UIAlertController *alertController;
@property (nonatomic, weak) UIViewController *fromViewController;

@end

@implementation BPAlertView

//+ (BPAlertView *)showAlertViewForTitle:(NSString *)title message:(NSString *)message completionBlock:(BPAlertViewCompletionBlock)completionBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonsTitle:(NSString *)otherButtonTitle, ...
+ (BPAlertView *)showAlertViewForTitle:(NSString *)title message:(NSString *)message style:(BPAlertViewStyle)bpAlertViewStyle fromViewController:(UIViewController *)fromViewController completionBlock:(BPAlertViewCompletionBlock)completionBlock cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonsTitle:(NSString *)otherButtonTitle, ...
{
    if (!title.length || !message.length)
    {
        // NSLog(@"Alertview without title or message ??");
        return nil;
    }
    BPAlertView *alertView = [self new];
    
    if (!alertView)
    {
        return nil;
    }
    alertView.title = title;
    alertView.message = message;
    alertView.cancelButtonTitle = cancelButtonTitle;
    alertView.completionBlock = completionBlock;
    alertView.bpAlertViewStyle = bpAlertViewStyle;
    alertView.fromViewController = fromViewController;
    
    NSMutableArray *buttonTitles = [NSMutableArray new];
    va_list args;
    va_start(args, otherButtonTitle);
    for (id arg = otherButtonTitle; arg != nil; arg = va_arg(args, NSString*))
    {
        if (arg && [arg isKindOfClass:[NSString class]])
        {
            [buttonTitles addObject:[arg copy]];
        }
    }
    va_end(args);
    alertView.otherButtonTitles = buttonTitles;
    
    if (!alertView.cancelButtonTitle.length &&
        !alertView.otherButtonTitles.count)
    {
        alertView.cancelButtonTitle = @"OK";
    }
    
    if (BP_SYSTEM_VERSION_LESS_THAN(@"8.0"))
    {
        [alertView showiOS7ORLessAlert];
    }
    else
    {
        [alertView showiOS8Alert];
    }

    return alertView;
}

- (void)dismissWithAnimation:(BOOL)animated
{
    if (self.alertView)
    {
        [self.alertView dismissWithClickedButtonIndex:self.alertView.cancelButtonIndex animated:animated];
    }
    else if (self.alertController)
    {
        [self.alertController dismissViewControllerAnimated:animated completion:nil];
    }
}

- (void)showiOS8Alert
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:self.title message:self.message preferredStyle:UIAlertControllerStyleAlert];
    self.alertController = alertController;
    
    if (self.cancelButtonTitle.length)
    {
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:self.cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:^{
            }];
            [self tappedButtonIndex:0 buttonTitle:action.title];
            bpAlertView = nil;
        }];
        [alertController addAction:cancelAction];
    }
    
    for (NSString *buttonTitle in self.otherButtonTitles)
    {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alertController dismissViewControllerAnimated:YES completion:^{
            }];
            NSInteger index = 1;
            for (NSString *buttonTitle in self.otherButtonTitles)
            {
                if (buttonTitle == action.title)
                {
                    break;
                }
                index++;
            }
            [self tappedButtonIndex:index buttonTitle:action.title];
            bpAlertView = nil;
        }];
        [alertController addAction:alertAction];
    }
    
    UIViewController *fromViewController = self.fromViewController;
    if (!fromViewController)
    {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window)
        {
            window = [[[UIApplication sharedApplication] windows] lastObject];
        }
        if (!window.isKeyWindow)
        {
            [window makeKeyAndVisible];
        }
        fromViewController = window.rootViewController;
    }
    [fromViewController presentViewController:alertController animated:YES completion:^{
        bpAlertView = self;
    }];
}

- (void)showiOS7ORLessAlert
{
    BPAlertView *delegate = self.completionBlock ? self : nil;
    if (delegate)
    {
        bpAlertView = self;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:self.title message:self.message delegate:delegate cancelButtonTitle:self.cancelButtonTitle otherButtonTitles:nil];
    if (self.bpAlertViewStyle > UIAlertViewStyleDefault &&
        self.bpAlertViewStyle < UIAlertViewStyleLoginAndPasswordInput)
    {
        alertView.alertViewStyle = (UIAlertViewStyle)self.bpAlertViewStyle;
    }
    self.alertView = alertView;
    
    for (NSString *buttonTitle in self.otherButtonTitles)
    {
        [alertView addButtonWithTitle:buttonTitle];
    }
    [alertView show];
}

- (void)tappedButtonIndex:(NSInteger)tappedButtonIndex buttonTitle:(NSString *)tappedButtonTitle
{
    if (self.completionBlock)
    {
        self.completionBlock(tappedButtonIndex, tappedButtonTitle);
    }
    self.completionBlock = nil;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    buttonIndex = buttonIndex == alertView.cancelButtonIndex ? buttonIndex :  + 1;
    [self tappedButtonIndex:buttonIndex buttonTitle:buttonTitle];
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    [self tappedButtonIndex:alertView.cancelButtonIndex buttonTitle:@""];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    bpAlertView = nil;
}

@end
