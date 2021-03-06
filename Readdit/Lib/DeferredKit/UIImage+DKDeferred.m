//
//  UIImage+DKDeferred.m
//  DeferredKit
//
//  Created by Samuel Sutch on 8/30/09.
//

#import "UIImage+DKDeferred.h"


@implementation UIImage (DKDeferredAdditions)

+ (UIImage*)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
//  if (UIGraphicsBeginImageContextWithOptions != NULL)
//    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
//  else
    UIGraphicsBeginImageContext(newSize);
  [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  return newImage;
}

- (UIImage *)scaleImageToSize:(CGSize)newSize {
  return [UIImage imageWithImage:self scaledToSize:newSize];
}

- (NSData *)dataForCacheKey:(id)k
{
  return UIImagePNGRepresentation(self);
}

+ (id)fromCacheData:(NSData *)data key:(id)k
{
  return [UIImage imageWithData:data];
}

@end
