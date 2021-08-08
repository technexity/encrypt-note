//
//  NoteDocument.m
//  EncryptNote
//
//  Created by Nam Tran on 08/08/2021.
//

#import "NoteDocument.h"
#import "Note.h"

#define NOTE_EXTENSION @"snf"
#define kArchiveKey @"Note"

@implementation NoteDocument {
    //NSFileWrapper *_fileWrapper;
}

/*#pragma mark - Document Writing Methods

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    //if (self.metadata == nil || self.data == nil)
    //        return nil;
    NSMutableDictionary *wrappers = [NSMutableDictionary dictionary];
    [self encodeObject:self.note toWrappers:wrappers withKey:kArchiveKey];
    //[self encodeObject:_metadata toWrappers:wrappers withKey:kMetadataKey];
    NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:wrappers];
    return fileWrapper;
}

- (void)encodeObject:(id<NSCoding>)object toWrappers:(NSMutableDictionary *)wrappers withKey:(NSString *)key {
    @autoreleasepool {
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
        [archiver encodeObject:object forKey:@"DATA"];
        [archiver finishEncoding];
        NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:archiver.encodedData];
        [wrappers setObject:wrapper forKey:key];
    }
}

#pragma mark - Document Reading Methods

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSFileWrapper *fileWrapper = (NSFileWrapper *)contents;
    self.note = [self decodeObjectFromWrapper:fileWrapper WithKey:kArchiveKey];
    //self.note = nil;
    //_metadata = nil;
    return YES;
}

- (id)decodeObjectFromWrapper:(NSFileWrapper *)_fileWrapper WithKey:(NSString *)key {
    NSFileWrapper *fileWrapper = [_fileWrapper.fileWrappers objectForKey:key];
    if (!fileWrapper)
        return nil;
    NSData *data = [fileWrapper regularFileContents];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
    return [unarchiver decodeObjectForKey:@"DATA"];
}*/

- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    if ([contents length] > 0) {
        NSError *error;
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:contents error:&error];
        if (error != NULL) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            unarchiver.requiresSecureCoding = NO;
            self.note = [unarchiver decodeObjectForKey:kArchiveKey];
        }
        [unarchiver finishDecoding];
    } else {
        self.note = [[Note alloc] initWithNoteName:@"Finance"];
    }
    return YES;
}

- (id)contentsForType:(NSString *)typeName error:(NSError *__autoreleasing *)outError {
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:NO];
    [archiver encodeObject:self.note forKey:kArchiveKey];
    [archiver finishEncoding];
    return archiver.encodedData;
}

#pragma mark -
#pragma mark Utililities

- (NSData *)archivedDataWithArray:(Note *)note {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:note requiringSecureCoding:YES error:nil];
    return data;
}

- (Note *)unarchivedArrayFromData:(NSData *)data {
    NSSet *set = [NSSet setWithArray:@[[Note class], [NSObject class]]];
    Note *note = [NSKeyedUnarchiver unarchivedObjectOfClasses:set fromData:data error:nil];
    return note;
}

@end
