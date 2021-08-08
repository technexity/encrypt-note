//
//  BookmarkStorage.h
//  EncryptNote
//
//  Created by Nam Tran on 08/08/2021.
//

#import <Foundation/Foundation.h>
#import "Bookmark.h"

NS_ASSUME_NONNULL_BEGIN

@interface BookmarkStorage : NSObject

@property (nonatomic, strong, readonly) NSArray * bookmarks;

+ (BookmarkStorage *)sharedStorage;

- (void)synchronizeWithUbiquitousStore;
- (void)saveBookmark:(Bookmark *)bookmark;
- (void)removeBookmarkWithName:(NSString *)name ;
- (Bookmark *)findBookmarkWithName:(NSString *)name;
- (void)emptyBookmarks;

@end

NS_ASSUME_NONNULL_END
