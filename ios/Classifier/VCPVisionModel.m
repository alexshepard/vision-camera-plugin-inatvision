//
//  VCPVisionModel.m
//  VisionCameraPluginInatVision
//
//  Created by Alex Shepard on 10/18/24.
//  Copyright © 2024 Facebook. All rights reserved.
//

#import "VCPVisionModel.h"

@implementation VCPVisionModel

- (instancetype _Nullable)initWithModelPath:(NSString *)modelPath {
    if (self = [super init]) {
        NSURL *visionModelUrl = [NSURL fileURLWithPath:modelPath];
        if (!visionModelUrl) {
            NSLog(@"no file for vision model");
            return nil;
        }
        
        NSError *loadError = nil;
        self.cvModel = [MLModel modelWithContentsOfURL:visionModelUrl error:&loadError];
        if (loadError) {
            NSString *errString = [NSString stringWithFormat:@"error loading cv model: %@",
                                   loadError.localizedDescription];
            NSLog(@"%@", errString);
            return nil;
        }
        if (!self.cvModel) {
            NSLog(@"unable to make cv model");
            return nil;
        }
        
        NSError *modelError = nil;
        self.visionModel = [VNCoreMLModel modelForMLModel:self.cvModel
                                               error:&modelError];

        __weak typeof(self) weakSelf = self;
        VNRequestCompletionHandler recognitionHandler = ^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            
            VNCoreMLFeatureValueObservation *firstResult = request.results.firstObject;
            MLFeatureValue *firstFV = firstResult.featureValue;
            weakSelf.recentVisionScores = firstFV.multiArrayValue;
        };
        
        self.classification = [[VNCoreMLRequest alloc] initWithModel:self.visionModel
                                                   completionHandler:recognitionHandler];
        self.classification.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop;
        self.requests = @[ self.classification ];
    }
    
    return self;
}

- (MLMultiArray * _Nullable)visionPredictionsFor:(CVPixelBufferRef)pixBuf orientation:(UIImageOrientation)orient  {
    CGImagePropertyOrientation cgOrient = [self cgOrientationFor:orient];
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixBuf
                                                                              orientation:cgOrient
                                                                                  options:@{}];

    NSError *requestError = nil;
    [handler performRequests:self.requests
                       error:&requestError];
    
    return self.recentVisionScores;
}

- (CGImagePropertyOrientation)cgOrientationFor:(UIImageOrientation)uiOrientation {
    switch (uiOrientation) {
        case UIImageOrientationUp: return kCGImagePropertyOrientationUp;
        case UIImageOrientationDown: return kCGImagePropertyOrientationDown;
        case UIImageOrientationLeft: return kCGImagePropertyOrientationLeft;
        case UIImageOrientationRight: return kCGImagePropertyOrientationRight;
        case UIImageOrientationUpMirrored: return kCGImagePropertyOrientationUpMirrored;
        case UIImageOrientationDownMirrored: return kCGImagePropertyOrientationDownMirrored;
        case UIImageOrientationLeftMirrored: return kCGImagePropertyOrientationLeftMirrored;
        case UIImageOrientationRightMirrored: return kCGImagePropertyOrientationRightMirrored;
    }
}

@end

