//
//  VCPPrediction.h
//  RNTestLibrary
//
//  Created by Alex Shepard on 3/13/19.
//  Copyright © 2019 California Academy of Sciences. All rights reserved.
//

@import Foundation;

@class VCPNode;

@interface VCPPrediction : NSObject

@property VCPNode *node;
@property double score;
@property NSInteger rank;

- (instancetype)initWithNode:(VCPNode *)node score:(double)score;

- (NSDictionary *)asDict;

@end
