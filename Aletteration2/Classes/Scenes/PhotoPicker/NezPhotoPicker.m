//
//  NezPhotoPicker.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezPhotoPicker.h"
#import <QuartzCore/QuartzCore.h>

#define NEZ_PHOTO_PICKER_GROUP_SECTIONS 6

@implementation NezPhotoPicker

-(id)init {
	if ((self = [super init])) {
		_library = [[ALAssetsLibrary alloc] init];
	}
	return self;
}

-(BOOL)finishLoadingGroupScetions {
	return(_loadedGroupSections == NEZ_PHOTO_PICKER_GROUP_SECTIONS);
}

-(void)loadGroupsWithType:(ALAssetsGroupType)type groupIndex:(int)groupIndex onFinishBlock:(NezGCDBlock)finishBlock {
	NSMutableArray *groupArray = [NSMutableArray array];
	[_library enumerateGroupsWithTypes:type usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
		if (group == nil) {
			if (finishBlock != NULL) {
				[groupArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
					ALAssetsGroup *g1 = obj1;
					ALAssetsGroup *g2 = obj2;
					NSString *s1 = [g1 valueForProperty:ALAssetsGroupPropertyName];
					NSString *s2 = [g2 valueForProperty:ALAssetsGroupPropertyName];
					return [s1 compare:s2];
				}];
				dispatch_async(dispatch_get_main_queue(), ^{
					[_groupSectionList setObject:groupArray atIndexedSubscript:groupIndex];
					_loadedGroupSections++;
					if (_loadedGroupSections == NEZ_PHOTO_PICKER_GROUP_SECTIONS) {
						finishBlock();
					}
				});
			}
		} else if (group.numberOfAssets > 0 && group.posterImage != nil) {
			[groupArray addObject:group];
		}
	} failureBlock:NULL];
}

-(void)loadGroupsWithOnFinishBlock:(NezGCDBlock)finishBlock {
	_loadedGroupSections = 0;
	
	//There must be NEZ_PHOTO_PICKER_GROUP_SECTIONS items in this array
	ALAssetsGroupType typeArray[] = {
		ALAssetsGroupSavedPhotos,
		ALAssetsGroupLibrary,
		ALAssetsGroupAlbum,
		ALAssetsGroupPhotoStream,
		ALAssetsGroupEvent,
		ALAssetsGroupFaces
	};
	//There must be NEZ_PHOTO_PICKER_GROUP_SECTIONS items in this array
	_groupSectionList = [NSMutableArray arrayWithObjects:
		[NSMutableArray array],
		[NSMutableArray array],
		[NSMutableArray array],
		[NSMutableArray array],
		[NSMutableArray array],
		[NSMutableArray array],
		nil
	];
	for (int i=0; i < NEZ_PHOTO_PICKER_GROUP_SECTIONS; i++) {
		[self loadGroupsWithType:typeArray[i] groupIndex:i onFinishBlock:finishBlock];
	}
}

@end
