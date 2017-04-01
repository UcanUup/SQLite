//
//  SQLiteManager.h
//  SQLite
//
//  Created by Young on 2017/3/16.
//  Copyright © 2017年 Young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLiteDefines.h"

@interface SQLiteManager : NSObject

+ (instancetype)sharedInstance;

- (void)closeDatabase;

#pragma mark - 检查表存在和创建

- (BOOL)checkTableExist:(NSString *)tableName databaseFilePath:(NSString *)filePath;

#pragma mark - 增删查改

- (NSArray *)queryDatabaseWithFilePath:(NSString *)filePath sql:(NSString *)sql columnTypes:(NSArray *)columnTypes;
- (int)modifyDatabaseWithFilePath:(NSString *)filePath sql:(NSString *)sql;
- (int)modifyDatabaseWithFilePath:(NSString *)filePath sql:(NSString *)sql parameters:(NSArray *)parameters;
- (BOOL)modifyDatabaseWithFilePath:(NSString *)filePath sql:(NSString *)sql parametersArray:(NSArray<NSArray *> *)parametersArray stopWhenError:(BOOL)stopWhenError;

@end
