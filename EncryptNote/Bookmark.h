//
//  Bookmark.h
//  EncryptNote
//
//  Created by Nam Tran on 08/08/2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Bookmark : NSObject<NSSecureCoding>

@property (nonatomic, assign) NSInteger    bookmarkId;
@property (nonatomic, strong) NSString   * bookmarkName;
@property (nonatomic, strong) NSString   * noteUniqueKey;
@property (nonatomic, assign) BOOL        requireUnlocked;
@property (nonatomic, strong) NSDate     * bookmarkedDate;

- (instancetype)init;
- (instancetype)initWithBookmarkName:(NSString *)bookmarkName noteUniqueKey:(NSString *)noteUniqueKey requireUnlocked:(BOOL)requireUnlocked;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end

NS_ASSUME_NONNULL_END
