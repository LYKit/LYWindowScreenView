//
//  NSObject+Swizzle.m
//  bangjob
//
//  Created by langezhao on 2018/12/26.
//  Copyright © 2018年 com.58. All rights reserved.
//

#import "NSObject+LYSwizzle.h"
#import <objc/runtime.h>

@implementation NSObject (LYSwizzle)

+ (void)swizzleInstanceSelector:(SEL)originalSelector withNewSelector:(SEL)newSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod = class_getInstanceMethod(self, newSelector);
    
    BOOL methodAdded = class_addMethod([self class],
                                       originalSelector,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));
    
    if (methodAdded) {
        class_replaceMethod([self class],
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

+ (void)swizzleClassSelector:(SEL)orgSelector withNewSelector:(SEL)newSelector {
    Method orgMethod = class_getClassMethod(self, orgSelector);
    Method newMethod = class_getClassMethod(self, newSelector);
    
    BOOL methodAdded = class_addMethod(self,
                                       orgSelector,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));
    
    if (methodAdded) {
        class_replaceMethod(self,
                            newSelector,
                            method_getImplementation(orgMethod),
                            method_getTypeEncoding(orgMethod));
    } else {
        method_exchangeImplementations(orgMethod, newMethod);
    }
}

@end
