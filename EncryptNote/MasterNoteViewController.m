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

@interface MasterNoteViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray * data;
@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UISwitch   * bookmarkedSwitch;

@end

@implementation MasterNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    self.data = [self parseJSONFile];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
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
    
    Note *note = [self.data objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.text = note.name;
    cell.detailTextLabel.text = note.filePath;
    
    Bookmark *bookmark = [[BookmarkStorage sharedStorage] findBookmarkWithName:note.name];
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
                
                Note *note = [self.data objectAtIndex:indexPath.row];
                NoteEditorViewController *viewController = [[NoteEditorViewController alloc] init];
                viewController.note = note;
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
        Note *note = [self.data objectAtIndex:senderSwitch.tag];
        if ([senderSwitch isOn]) {
            Bookmark *bookmark = [[Bookmark alloc] initWithBookmarkName:note.name noteUniqueKey:note.name requireUnlocked:note.locked];
            [[BookmarkStorage sharedStorage] saveBookmark:bookmark];
        } else {
            [[BookmarkStorage sharedStorage] removeBookmarkWithName:note.name];
        }
    }
}

#pragma mark - private implementation

- (NSArray *)parseJSONFile {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:5];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"notes" ofType:@"json"];
    
    // Load the file into an NSData object called JSONData
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    // Create an Objective-C object from JSON Data
    NSArray *JSONArray = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:&error];

    if (!error && JSONArray) {
        for (NSDictionary* dic in JSONArray) {
            Note *note = [[Note alloc] init];
            note.uuid = [dic[@"id"] integerValue];
            note.name = dic[@"name"];
            note.filePath = dic[@"filepath"];
            note.locked = dic[@"locked"];
            [result addObject:note];
        }
    }
    
    return result;
}

@end
