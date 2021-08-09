//
//  NoteData.m
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import "NoteData.h"

#define NOTE_VERSION 1

static NSString * const kNoteVersion        = @"noteVersion";
static NSString * const kNoteName           = @"noteName";
static NSString * const kNoteContent        = @"noteContent";

@implementation NoteData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.noteName = @"";
        self.noteContent = @"";
    }
    return self;
}

- (instancetype)initWithNoteName:(NSString *)noteName {
    self = [super init];
    if (self) {
        self.noteName = noteName;
        self.noteContent = @"";
    }
    return self;
}

- (instancetype)initWithNoteName:(NSString *)noteName noteContent:(NSString *)noteContent {
    self = [super init];
    if (self) {
        self.noteName = noteName;
        self.noteContent = noteContent;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        NSInteger version = [aDecoder decodeIntegerForKey:kNoteVersion];
        if (version == 1) {
            self.noteName =[aDecoder decodeObjectForKey:kNoteName];
            self.noteContent =[aDecoder decodeObjectForKey:kNoteContent];
        }
    }
    return self;
}

#pragma mark -
#pragma mark NSCoding & NSSecureCoding Protocols

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:NOTE_VERSION forKey:kNoteVersion];
    [aCoder encodeObject:self.noteName forKey:kNoteName];
    [aCoder encodeObject:self.noteContent forKey:kNoteContent];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
