//
//  NoteMetadata.m
//  EncryptNote
//
//  Created by Nam Tran on 09/08/2021.
//

#import "NoteMetadata.h"

#define NOTE_VERSION 1

static NSString * const kNoteVersion        = @"noteVersion";
static NSString * const kNoteName           = @"noteName";
static NSString * const kRequireUnlocked    = @"requireUnlocked";
static NSString * const kCreatedDate        = @"createdDate";

@implementation NoteMetadata

- (instancetype)init {
    self = [super init];
    if (self) {
        self.noteName = @"";
        self.requireUnlocked = NO;
        self.createdDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithNoteName:(NSString *)noteName {
    self = [super init];
    if (self) {
        self.noteName = noteName;
        self.requireUnlocked = NO;
        self.createdDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithNoteName:(NSString *)noteName requireUnlocked:(BOOL)requireUnlocked {
    self = [super init];
    if (self) {
        self.noteName = noteName;
        self.requireUnlocked = requireUnlocked;
        self.createdDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        NSInteger version = [aDecoder decodeIntegerForKey:kNoteVersion];
        if (version == 1) {
            self.noteName =[aDecoder decodeObjectForKey:kNoteName];
            self.requireUnlocked = [aDecoder decodeBoolForKey:kRequireUnlocked];
            self.createdDate =[aDecoder decodeObjectForKey:kCreatedDate];
        }
    }
    return self;
}

#pragma mark -
#pragma mark NSCoding & NSSecureCoding Protocols

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:NOTE_VERSION forKey:kNoteVersion];
    [aCoder encodeObject:self.noteName forKey:kNoteName];
    [aCoder encodeBool:self.requireUnlocked forKey:kRequireUnlocked];
    [aCoder encodeObject:self.createdDate forKey:kCreatedDate];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
