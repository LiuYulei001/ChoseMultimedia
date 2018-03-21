//
//  UploadVideoTool.h
//  UploadVideo
//
//  Created by Rainy on 2018/3/21.
//  Copyright © 2018年 WealthOnline_iOS_team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MultimediaType) {
    
    MultimediaTypeForImage,   //照片
    MultimediaTypeForVideo,   //视频
};

typedef void(^ChoosVideoBlock)(NSString *videoPath);
typedef void(^ChoosImageBlock)(UIImage *image);

@interface UploadVideoTool : NSObject

- (void)chooseMultimediaWihtType:(MultimediaType)mediaType
                 chooseVideoDone:(ChoosVideoBlock)chooseVideoDone
                 chooseImageDone:(ChoosImageBlock)chooseImageDone;

@end
