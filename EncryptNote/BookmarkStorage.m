//
//  BookmarkStorage.m
//  EncryptNote
//
//  Created by Nam Tran on 08/08/2021.
//

#import "BookmarkStorage.h"
#import "Settings.h"

@interface BookmarkStorage ()
@property (nonatomic, strong) NSArray * bookmarks;
@end

@implementation BookmarkStorage

+ (BookmarkStorage *)sharedStorage {
    static BookmarkStorage *_sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[BookmarkStorage alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self synchronizeWithUbiquitousStore];
    }
    return self;
}

#pragma mark - Properties

- (NSArray *)bookmarks {
    if (_bookmarks == nil) {
        _bookmarks = [NSArray arrayWithArray:[self items]];
    }
    return _bookmarks;
}

#pragma mark - Public methods

- (void)synchronizeWithUbiquitousStore {
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateKeyValuePairs:)
                                                 name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:store];
    // Synchronize Store
    [store synchronize];
}

- (void)saveBookmark:(Bookmark *)bookmark {
    NSMutableArray* items = [NSMutableArray arrayWithArray:self.bookmarks];
    bookmark.bookmarkId = [self nextSequence];
    /// remove the duplicate bookmark if any
    for (Bookmark *item in items) {
        if ([item.bookmarkName isEqualToString:bookmark.bookmarkName]) {
            [items removeObject:item];
            break;
        }
    }
    /// insert new bookmark on top of the array
    [items insertObject:bookmark atIndex:0];
    [self saveData:items];
}

- (void)removeBookmarkWithName:(NSString *)name {
    NSMutableArray* items = [NSMutableArray arrayWithArray:self.bookmarks];
    for (Bookmark *item in items) {
        if ([item.bookmarkName isEqualToString:name]) {
            [items removeObject:item];
            break;
        }
    }
    [self saveData:items];
}

- (Bookmark *)findBookmarkWithName:(NSString *)name {
    for (Bookmark* item in self.bookmarks) {
        if ([item.bookmarkName isEqualToString:name]) {
            return item;
        }
    }
    return nil;
}

- (void)emptyBookmarks {
    [self saveData:[[NSMutableArray alloc] init]];
}

#pragma mark - Private methods

- (NSArray *)items {
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
    NSArray *array = [self unarchivedArrayFromData:[userDefs objectForKey:kBookmarkBundle]];
    return array;
}

- (void)updateKeyValuePairs:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *changeReason = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangeReasonKey];
    NSInteger reason = -1;
      
    // Is a Reason Specified?
    if (!changeReason) {
        return;
    } else {
        reason = [changeReason integerValue];
    }
      
    // Proceed If Reason Was (1) Changes on Server or (2) Initial Sync
    if ((reason == NSUbiquitousKeyValueStoreServerChange) || (reason == NSUbiquitousKeyValueStoreInitialSyncChange)) {
        NSArray *changedKeys = [userInfo objectForKey:NSUbiquitousKeyValueStoreChangedKeysKey];
        NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
          
        // Search Keys for kBookmarkBundle
        for (NSString *key in changedKeys) {
            if ([key isEqualToString:kBookmarkBundle]) {
                // Update data and save local copy
                NSArray *array = [self unarchivedArrayFromData:[store objectForKey:kBookmarkBundle]];
                [self saveDataToLocalStore:array];
                break;
            }
        }
    }
}

- (void)saveData:(NSArray *)array {
    [self saveDataToLocalStore:array];
    [self saveDataToCloudStore:array];
}

- (void)saveDataToLocalStore:(NSArray *)array {
    /// update the bookmarks property to make sure that it is update-to-date
    _bookmarks = array;
    
    /// save the changes to local user defaults
    NSUserDefaults *userDefs = [NSUserDefaults standardUserDefaults];
    [userDefs setObject:[self archivedDataWithArray:array] forKey:kBookmarkBundle];
    [userDefs synchronize];
}

- (void)saveDataToCloudStore:(NSArray *)array {
    /// Save to iCloud
    NSUbiquitousKeyValueStore *store = [NSUbiquitousKeyValueStore defaultStore];
    if (store != nil) {
        [store setObject:[self archivedDataWithArray:array] forKey:kBookmarkBundle];
        [store synchronize];
    }
}

- (NSInteger)nextSequence {
    NSInteger maxValue = 0;
    for (Bookmark* item in self.bookmarks) {
        if (item.bookmarkId >= maxValue) {
            maxValue = item.bookmarkId;
        }
    }
    return maxValue + 1;
}

- (NSData *)archivedDataWithArray:(NSArray *)array {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array requiringSecureCoding:YES error:nil];
    return data;
}

- (NSArray *)unarchivedArrayFromData:(NSData *)data {
    NSSet *set = [NSSet setWithArray:@[[NSArray class], [NSObject class]]];
    NSArray *array = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:nil];
    return array;
}

@end
