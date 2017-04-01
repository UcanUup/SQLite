//
//  SQLiteDatabaseManager.m
//  SQLite
//
//  Created by Young on 2017/3/23.
//  Copyright © 2017年 Young. All rights reserved.
//

#import "SQLiteDatabaseManager.h"

@implementation SQLiteDatabaseManager

+ (sqlite3 *)openOrCreateDatabaseWithFilePath:(NSString *)filePath {
    if ([filePath length] == 0) {
        NSLog(@"文件路径为空");
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        if (![fileManager createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil]) {
            NSLog(@"数据库目录创建失败");
            return nil;
        }
        if (![fileManager createFileAtPath:filePath contents:nil attributes:nil]) {
            NSLog(@"数据库文件创建失败");
            return nil;
        }
    }
    
    sqlite3 *database;
    if (sqlite3_open([filePath UTF8String], &database) != SQLITE_OK) {
        NSLog(@"数据库打开失败");
        return nil;
    }
    
    return database;
}

+ (void)closeDatabase:(sqlite3 *)database {
    if (database == nil) return;
    sqlite3_close(database);
}

@end
