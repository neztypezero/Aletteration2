//
//  NezUIBarLabelItem.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-31.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NezUIBarLabelItem : UIBarButtonItem

@property(nonatomic,strong) UILabel *label;

-(id)initWithLabelText:(NSString*)labelText;

@end
