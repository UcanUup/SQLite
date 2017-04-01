//
//  FriendTableManager.h
//  SQLite
//
//  Created by Young on 2017/3/23.
//  Copyright © 2017年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendTableManager : NSObject

+ (NSString *)databaseFilePath;

+ (void)checkTableWithId:(NSInteger)friendId;
+ (int)createIndexWithId:(NSInteger)friendId;
+ (int)deleteIndexWithId:(NSInteger)friendId;

+ (NSString *)sqlForInsertMessageWithId:(NSInteger)friendId;

+ (NSString *)sqlForSearchMessageWithId:(NSInteger)friendId;
+ (NSArray *)columnTypesForSearchMessage;

@end
