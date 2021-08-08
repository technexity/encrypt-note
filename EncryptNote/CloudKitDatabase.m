//
//  CloudKitDatabase.m
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import "CloudKitDatabase.h"

NSString * const kRecordType = @"Notes";

@interface CloudKitDatabase ()

@property (nonatomic, strong) CKDatabase * ckDatabase;

@end

@implementation CloudKitDatabase

+ (CloudKitDatabase *)sharedDB {
    static CloudKitDatabase *_sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[CloudKitDatabase alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.ckDatabase = [[CKContainer defaultContainer] privateCloudDatabase];
    }
    return self;
}

- (void)createRecordWithName:(NSString *)name content:(NSString *)content {
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:name];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:kRecordType recordID:recordID];
    [record setObject:name forKey:@"key"];
    [record setObject:content forKey:@"content"];
    
    [self.ckDatabase saveRecord:record completionHandler:^(CKRecord * _Nullable savedRecord, NSError * _Nullable error) {
        if (error != nil) {
            double retryAfterValue = [error.userInfo[CKErrorRetryAfterKey] doubleValue];
            NSDate *retryAfterDate = [NSDate dateWithTimeIntervalSinceNow:retryAfterValue];
            NSLog(@"Error: %@. Detail: %@", error.localizedDescription, retryAfterDate.debugDescription);
        }
        NSLog(@"Saved successfully. Record: %@", savedRecord.recordID.recordName);
    }];
}

- (void)updateRecordWithName:(NSString *)name content:(NSString *)content {
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:name];
        
    [self.ckDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *fetchedRecord, NSError *error) {
        if (fetchedRecord != nil) {
            //NSString *name = fetchedRecord[@"name"];
            NSLog(@"Record[content]: %@", fetchedRecord[@"content"]);
            fetchedRecord[@"content"] = content;
                
            [self.ckDatabase saveRecord:fetchedRecord completionHandler:^(CKRecord * _Nullable savedRecord, NSError * _Nullable error) {
                if (error != NULL) {
                    double retryAfterValue = [error.userInfo[CKErrorRetryAfterKey] doubleValue];
                    NSDate *retryAfterDate = [NSDate dateWithTimeIntervalSinceNow:retryAfterValue];
                    NSLog(@"Error: %@. Detail: %@", error.localizedDescription, retryAfterDate.debugDescription);
                }
                NSLog(@"Saved successfully. Record: %@", savedRecord.recordID.recordName);
            }];
        } else {
            // handle errors here
            NSLog(@"Unable to update record");
        }
    }];
}

- (void)fetchRecordsWithStartName:(NSString *)prefix completionHandler:(void (^)(NSArray *results, NSError *error))completionHandler {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS '%@'", prefix];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:kRecordType predicate:predicate];
        
    [self.ckDatabase performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (error != NULL) {
            NSLog(@"Error: %@.", error.localizedDescription);
        }
        completionHandler(results, error);
    }];
}

@end
