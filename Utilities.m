//
//  Utilities.m
//  Road
//
//  Created by Li Pan on 2016-02-28.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (id) unarchiveFile: (NSString *) path {
    id archive = nil;
    @try {
        archive = [NSKeyedUnarchiver unarchiveObjectWithFile: path];
        //        NSLog(@"File read from path %@", path);
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to unarchive file %@: %@", path, [exception reason]);
        if ([[NSFileManager defaultManager] fileExistsAtPath: path]) {
            [[NSFileManager defaultManager] removeItemAtPath: path error: nil];
        }
    }
    return archive;
}

+ (BOOL) archiveFile: (id) objectToArchive toFile: (NSString *) path {
    @try {
        NSString *pathOnly = [path stringByDeletingLastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath: pathOnly]) {
            [[NSFileManager defaultManager] createDirectoryAtPath: pathOnly withIntermediateDirectories: YES attributes: nil error: nil];
        }
        [NSKeyedArchiver archiveRootObject: objectToArchive toFile: path];
        //        NSLog(@"File saved to %@", path);
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Unable to unarchive file %@: %@", path, [exception reason]);
        if ([[NSFileManager defaultManager] fileExistsAtPath: path]) {
            [[NSFileManager defaultManager] removeItemAtPath: path error: nil];
        }
        return NO;
    }
}

+ (NSString *) getSavedProfilePath {
    NSString *savedPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *userPath = [savedPath stringByAppendingPathComponent: @"CURRENT_USER.acc"];
    return userPath;
}


@end
