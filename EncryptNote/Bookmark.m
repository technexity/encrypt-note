//
//  Bookmark.m
//  EncryptNote
//
//  Created by Nam Tran on 08/08/2021.
//

#import "Bookmark.h"

static NSString * const kBookmarkId         = @"bookmarkId";
static NSString * const kBookmarkName       = @"bookmarkName";
static NSString * const kNoteUniqueKey      = @"noteUniqueKey";
static NSString * const kRequireUnlocked    = @"requireUnlocked";
static NSString * const kBookmarkedDate     = @"bookmarkedDate";

@implementation Bookmark

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bookmarkId = -1;
        self.bookmarkName = @"";
        self.noteUniqueKey = @"";
        self.requireUnlocked = NO;
        self.bookmarkedDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithBookmarkName:(NSString *)bookmarkName noteUniqueKey:(NSString *)noteUniqueKey requireUnlocked:(BOOL)requireUnlocked {
    self = [super init];
    if (self) {
        self.bookmarkId = -1;
        self.bookmarkName = bookmarkName;
        self.noteUniqueKey = noteUniqueKey;
        self.requireUnlocked = requireUnlocked;
        self.bookmarkedDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        self.bookmarkId = [aDecoder decodeIntegerForKey:kBookmarkId];
        self.bookmarkName =[aDecoder decodeObjectForKey:kBookmarkName];
        self.noteUniqueKey =[aDecoder decodeObjectForKey:kNoteUniqueKey];
        self.requireUnlocked = [aDecoder decodeBoolForKey:kRequireUnlocked];
        self.bookmarkedDate =[aDecoder decodeObjectForKey:kBookmarkedDate];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.bookmarkId forKey:kBookmarkId];
    [aCoder encodeObject:self.bookmarkName forKey:kBookmarkName];
    [aCoder encodeObject:self.noteUniqueKey forKey:kNoteUniqueKey];
    [aCoder encodeBool:self.requireUnlocked forKey:kRequireUnlocked];
    [aCoder encodeObject:self.bookmarkedDate forKey:kBookmarkedDate];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
