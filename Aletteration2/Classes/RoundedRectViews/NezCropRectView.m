//
//  NezCropRectView.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezCropRectView.h"
#import <QuartzCore/QuartzCore.h>

@implementation NezCropRectView

-(void)drawRect:(CGRect)rect {
	CGRect rectangle;
	CGSize size = rect.size;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	// Reset the transformation
	CGAffineTransform to = CGContextGetCTM(context);
	to = CGAffineTransformInvert(to);
	CGContextConcatCTM(context, to);
	
	CGContextSetLineWidth(context, 1.0);
	CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
	rectangle = CGRectMake(1,1,size.width-2,size.height-2);
	CGContextAddRect(context, rectangle);
	CGContextStrokePath(context);
	CGContextRestoreGState(context);
}

@end
