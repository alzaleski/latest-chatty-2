//
//  ReplyCell.h
//  LatestChatty2
//
//  Created by Alex Wayne on 3/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableCellFromNib.h"
#import "Post.h"

@interface ReplyCell : TableCellFromNib {
    Post *post;
    BOOL isThreadStarter;
    
    IBOutlet UILabel *preview;
    IBOutlet UILabel *usernameLabel;

    IBOutlet UIImageView *blueBullet;
    IBOutlet UIImageView *grayBullet;
    IBOutlet UIView      *categoryStripe;
}

@property (nonatomic, retain) Post *post;
@property (nonatomic, assign) BOOL isThreadStarter;

@end
