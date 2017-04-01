//
//  FriendTableManager.m
//  SQLite
//
//  Created by Young on 2017/3/23.
//  Copyright © 2017年 Young. All rights reserved.
//

#import "FriendTableManager.h"
#import "SQLiteManager.h"

@implementation FriendTableManager

+ (NSString *)databaseFilePath {
    return [NSString stringWithFormat:@"%@/Documents/Database/FriendMessage.db", NSHomeDirectory()];
}

+ (NSString *)tableNameWithId:(NSInteger)friendId {
    return [NSString stringWithFormat:@"Friend_Message_%@", @(friendId)];
}

+ (NSString *)sqlForCreateTableWithId:(NSInteger)friendId {
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(friendId INTEGER, senderId INTEGER, receiverId INTEGER, sendTime INTEGER, receiveTime INTEGER, sendLocation INTEGER, receiveLocation INTEGER, messageId INTEGER PRIMARY KEY, message TEXT, extraInfo BLOB)", [self tableNameWithId:friendId]];
}

+ (NSString *)sqlForCreateIndexWithId:(NSInteger)friendId {
    return [NSString stringWithFormat:@"CREATE INDEX IF NOT EXISTS MessageIndex_%@ on %@(sendTime)", @(friendId), [self tableNameWithId:friendId]];
}

+ (NSString *)sqlForDeleteIndexWithId:(NSInteger)friendId {
    return [NSString stringWithFormat:@"DROP INDEX IF EXISTS MessageIndex_%@", @(friendId)];
}

+ (void)checkTableWithId:(NSInteger)friendId {
    //建表
    NSString *sql = [self sqlForCreateTableWithId:friendId];
    [[SQLiteManager sharedInstance] modifyDatabaseWithFilePath:[self databaseFilePath] sql:sql];
//    [[SQLiteManager sharedInstance] checkTable:[self tableNameWithId:friendId] databaseFilePath:[self databaseFilePath] createTableIfNotExistWithSql:sql];
}

+ (int)createIndexWithId:(NSInteger)friendId {
    //添加索引
    NSString *sql = [self sqlForCreateIndexWithId:friendId];
    return [[SQLiteManager sharedInstance] modifyDatabaseWithFilePath:[self databaseFilePath] sql:sql];
}

+ (int)deleteIndexWithId:(NSInteger)friendId {
    //删除索引
    NSString *sql = [self sqlForDeleteIndexWithId:friendId];
    return [[SQLiteManager sharedInstance] modifyDatabaseWithFilePath:[self databaseFilePath] sql:sql];
}

+ (NSString *)sqlForInsertMessageWithId:(NSInteger)friendId {
    return [NSString stringWithFormat:@"INSERT INTO %@(friendId, senderId, receiverId, sendTime, receiveTime, sendLocation, receiveLocation, messageId, message, extraInfo) VALUES (?,?,?,?,?,?,?,?,?,?)", [self tableNameWithId:friendId]];
}

+ (NSString *)sqlForSearchMessageWithId:(NSInteger)friendId {
    return [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY sendTime desc, receiveTime desc limit 0, 10", [self tableNameWithId:friendId]];
//    return [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY sendTime desc limit 5000, 10", [self tableNameWithId:friendId]];
//    return [NSString stringWithFormat:@"SELECT * FROM %@", [self tableNameWithId:friendId]];
}

+ (NSArray *)columnTypesForSearchMessage {
    return @[@(SQLiteTableColumnType_INT), @(SQLiteTableColumnType_INT), @(SQLiteTableColumnType_INT), @(SQLiteTableColumnType_INT), @(SQLiteTableColumnType_INT), @(SQLiteTableColumnType_INT), @(SQLiteTableColumnType_INT), @(SQLiteTableColumnType_INT), @(SQLiteTableColumnType_TEXT), @(SQLiteTableColumnType_BLOB)];
}

@end
