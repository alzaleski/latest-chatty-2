//
//  Thread.h
//  LatestChatty2
//
//  Created by Alex Wayne on 3/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Model.h"
#import "StringAdditions.h"
#import "ModelLoader.h"

@interface Post : Model {
  NSString *author;
  NSString *preview;
  NSString *body;
  NSDate   *date;
  NSUInteger replyCount;
  
  NSUInteger storyId;
  NSUInteger parentPostId;
  
  NSMutableArray *replies;
}

@property (copy) NSString *author;
@property (copy) NSString *preview;
@property (copy) NSString *body;
@property (copy) NSDate *date;
@property (readonly) NSUInteger replyCount;

@property (readonly) NSUInteger storyId;
@property (readonly) NSUInteger parentPostId;

@property (retain) NSMutableArray *replies;

+ (ModelLoader *)findAllWithStoryId:(NSUInteger)storyId delegate:(id<ModelLoadingDelegate>)delegate;
+ (ModelLoader *)findAllInLatestChattyWithDelegate:(id<ModelLoadingDelegate>)delegate;

@end