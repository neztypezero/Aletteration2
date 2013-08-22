//
//  NezLoadingController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-18.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezEmbededController.h"

@interface NezLoadingController : NezEmbededController

@property(nonatomic, strong) IBOutlet UIImageView *logoImage;
@property(nonatomic, strong) IBOutlet UIProgressView *loadingProgressView;

@end
