//
//  NoteDocument.m
//  EncryptNote
//
//  Created by Nam Tran on 08/08/2021.
//

#import "NoteDocument.h"
#import "NoteMetadata.h"
#import "NoteData.h"
#import "Entry.h"

static NSString * const kDataKey      = @"Data";
static NSString * const kNoteMetadata = @"note.metadata";
static NSString * const kNoteData     = @"note.data";

@interface NoteDocument ()

@property (nonatomic, strong) NSFileWrapper * fileWrapper;
@property (nonatomic, strong) NoteMetadata  * noteMetadata;
@property (nonatomic, strong) NoteData     * noteData;

@end

@implementation NoteDocument

@dynamic noteName, noteContent, requireUnlocked;

#pragma mark - Properties

- (NoteMetadata *)noteMetadata {
    if (_noteMetadata == nil) {
        if (self.fileWrapper != nil) {
            _noteMetadata = [self decodeFromWrapperForKey:kNoteMetadata];
        } else {
            _noteMetadata = [[NoteMetadata alloc] init];
            _noteMetadata.noteName = @"untitled";
        }
    }
    return _noteMetadata;
}

- (NoteData *)noteData {
    if (_noteData == nil) {
        if (self.fileWrapper != nil) {
            _noteData = [self decodeFromWrapperForKey:kNoteData];
        } else {
            _noteData = [[NoteData alloc] init];
        }
    }
    return _noteData;
}

- (NSString *)noteName {
    return self.noteMetadata.noteName;
}

- (void)setNoteName:(NSString *)noteName {
    self.noteMetadata.noteName = noteName;
    self.noteData.noteName = noteName;
}

- (NSString *)noteContent {
    return self.noteData.noteContent;
}

- (void)setNoteContent:(NSString *)noteContent {
    self.noteData.noteContent = noteContent;
}

- (BOOL)requireUnlocked {
    return self.noteMetadata.requireUnlocked;
}

- (void)setRequireUnlocked:(BOOL)requireUnlocked {
    self.noteMetadata.requireUnlocked = requireUnlocked;
}

- (NSString *)description {
    return [[self.fileURL lastPathComponent] stringByDeletingPathExtension];
}

#pragma mark - Loading contents

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    self.fileWrapper = (NSFileWrapper *)contents;
    _noteMetadata = nil;
    _noteData = nil;
    return YES;
}

- (id)decodeFromWrapperForKey:(NSString *)key {
    NSFileWrapper *wrapper = [self.fileWrapper.fileWrappers objectForKey:key];
    if (wrapper == nil) {
        return nil;
    }
    NSData *data = [wrapper regularFileContents];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
    unarchiver.requiresSecureCoding = NO;
    return [unarchiver decodeObjectForKey:kDataKey];
}

#pragma mark - Writting contents

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing  _Nullable *)outError {
    if (self.noteMetadata == nil || self.noteData == nil) {
        return nil;
    }
    NSDictionary *wrappers = @{
        kNoteMetadata: [self encodeToWrapperWithObject:self.noteMetadata],
        kNoteData: [self encodeToWrapperWithObject:self.noteData]
    };
    return [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
}

- (NSFileWrapper *)encodeToWrapperWithObject:(id<NSCoding>)object {
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
    [archiver encodeObject:object forKey:kDataKey];
    [archiver finishEncoding];
    NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:archiver.encodedData];
    return wrapper;
}

@end
