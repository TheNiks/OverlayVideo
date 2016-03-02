//
//  NKDirectVideo.h
//  OverlayVideoAds
//
//  Created by Nikunj Modi on 3/1/16.
//  Copyright © 2016 Niks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NKVideo.h"

@interface NKDirectVideo : NSObject <NKVideo>
@property (nonatomic, strong) NSURL *contentURL;
@property (nonatomic, strong) id currentVC;
@end
