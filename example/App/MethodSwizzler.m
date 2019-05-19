//
//  MethodSwizzler.m
//  App
//
//  Created by Ben on 19/05/2019.
//  Copyright © 2019 bcylin. All rights reserved.
//

@import CPDAcknowledgements;

#import <objc/runtime.h>
#import "MethodSwizzler.h"

@implementation MethodSwizzler

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class class = object_getClass(NSClassFromString(@"CPDCocoaPodsLibrariesLoader"));

    SEL originalSelector = @selector(loadAcknowledgementsWithBundle:);
    SEL swizzledSelector = @selector(loadAcknowledgementsWithBundle:);

    Method originalMethod = class_getClassMethod(class, originalSelector);
    Method swizzledMethod = class_getClassMethod(self, swizzledSelector);

    BOOL didAddMethod = class_addMethod(class,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
      class_replaceMethod(class,
                          swizzledSelector,
                          method_getImplementation(originalMethod),
                          method_getTypeEncoding(originalMethod));
    } else {
      method_exchangeImplementations(originalMethod, swizzledMethod);
    }
  });
}

/**
 Load `*-App-metadata.plist` instead of `*-metadata.plist`.

 @param bundle The bundle that contains the plist.
 @return An array of CPDLibrary.
 */
+ (NSArray <CPDLibrary *>*)loadAcknowledgementsWithBundle:(NSBundle *)bundle {
  Class class = NSClassFromString(@"CPDCocoaPodsLibrariesLoader");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
  NSString *path = [class performSelector:@selector(pathForFirstFileWithSuffix:inBundle:)
                               withObject:@"-App-metadata.plist"
                               withObject:bundle];
#pragma clang diagnostic pop

  NSArray *entries = [NSDictionary dictionaryWithContentsOfFile:path][@"specs"];
  NSMutableArray *acknowledgements = [NSMutableArray array];

  for (NSDictionary *entry in entries) {
    CPDLibrary *acknowledgement = [[CPDLibrary alloc] initWithCocoaPodsMetadataPlistDictionary:entry];
    [acknowledgements addObject:acknowledgement];
  }

  return [acknowledgements copy];
}

@end
