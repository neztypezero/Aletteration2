//
//  NezAppDelegate.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAppDelegate.h"
#import "NezAletterationGameState.h"
#import "NezViewController.h"
#import "NezAletterationPrefs.h"

@implementation NezAppDelegate

-(BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
	return YES;
}

-(void)applicationWillResignActive:(UIApplication *)application {
	GLKView *view = (GLKView*)self.glkViewController.view;
	[NezAletterationGameState getPreferences].stateObject.snapshot = view.snapshot;
	[NezAletterationGameState savePreferences];
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

-(void)applicationWillTerminate:(UIApplication *)application {
// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window {
	return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(NezViewController*)getGLKViewController {
	return (NezViewController*)self.window.rootViewController;
}

#pragma mark access to app delegate etc.
+(NezAppDelegate*)sharedAppDelegate {
    return (NezAppDelegate*)[[UIApplication sharedApplication] delegate];
}

+(CGFloat)screenScale {
	static CGFloat scale = -1;
	if (scale < 0) {
		UIScreen *mainScreen = [UIScreen mainScreen];
		scale = mainScreen.scale;
	}
	return scale;
}

+(CGRect)getScreenBounds {
	return [NezAppDelegate sharedAppDelegate].glkViewController.view.bounds;
}

+(CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)orientation {
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds; //implicitly in Portrait orientation.
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation ==  UIInterfaceOrientationLandscapeLeft){
        CGRect temp = CGRectZero;
        temp.size.width = fullScreenRect.size.height;
        temp.size.height = fullScreenRect.size.width;
        fullScreenRect = temp;
    }
    return fullScreenRect;
}

@end
