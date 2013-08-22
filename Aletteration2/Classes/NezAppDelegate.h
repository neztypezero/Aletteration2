//
//  NezAppDelegate.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class NezViewController;

@interface NezAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly, getter = getGLKViewController) NezViewController *glkViewController;

+(NezAppDelegate*)sharedAppDelegate;
+(CGFloat)screenScale;
+(CGRect)getScreenBounds;
+(CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)orientation;

@end
