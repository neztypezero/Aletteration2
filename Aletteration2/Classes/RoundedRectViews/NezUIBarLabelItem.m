//
//  NezUIBarLabelItem.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-31.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezUIBarLabelItem.h"
#import <QuartzCore/QuartzCore.h>

@implementation NezUIBarLabelItem

-(id)initWithCoder:(NSCoder *)aDecoder {
	UIBarButtonItem *barItem = [super initWithCoder:aDecoder];
	if ((self=[self initWithLabelText:barItem.title])) {
		
	}
	return self;
}

-(id)initWithLabelText:(NSString*)labelText {
	self.label = [[UILabel alloc] init];
	[_label setBackgroundColor:[UIColor clearColor]];
	[_label setFont:[UIFont boldSystemFontOfSize:18.0]];
	[_label setTextAlignment:NSTextAlignmentCenter];
	[_label setTextColor:[UIColor whiteColor]];
	[_label.layer setShadowColor:[[UIColor colorWithWhite:1.0 alpha:0.5] CGColor]];
	[_label.layer setShadowOffset:CGSizeMake(0, 1)];
	[_label.layer setShadowRadius:0.0];
	[_label.layer setShadowOpacity:1.0];
	[_label.layer setMasksToBounds:NO];
	[_label setText:labelText];
	[_label sizeToFit];
	
	if ((self=[super initWithCustomView:_label])) {
	}
	return self;
}

@end
