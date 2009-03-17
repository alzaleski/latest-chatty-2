//
//  TableCellFromNib.m
//  LatestChatty2
//
//  Created by Alex Wayne on 3/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableCellFromNib.h"


@implementation TableCellFromNib

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundleOrNil {
  UIViewController *cellFactory = [[UIViewController alloc] initWithNibName:nibName bundle:nibBundleOrNil];
  self = (TableCellFromNib *)cellFactory.view;
  [self retain];
  [cellFactory release];
  
  return self;
}

@end
