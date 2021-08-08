//
//  MasterNoteViewController.m
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import "MasterNoteViewController.h"
#import "NoteEditorViewController.h"
#import "Note.h"
#import "Settings.h"
#import "BookmarkStorage.h"
#import "NoteDocument.h"

@interface MasterNoteViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray * notes;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UISwitch   * bookmarkedSwitch;

@property (nonatomic, strong) NSMetadataQuery * query;

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
    
    [self loadNotes];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notes count];
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
    NoteDocument *document = [self.notes objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.text = document.note.noteName;
    
    Bookmark *bookmark = [[BookmarkStorage sharedStorage] findBookmarkWithName:document.note.noteName];
    self.bookmarkedSwitch.on = bookmark != nil;
    
    // use switch tag to keep the table row number
    self.bookmarkedSwitch.tag = indexPath.row;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[Settings settings] idAuthenicateWithCompletionHandler:^(BOOL success, NSString * _Nonnull errorMsg) {
        
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                /// User authenticated successfully, take appropriate action
                
                NoteDocument *document = [self.notes objectAtIndex:indexPath.row];
                NoteEditorViewController *viewController = [[NoteEditorViewController alloc] init];
                viewController.note = document.note;
                viewController.viewController = self;
                [self.navigationController pushViewController:viewController animated:YES];
                
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
        NoteDocument *document = [self.notes objectAtIndex:senderSwitch.tag];
        if ([senderSwitch isOn]) {
            Bookmark *bookmark = [[Bookmark alloc] initWithBookmarkName:document.note.noteName noteUniqueKey:document.note.noteName requireUnlocked:document.note.requireUnlocked];
            [[BookmarkStorage sharedStorage] saveBookmark:bookmark];
        } else {
            [[BookmarkStorage sharedStorage] removeBookmarkWithName:document.note.noteName];
        }
    }
}

#pragma mark -

- (void)addAction:(id)sender {
    NoteEditorViewController *vc = [[NoteEditorViewController alloc] init];
    vc.viewController = self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
          
    // Present View Controller Modally
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - private implementation

- (void)loadNotes {
    if (!self.notes) {
        self.notes = [[NSMutableArray alloc] init];
    }
     
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
     
    if (baseURL) {
        self.query = [[NSMetadataQuery alloc] init];
        [self.query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope]];
         
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K like '*'", NSMetadataItemFSNameKey];
        [self.query setPredicate:predicate];
         
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(queryDidFinish:) name:NSMetadataQueryDidFinishGatheringNotification object:self.query];
        [nc addObserver:self selector:@selector(queryDidFinish:) name:NSMetadataQueryDidUpdateNotification object:self.query];
         
        [self.query startQuery];
    }
}

- (void)queryDidFinish:(NSNotification *)notification {
    NSMetadataQuery *query = [notification object];
     
    // Stop Updates
    [query disableUpdates];
     
    // Stop Query
    [query stopQuery];
     
    // Clear Bookmarks
    [self.notes removeAllObjects];
     
    [query.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSURL *documentURL = [(NSMetadataItem *)obj valueForAttribute:NSMetadataItemURLKey];
        NoteDocument *document = [[NoteDocument alloc] initWithFileURL:documentURL];
         
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self.notes addObject:document];
                [self.tableView reloadData];
            }
        }];
    }];
     
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -

- (void)saveNote:(Note *)note {
    // Save Bookmark
    NSURL *baseURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
     
    if (baseURL) {
        NSURL *documentsURL = [baseURL URLByAppendingPathComponent:@"Documents"];
        NSURL *documentURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"Note_%@-%f", note.noteName, [[NSDate date] timeIntervalSince1970]]];
         
        NoteDocument *document = [[NoteDocument alloc] initWithFileURL:documentURL];
        document.note = note;
         
        // Add Bookmark To Bookmarks
        [self.notes addObject:document];
         
        // Reload Table View
        [self.tableView reloadData];
         
        [document saveToURL:documentURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"Save succeeded.");
            } else {
                NSLog(@"Save failed.");
            }
        }];
    }
}

@end
