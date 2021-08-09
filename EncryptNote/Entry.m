//
//  Entry.m
//  EncryptNote
//
//  Created by Nam Tran on 09/08/2021.
//

#import "Entry.h"

@implementation Entry

- (instancetype)initWithFileURL:(NSURL *)fileURL metadata:(NoteMetadata *)metadata version:(NSFileVersion *)version {
    if ((self = [super init])) {
        _fileURL = fileURL;
        _metadata = metadata;
        _version = version;
    }
    return self;
}

@end
