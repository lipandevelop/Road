//
//  Utilities.h
//  Road
//
//  Created by Li Pan on 2016-02-28.
//  Copyright © 2016 Li Pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (id)unarchiveFile: (NSString *) path;
+ (BOOL)archiveFile: (id) objectToArchive toFile: (NSString *) path;
+ (NSString *)getSavedProfilePath;




@end
