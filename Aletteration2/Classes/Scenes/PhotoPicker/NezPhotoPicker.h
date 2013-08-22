//
//  NezPhotoPicker.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NezGCD.h"

@interface NezPhotoPicker : NSObject {
	ALAssetsLibrary *_library;
	
	int _loadedGroupSections;
}

@property(nonatomic,strong) NSMutableArray *groupSectionList;

-(void)loadGroupsWithOnFinishBlock:(NezGCDBlock)finishBlock;
-(BOOL)finishLoadingGroupScetions;

@end
