//
//  NKVideo.h
//  OverlayVideoAds
//
//  Created by Nikunj Modi on 3/1/16.
//  Copyright © 2016 Niks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSUInteger, NKQualityOptions) {
    NKQualityLow,
    NKQualityMedium,
    NKQualityHigh
};

@protocol NKVideo <NSObject>

@required

/**
 This is a blocking call, wont return till video info has been parsed. To avoid blocking behavor, use init and call parseURL to parse video url
 */
- (instancetype)initWithContent:(NSURL *)contentURL;

/**
 Loads video info and parses direct urls to video and thumbnail images
 */
- (void)parseWithCompletion:(void(^)(NSError *error))callback;

/**
 Thumbnail image for given quality
 */
- (void)thumbImage:(NKQualityOptions)quality completion:(void (^)(UIImage *thumbImage, NSError *error))callback;

/**
 Direct url to the video for given quality
 */
- (NSURL *)videoURL:(NKQualityOptions)quality;

/**
 Plays video for a given quality in a modal window
 */
- (void)play:(NKQualityOptions)quality;

@optional

/**
 Instance of player so you could present it modally by yourself or push it to a navigation controller.
 */
- (MPMoviePlayerViewController *)movieViewController:(NKQualityOptions)quality;

@end