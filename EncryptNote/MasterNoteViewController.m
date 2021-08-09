//
//  MasterNoteViewController.m
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import "MasterNoteViewController.h"
#import "NoteEditorViewController.h"
#import "AppDelegate.h"
#import "Settings.h"
#import "BookmarkStorage.h"
#import "NoteDocument.h"
#import "Entry.h"
#import "NoteMetadata.h"

#define NOTE_EXTENSION @"enf"

@interface MasterNoteViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray * entries;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UISwitch   * bookmarkedSwitch;

@property (nonatomic, strong) NSMetadataQuery * query;

@property (strong) NoteDocument * selectedDocument;
@property (strong) Entry * selectedEntry;

@property (strong) NSMutableArray *iCloudURLs;
@property BOOL iCloudIsReady;
@property BOOL awaitingMoveLocalToiCloud;
@property BOOL awaitingCopyiCloudToLocal;

@end

@implementation MasterNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                 target:self action:@selector(addAction:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.entries = [NSMutableArray array];
    [self reload];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // enable user to interact with this cell
        cell.userInteractionEnabled = YES;
        cell.textLabel.font = [UIFont systemFontOfSize:20];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        //cell.detailTextLabel.numberOfLines = 2;
        
        self.bookmarkedSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        
        [self.bookmarkedSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        
        // in case the parent view draws with a custom color or gradient, use a transparent color
        self.bookmarkedSwitch.backgroundColor = [UIColor clearColor];
        
        cell.accessoryView = self.bookmarkedSwitch;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    // Fetch Note
    Entry *entry = [self.entries objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.text = entry.metadata.noteName;
    
    Bookmark *bookmark = [[BookmarkStorage sharedStorage] findBookmarkWithName:entry.metadata.noteName];
    self.bookmarkedSwitch.on = bookmark != nil;
    
    // use switch tag to keep the table row number
    self.bookmarkedSwitch.tag = indexPath.row;
    
    return cell;
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.query disableUpdates];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [self.query enableUpdates];
}

- (void)didBecomeActive:(NSNotification *)notification {
    [self reload];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[Settings settings] idAuthenicateWithCompletionHandler:^(BOOL success, NSString * _Nonnull errorMsg) {
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                /// User authenticated successfully, take appropriate action\
                
                self.selectedEntry = self.entries[indexPath.row];
                self.selectedDocument = [[NoteDocument alloc] initWithFileURL:[self.selectedEntry fileURL]];

                [self.selectedDocument openWithCompletionHandler:^(BOOL success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NoteEditorViewController *viewController = [[NoteEditorViewController alloc] init];
                        viewController.document = self.selectedDocument;
                        viewController.entry = self.selectedEntry;
                        viewController.viewController = self;
                        viewController.createNew = NO;
                        [self.navigationController pushViewController:viewController animated:YES];
                        
                    });
                }];
                
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [[Settings settings] showAlertIn:self title:@"Error" message:errorMsg];
                
            });
        }
        
    }];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Switch Action

- (void)switchAction:(id)sender {
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch *senderSwitch = (UISwitch *)sender;
        // use switch tag as index row number
        Entry *entry = [self.entries objectAtIndex:senderSwitch.tag];
        if ([senderSwitch isOn]) {
            Bookmark *bookmark = [[Bookmark alloc] initWithBookmarkName:entry.metadata.noteName noteUniqueKey:entry.metadata.noteName requireUnlocked:entry.metadata.requireUnlocked];
            [[BookmarkStorage sharedStorage] saveBookmark:bookmark];
        } else {
            [[BookmarkStorage sharedStorage] removeBookmarkWithName:entry.metadata.noteName];
        }
    }
}

#pragma mark -

- (void)addAction:(id)sender {
    NSURL *fileURL = [self getDocumentURL:[self getDocumentFilename:@"Note" forLocal:YES]];
    NoteDocument *document = [[NoteDocument alloc] initWithFileURL:fileURL];
    
    [document saveToURL:[document fileURL] forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if (!success) {
            NSLog(@"There was an error saving the document - %@", fileURL);
        }
        NSLog(@"File created at %@", fileURL);
        NoteMetadata *metadata = [document noteMetadata];
        NSURL *fileURL = [document fileURL];
        NSFileVersion *version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
        
        self.selectedDocument = document;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self addOrUpdateEntryWithURL:fileURL metadata:metadata version:version];
            
            NoteEditorViewController *vc = [[NoteEditorViewController alloc] init];
            vc.viewController = self;
            vc.createNew = YES;
            vc.document = document;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:nav animated:YES completion:nil];
            
        });
    }];
}

#pragma mark - private implementation

- (void)reload {
    [self.entries removeAllObjects];
    
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
         
    if (baseURL) {
        [self queryICloud];
    } else {
        [self loadLocal];
    }
}

- (void)loadLocal {
    NSArray *localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[Settings settings] documentsDirectoryURL]
                                                            includingPropertiesForKeys:nil options:0 error:nil];
        
    [localDocuments enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        if ([[fileURL pathExtension] isEqualToString:NOTE_EXTENSION]) {
            [self loadDocumentAtFileURL:fileURL];
        }
    }];
    
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}

- (void)loadDocumentAtFileURL:(NSURL *)fileURL {
    NoteDocument *document = [[NoteDocument alloc] initWithFileURL:fileURL];
    
    [document openWithCompletionHandler:^(BOOL success) {
        if (!success) {
            NSLog(@"Unable to open document at %@", fileURL);
            return;
        }

        NoteMetadata *metadata = [document noteMetadata];
        NSURL *fileURL = [document fileURL];
        NSFileVersion *version = [NSFileVersion currentVersionOfItemAtURL:fileURL];
        NSLog(@"Loaded file %@", [document fileURL]);
        
        [document closeWithCompletionHandler:^(BOOL success) {
            if (!success) {
                NSLog(@"There was an error closing the document at %@", fileURL);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self addOrUpdateEntryWithURL:fileURL metadata:metadata version:version];
            });
        }];
    }];
}

- (void)addOrUpdateEntryWithURL:(NSURL *)fileURL metadata:(NoteMetadata *)metadata version:(NSFileVersion *)version {
    NSInteger index = [self indexOfEntryWithFileURL:fileURL];
    
    if (index == NSNotFound) {
        Entry *entry = [[Entry alloc] initWithFileURL:fileURL metadata:metadata version:version];
        [self.entries addObject:entry];
        
        [self.entries sortUsingComparator:^NSComparisonResult(Entry *entry1, Entry *entry2) {
            NSComparisonResult result = [[[entry1 metadata] noteName]  compare:[[entry2 metadata] noteName]];
            NSLog(@"results is %ld", (long)result);
            return result;
        }];
    } else {
        Entry *entry = [self.entries objectAtIndex:index];
        [entry setMetadata:metadata];
        [entry setVersion:version];
        
        [self.entries sortUsingComparator:^NSComparisonResult(Entry *entry1, Entry *entry2) {
            NSComparisonResult result = [[[entry1 metadata] noteName]  compare:[[entry2 metadata] noteName]];
            NSLog(@"results is %ld", (long)result);
            return result;
        }];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)indexOfEntryWithFileURL:(NSURL *)fileURL {
    __block NSInteger index = NSNotFound;
    [self.entries enumerateObjectsUsingBlock:^(Entry *entry, NSUInteger idx, BOOL *stop) {
        if ([[entry fileURL] isEqual:fileURL]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (void)deleteEntry:(Entry *)entry {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtURL:[entry fileURL] error:nil];
    [self removeEntryWithURL:[entry fileURL]];
}

- (void)removeEntryWithURL:(NSURL *)fileURL {
    NSInteger index = [self indexOfEntryWithFileURL:fileURL];
    [self.entries removeObjectAtIndex:index];
    [self.tableView reloadData];
}

#pragma mark -

- (NSURL *)getDocumentURL:(NSString *)filename {
    return [[[Settings settings] documentsDirectoryURL] URLByAppendingPathComponent:filename isDirectory:NO];
}

- (NSString *)getDocumentFilename:(NSString *)filename forLocal:(BOOL)isLocal {
    NSInteger docCount = 0;
    NSString *newDocName = nil;
    BOOL done = NO;
    BOOL first = YES;
    while (!done) {
        if (first) {
            first = NO;
            newDocName = [NSString stringWithFormat:@"%@.%@", filename, NOTE_EXTENSION];
        } else {
            newDocName = [NSString stringWithFormat:@"%@_%ld.%@", filename, (long)docCount, NOTE_EXTENSION];
        }
        BOOL nameExists = NO;
        if (isLocal) {
            nameExists = [self documentNameExistsInObjects:newDocName];
        } else {
            nameExists = [self documentNameExistsIniCloudURLs:newDocName];
        }
        if (!nameExists) {
            break;
        } else {
            docCount++;
        }
    }
    return newDocName;
}

- (BOOL)documentNameExistsInObjects:(NSString *)documentName {
    __block BOOL nameExists = NO;
    [self.entries enumerateObjectsUsingBlock:^(Entry *entry, NSUInteger idx, BOOL *stop) {
        if ([[[entry fileURL] lastPathComponent] isEqualToString:documentName]) {
            nameExists = YES;
            *stop = YES;
        }
    }];
    return nameExists;
}
   
- (void)detailViewControllerDidClose:(NoteEditorViewController *)detailViewCtrl {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    NSFileVersion *version = [NSFileVersion currentVersionOfItemAtURL:[detailViewCtrl.document fileURL]];
    [self addOrUpdateEntryWithURL:[detailViewCtrl.document fileURL] metadata:[detailViewCtrl.document noteMetadata] version:version];
}

#pragma mark -

- (NSMetadataQuery *)documentQuery {
    NSMetadataQuery *query = [[NSMetadataQuery alloc] init];
    
    if (query) {
        [query setSearchScopes:@[NSMetadataQueryUbiquitousDocumentsScope]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K LIKE %@", NSMetadataItemFSNameKey,
                                  [NSString stringWithFormat:@"*.%@", NOTE_EXTENSION]];
        
        [query setPredicate:predicate];
    }
    
    return query;
}

- (void)queryICloud {
    [self stopICloudQuery];
    
    self.query = [self documentQuery];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processICloudFiles:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processICloudFiles:)
                                                 name:NSMetadataQueryDidUpdateNotification object:nil];
    [self.query startQuery];
}

- (void)stopICloudQuery {
    if (self.query) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSMetadataQueryDidUpdateNotification object:nil];
        [self.query stopQuery];
        self.query = nil;
    }
}

- (void)processICloudFiles:(NSNotification *)notification {
    [self.query disableUpdates];
    
    [self.iCloudURLs removeAllObjects];
    
    [[self.query results] enumerateObjectsUsingBlock:^(NSMetadataItem *item,  NSUInteger idx, BOOL *stop) {
        NSURL *fileURL = [item valueForAttribute:NSMetadataItemURLKey];
        NSNumber *aBool = nil;
        [fileURL getResourceValue:&aBool forKey:NSURLIsHiddenKey error:nil];
        if (aBool && ![aBool boolValue]) {
            [self.iCloudURLs addObject:fileURL];
        }
    }];
    
    NSLog(@"Found %lu files in iCloud", (unsigned long)[_iCloudURLs count]);
    
    self.iCloudIsReady = YES;
    
    if (YES) {
        for (NSInteger i = [self.entries count] - 1; i >= 0; i--) {
            Entry *entry = self.entries[i];
            if (![self.iCloudURLs containsObject:[entry fileURL]]) {
                [self removeEntryWithURL:[entry fileURL]];
            }
        }
        
        [self.iCloudURLs enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
            [self loadDocumentAtFileURL:fileURL];
        }];
        
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    
    [self.query enableUpdates];
    
    self.awaitingMoveLocalToiCloud = YES;
    if (self.awaitingMoveLocalToiCloud) {
        self.awaitingMoveLocalToiCloud = NO;
        
        [self moveLocalToICloud];
        
    } else if (_awaitingCopyiCloudToLocal) {
        
        [self copyICloudToLocal];
    }
}

- (void)moveLocalToICloud {
    if (self.iCloudIsReady && !self.awaitingMoveLocalToiCloud) {
        
        NSArray *localDocuments = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[[Settings settings] documentsDirectoryURL]
                                                                includingPropertiesForKeys:nil options:0 error:nil];
        
        [localDocuments enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
            if ([[fileURL pathExtension] isEqualToString:NOTE_EXTENSION]) {
                NSString *fileName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
                NSURL *destinationURL = [self getDocumentURL:[self getDocumentFilename:fileName forLocal:NO]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error = nil;
                    BOOL success = [[NSFileManager defaultManager] setUbiquitous:YES
                                                                       itemAtURL:fileURL
                                                                  destinationURL:destinationURL
                                                                           error:&error];
                    if (success) {
                        NSLog(@"Moved %@ to %@", fileURL,destinationURL);
                        [self loadDocumentAtFileURL:destinationURL];
                    } else {
                        NSLog(@"Error Moving %@ to %@ - %@", fileURL,destinationURL, error.localizedDescription);
                    }
                });
            }
        }];
        
        [self copyICloudToLocal];
    } else {
        self.awaitingMoveLocalToiCloud = YES;
    }
}

- (void)copyICloudToLocal {
    if (self.iCloudIsReady && self.awaitingCopyiCloudToLocal) {
        self.awaitingCopyiCloudToLocal = NO;
        
        [self.iCloudURLs enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
            NSString *fileName = [[fileURL lastPathComponent] stringByDeletingPathExtension];
            NSURL *destinationURL = [self getDocumentURL:[self getDocumentFilename:fileName forLocal:YES]];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
                [fileCoordinator coordinateReadingItemAtURL:fileURL
                                                    options:NSFileCoordinatorReadingWithoutChanges error:nil
                                                 byAccessor:^(NSURL *newURL) {
                    
                    NSFileManager *fileManager = [[NSFileManager alloc] init];
                    NSError *error = nil;
                    BOOL success = [fileManager copyItemAtURL:fileURL toURL:destinationURL error:&error];
                    if (success) {
                        NSLog(@"Copied %@ to %@",fileURL,destinationURL);
                        [self loadDocumentAtFileURL:destinationURL];
                    } else {
                        NSLog(@"Error Copying %@ to %@ - %@", fileURL, destinationURL, error.localizedDescription);
                    }
                    
                }];
                
            });
            
        }];
    } else {
        if (!self.awaitingCopyiCloudToLocal) {
            self.awaitingCopyiCloudToLocal = YES;
        }
    }
}

- (BOOL)documentNameExistsIniCloudURLs:(NSString *)documentName {
    __block BOOL nameExists = NO;
    [_iCloudURLs enumerateObjectsUsingBlock:^(NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        if ([[fileURL lastPathComponent] isEqualToString:documentName]) {
            nameExists = YES;
            *stop = YES;
        }
    }];
    return nameExists;
}

@end
