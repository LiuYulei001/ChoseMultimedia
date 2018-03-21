# ChoseMultimedia

设置：

最大录制视频时间 kVideoMaximumDuration

最大上传视频大小(M) kVideoMaximumMemory

typedef NS_ENUM(NSUInteger, MultimediaType) {
    
    MultimediaTypeForImage,   //照片
    
    MultimediaTypeForVideo,   //视频
};

功能1：录制视频、选择视频后并压缩成可上传文件，并回调返回视频路径进行上传

[self.actionTool chooseMultimediaWihtType:MultimediaTypeForVideo chooseVideoDone:^(NSString *videoPath) {
        
        /*
         
         录制或者选择后，通过网络上传工具根据视频路径进行上传。
         
         */
         
        NSLog(@"videoPath = %@",videoPath);
        
        
    } chooseImageDone:nil];

功能2：拍摄图片、选择图片后并回调返回图片进行上传

[self.actionTool chooseMultimediaWihtType:MultimediaTypeForImage chooseVideoDone:nil chooseImageDone:^(UIImage *image) {
        
        /*
         
         拍摄或者选择后，通过网络上传工具将图片进行上传。
         
         */
         
        NSLog(@"image = %@",image);
        
    }];
