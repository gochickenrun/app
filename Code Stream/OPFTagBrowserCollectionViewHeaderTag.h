//
//  OPFOPFTagBrowserCollectionViewHeaderTag.h
//  Code Stream
//
//  Created by Tobias Deekens on 09.05.13.
//  Copyright (c) 2013 Opposing Force. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OPFTag;

@interface OPFTagBrowserCollectionViewHeaderTag : UICollectionReusableView

@property (strong, nonatomic) OPFTag *tagModel;

@property (weak, nonatomic) IBOutlet UILabel *tagName;

@end
