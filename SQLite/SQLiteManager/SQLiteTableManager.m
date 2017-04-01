 //
//  SQLiteTableManager.m
//  SQLite
//
//  Created by Young on 2017/3/23.
//  Copyright © 2017年 Young. All rights reserved.
//

#import "SQLiteTableManager.h"
#import "SQLiteDefines.h"

@implementation SQLiteTableManager

+ (NSArray *)queryWithDatabase:(sqlite3 *)database sql:(NSString *)sql columnTypes:(NSArray *)columnTypes {
    sqlite3_stmt *statement = nil;
    int resultCode = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    if (resultCode != SQLITE_OK) {
        NSLog(@"查询失败，错误信息：%s (%@)", sqlite3_errmsg(database), @(resultCode));
    }
    
    NSMutableArray *returnArray = [NSMutableArray array];
    while (sqlite3_step(statement) == SQLITE_ROW) {
        NSMutableArray *rowData = [NSMutableArray array];
        for (int i = 0; i < [columnTypes count]; i++) {
            SQLiteTableColumnType columnType = [columnTypes[i] integerValue];
            switch (columnType) {
                case SQLiteTableColumnType_INT: {
                    int intValue = sqlite3_column_int(statement, i);
                    [rowData addObject:[NSNumber numberWithInt:intValue]];
                    break;
                }
                case SQLiteTableColumnType_TEXT: {
                    NSString *textValue = [NSString stringWithCString:(char *)sqlite3_column_text(statement, i) encoding:NSUTF8StringEncoding];
                    [rowData addObject:textValue];
                    break;
                }
                case SQLiteTableColumnType_BLOB: {
                    int blobLength = sqlite3_column_bytes(statement, i);
                    NSData *blobValue = [NSData dataWithBytes:sqlite3_column_blob(statement, i) length:blobLength];
                    [rowData addObject:blobValue];
                    break;
                }
                default:
                    break;
            }
        }
        [returnArray addObject:rowData];
    }
    sqlite3_finalize(statement);
    
    return returnArray;
}

+ (int)modifyWithDatabase:(sqlite3 *)database sql:(NSString *)sql {
    if (database == nil || sql == nil) return NO;
    
    int resultCode = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
    if (resultCode != SQLITE_OK) {
        NSLog(@"修改失败，错误信息：%s (%@)", sqlite3_errmsg(database), @(resultCode));
    }
    return resultCode;
}

+ (int)modifyWithDatabase:(sqlite3 *)database sql:(NSString *)sql parameters:(NSArray *)parameters {
    if (database == nil || sql == nil) return NO;
    
    sqlite3_stmt *statement = nil;
    int resultCode = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    if (resultCode != SQLITE_OK) {
        NSLog(@"修改失败，错误信息：%s (%@)", sqlite3_errmsg(database), @(resultCode));
    }
    
    for (int i = 0; i < [parameters count]; i++) {
        id parameter = parameters[i];
        if ([parameter isKindOfClass:[NSNumber class]]) {
            sqlite3_bind_int(statement, i+1, [parameter intValue]);
        } else if ([parameter isKindOfClass:[NSString class]]) {
            sqlite3_bind_blob(statement, i+1, [parameter bytes], (int)[parameter length], SQLITE_TRANSIENT);
        } else if ([parameter isKindOfClass:[NSData class]]) {
            sqlite3_bind_text(statement, i+1, [parameter UTF8String], -1, SQLITE_TRANSIENT);
        }
    }
    resultCode = sqlite3_step(statement);
    sqlite3_finalize(statement);
    if (resultCode != SQLITE_DONE) {
        NSLog(@"修改失败，错误信息：%s (%@)", sqlite3_errmsg(database), @(resultCode));
    }
    return resultCode;
}

+ (BOOL)modifyWithDatabase:(sqlite3 *)database sql:(NSString *)sql parametersArray:(NSArray<NSArray *> *)parametersArray stopWhenError:(BOOL)stopWhenError {
    if (database == nil || sql == nil) return nil;
    
    sqlite3_stmt *statement = nil;
    int resultCode = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    if (resultCode != SQLITE_OK) {
        NSLog(@"修改失败，错误码：%@", @(resultCode));
    }
    
    BOOL isSuccess = YES;
    sqlite3_exec(database, "BEGIN;", 0, 0, NULL);
    for (NSArray *parameters in parametersArray) {
        for (int i = 0; i < [parameters count]; i++) {
            id parameter = parameters[i];
            if ([parameter isKindOfClass:[NSNumber class]]) {
                sqlite3_bind_int(statement, i+1, [parameter intValue]);
            } else if ([parameter isKindOfClass:[NSString class]]) {
                sqlite3_bind_text(statement, i+1, [parameter UTF8String], -1, SQLITE_TRANSIENT);
            } else if ([parameter isKindOfClass:[NSData class]]) {
                sqlite3_bind_blob(statement, i+1, [parameter bytes], (int)[parameter length], SQLITE_TRANSIENT);
            }
        }
        resultCode = sqlite3_step(statement);
        if (resultCode != SQLITE_DONE) {
            isSuccess = NO;
            NSLog(@"修改失败，错误信息：%s (%@)", sqlite3_errmsg(database), @(resultCode));
            if (stopWhenError) {
                return NO;
            }
        }
        sqlite3_reset(statement);
    }
    sqlite3_finalize(statement);
    sqlite3_exec(database, "COMMIT;", 0, 0, NULL);
    
    return isSuccess;
}

@end
