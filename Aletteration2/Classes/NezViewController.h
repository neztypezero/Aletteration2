//
//  NezViewController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface NezViewController : GLKViewController {
}

@property(nonatomic, weak) IBOutlet UIView *loadingEmbedView;
@property(nonatomic, weak) IBOutlet UIView *commandsEmbedView;
@property(nonatomic, weak) IBOutlet UIImageView *snapshotImageView;

@property(nonatomic, weak) UINavigationController *commandsNavigationController;

@end
