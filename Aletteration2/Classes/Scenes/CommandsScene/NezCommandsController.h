//
//  NezCommandsController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NezCommandsController : UIViewController<UIPopoverControllerDelegate>

@property(nonatomic, weak) IBOutlet UIView *dialogEmbedView;
@property(nonatomic, weak) UINavigationController *dialogNavController;
@property(nonatomic, weak) IBOutlet UIImageView *logoImageView;

-(IBAction)showOptionsPopover:(UIButton*)sender;
-(IBAction)showHighScoresPopover:(UIButton*)sender;
-(IBAction)showRulesPopover:(UIButton*)sender;

-(IBAction)showOptionsDialog:(id)sender;
-(IBAction)showHighScoresDialog:(id)sender;
-(IBAction)showRulesDialog:(id)sender;

-(IBAction)showCreditsDialog:(id)sender;

-(void)showDialog:(NSString*)segueID;

-(IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue;

@end
