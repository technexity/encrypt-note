//
//  Note.m
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import "Note.h"

static NSString * const kNoteId             = @"noteId";
static NSString * const kNoteName           = @"noteName";
static NSString * const kNoteText           = @"noteText";
static NSString * const kRequireUnlocked    = @"requireUnlocked";
static NSString * const kCreatedDate        = @"createdDate";

@implementation Note

- (instancetype)init {
    self = [super init];
    if (self) {
        self.noteId = -1;
        self.noteName = @"";
        self.noteText = @"";
        self.requireUnlocked = NO;
        self.createdDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithNoteName:(NSString *)noteName {
    self = [super init];
    if (self) {
        self.noteId = -1;
        self.noteName = noteName;
        self.noteText = @"";
        self.requireUnlocked = NO;
        self.createdDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithNoteName:(NSString *)noteName requireUnlocked:(BOOL)requireUnlocked {
    self = [super init];
    if (self) {
        self.noteId = -1;
        self.noteName = noteName;
        self.noteText = @"";
        self.requireUnlocked = requireUnlocked;
        self.createdDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithNoteName:(NSString *)noteName noteText:(NSString *)noteText requireUnlocked:(BOOL)requireUnlocked {
    self = [super init];
    if (self) {
        self.noteId = -1;
        self.noteName = noteName;
        self.noteText = noteText;
        self.requireUnlocked = requireUnlocked;
        self.createdDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        self.noteId = [aDecoder decodeIntegerForKey:kNoteId];
        self.noteName =[aDecoder decodeObjectForKey:kNoteName];
        self.noteText =[aDecoder decodeObjectForKey:kNoteText];
        self.requireUnlocked = [aDecoder decodeBoolForKey:kRequireUnlocked];
        self.createdDate =[aDecoder decodeObjectForKey:kCreatedDate];
    }
    return self;
}

#pragma mark -
#pragma mark NSCoding & NSSecureCoding Protocols

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.noteId forKey:kNoteId];
    [aCoder encodeObject:self.noteName forKey:kNoteName];
    [aCoder encodeObject:self.noteText forKey:kNoteText];
    [aCoder encodeBool:self.requireUnlocked forKey:kRequireUnlocked];
    [aCoder encodeObject:self.createdDate forKey:kCreatedDate];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
