//
//  CloudKitDatabase.h
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CloudKitDatabase : NSObject

+ (CloudKitDatabase *)sharedDB;

- (void)createRecordWithName:(NSString *)name content:(NSString *)content;
- (void)updateRecordWithName:(NSString *)name content:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
