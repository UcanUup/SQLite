//
//  SQLiteManager.m
//  SQLite
//
//  Created by Young on 2017/3/16.
//  Copyright © 2017年 Young. All rights reserved.
//

#import "SQLiteManager.h"
#import "SQLiteDatabaseManager.h"
#import "SQLiteTableManager.h"

@interface SQLiteManager ()

@property (assign, nonatomic) sqlite3 *database;
@property (copy, nonatomic) NSString *filePath;

@end

@implementation SQLiteManager

+ (instancetype)sharedInstance {
    static SQLiteManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SQLiteManager alloc] init];
        sqlite3_config(SQLITE_CONFIG_SERIALIZED); //线程安全
    });
    return manager;
}

#pragma mark - 打开和关闭数据库

- (BOOL)switchDatabaseWithFilePath:(NSString *)filePath {
    if ([_filePath isEqualToString:filePath]) { //同一个数据库
        if (_database == nil) { //未打开
            sqlite3 *database = [SQLiteDatabaseManager openOrCreateDatabaseWithFilePath:filePath];
            if (database) {
                self.database = database;
            } else {
                return NO;
            }
        }
    } else {
        if (_database) { //已打开
            [SQLiteDatabaseManager closeDatabase:_database];
        }
        sqlite3 *database = [SQLiteDatabaseManager openOrCreateDatabaseWithFilePath:filePath];
        if (database) {
            self.database = database;
            self.filePath = filePath;
        } else {
            return NO;
        }
    }
    return YES;
}

- (void)closeDatabase {
    if (_database == nil) return;
    [SQLiteDatabaseManager closeDatabase:_database];
    self.database = nil;
    self.filePath = nil;
}

#pragma mark - 检查表存在和创建

- (BOOL)checkTableExist:(NSString *)tableName databaseFilePath:(NSString *)filePath {
    NSString *isExistSql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sqlite_master WHERE type = 'table' and name = '%@'", tableName];
    NSArray *reusltArray = [self queryDatabaseWithFilePath:filePath sql:isExistSql columnTypes:@[@(SQLiteTableColumnType_INT)]];
    if ([reusltArray count] > 0) {
        NSInteger tableCount = [[reusltArray[0] objectAtIndex:0] integerValue];
        if (tableCount > 0) { //表已经存在
            return YES;
        }
    }
    return NO;
}

#pragma mark - 增删查改

- (NSArray *)queryDatabaseWithFilePath:(NSString *)filePath sql:(NSString *)sql columnTypes:(NSArray *)columnTypes {
    if (![self switchDatabaseWithFilePath:filePath]) return nil;
    return [SQLiteTableManager queryWithDatabase:_database sql:sql columnTypes:columnTypes];
}

- (int)modifyDatabaseWithFilePath:(NSString *)filePath sql:(NSString *)sql {
    if (![self switchDatabaseWithFilePath:filePath]) return SQLITE_ERROR;
    return [SQLiteTableManager modifyWithDatabase:_database sql:sql];
}

- (int)modifyDatabaseWithFilePath:(NSString *)filePath sql:(NSString *)sql parameters:(NSArray *)parameters {
    if (![self switchDatabaseWithFilePath:filePath]) return SQLITE_ERROR;
    return [SQLiteTableManager modifyWithDatabase:_database sql:sql parameters:parameters];
}

- (BOOL)modifyDatabaseWithFilePath:(NSString *)filePath sql:(NSString *)sql parametersArray:(NSArray<NSArray *> *)parametersArray stopWhenError:(BOOL)stopWhenError {
    if (![self switchDatabaseWithFilePath:filePath]) return NO;
    return [SQLiteTableManager modifyWithDatabase:_database sql:sql parametersArray:parametersArray stopWhenError:(BOOL)stopWhenError];
}

@end
