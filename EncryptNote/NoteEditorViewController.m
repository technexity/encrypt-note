//
//  NoteEditorViewController.m
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import "NoteEditorViewController.h"
#import "NoteData.h"
#import "NoteDocument.h"
#import "MasterNoteViewController.h"
#import "NSString+AESCrypt.h"
#import "Settings.h"

#define NUMBER_OF_SECTIONS 4
#define SECTION_NAME 0
#define SECTION_CONTENT 1
#define SECTION_LOCKED 2
#define SECTION_DELETE 3

#define NAME_CONTROL_TAG 100
#define CONTENT_CONTROL_TAG 101
#define LOCKED_CONTROL_TAG 102

@interface NoteEditorViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UITextField * nameTextField;
@property (nonatomic, strong) UITextView  * contentTextView;
@property (nonatomic, strong) UISwitch   * lockedSwitch;

@end

@implementation NoteEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizesSubviews = YES;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                   target:self action:@selector(cancelAction:)];
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                 target:self action:@selector(doneAction:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = doneButton;
    
    //UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    //[self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.createNew) {
        return NUMBER_OF_SECTIONS - 1;
    }
    return NUMBER_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_CONTENT) {
        return UITableViewAutomaticDimension;
    }
    return 54.f;//UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_CONTENT) {
        return 640;//UITableViewAutomaticDimension;
    }
    return 54.f;//UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* CellIdentifier = @"DetailCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        cell.userInteractionEnabled = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (indexPath.section == SECTION_NAME) {
            if (indexPath.row == 0) {
                self.nameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
                self.nameTextField.adjustsFontSizeToFitWidth = YES;
                self.nameTextField.backgroundColor = [UIColor whiteColor];
                self.nameTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
                self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords; // no auto capitalization support
                self.nameTextField.textAlignment = NSTextAlignmentLeft;
                self.nameTextField.font = [UIFont systemFontOfSize:20];
                self.nameTextField.tag = NAME_CONTROL_TAG;
                self.nameTextField.placeholder = NSLocalizedString(@"Name", nil);

                self.nameTextField.keyboardType = UIKeyboardTypeAlphabet; // keyboard type of ur choice
                self.nameTextField.returnKeyType = UIReturnKeyDefault; // returnKey type for keyboard
                self.nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;//UITextFieldViewModeNever;
                
                self.nameTextField.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:self.nameTextField];

                [self.nameTextField.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15].active = YES;
                [self.nameTextField.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-12].active = YES;
                [self.nameTextField.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:0].active = YES;
                [self.nameTextField.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:0].active = YES;
                
                self.nameTextField.delegate = self;
            }
        }
        
        if (indexPath.section == SECTION_CONTENT) {
            self.contentTextView = [[UITextView alloc] initWithFrame:CGRectZero];
            
            self.contentTextView.backgroundColor = [UIColor whiteColor];
            self.contentTextView.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            self.contentTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences; // no auto capitalization support
            self.contentTextView.textAlignment = NSTextAlignmentLeft;
            self.contentTextView.font = [UIFont systemFontOfSize:20];
            self.contentTextView.tag = CONTENT_CONTROL_TAG;
            self.contentTextView.scrollEnabled = NO;
            
            self.contentTextView.keyboardType = UIKeyboardTypeAlphabet; // keyboard type of ur choice
            self.contentTextView.returnKeyType = UIReturnKeyDone; // returnKey type for keyboard
            
            self.contentTextView.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:self.contentTextView];
            
            [self.contentTextView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:15].active = YES;
            [self.contentTextView.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-12].active = YES;
            [self.contentTextView.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:0].active = YES;
            [self.contentTextView.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:0].active = YES;
            
            self.contentTextView.delegate = self;
        }
        
        if (indexPath.section == SECTION_LOCKED) {
            if (indexPath.row == 0) {
                cell.textLabel.font = [UIFont systemFontOfSize:20];
                
                self.lockedSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
                
                [self.lockedSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
                
                // in case the parent view draws with a custom color or gradient, use a transparent color
                self.lockedSwitch.backgroundColor = [UIColor clearColor];
                self.lockedSwitch.tag = LOCKED_CONTROL_TAG;
                
                cell.accessoryView = self.lockedSwitch;
            }
        }
        
        if (indexPath.section == SECTION_DELETE) {
            cell.textLabel.font = [UIFont systemFontOfSize:24];
            cell.textLabel.textColor = [UIColor redColor];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    }
    
    if (indexPath.section == SECTION_NAME) {
        if (indexPath.row == 0) {
            if (!self.createNew) {
                self.nameTextField.text = self.document.noteName;
            }
            [self.nameTextField becomeFirstResponder];
        }
    }
    
    if (indexPath.section == SECTION_CONTENT) {
        if (indexPath.row == 0) {
            if (!self.createNew) {
                self.contentTextView.text = [self decryptedTextFromNoteText:self.document.noteContent];
            }
        }
    }
    
    if (indexPath.section == SECTION_LOCKED) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Locked", nil);
            if (!self.createNew) {
                self.lockedSwitch.on = self.document.requireUnlocked;
            }
        }
    }
    
    if (indexPath.section == SECTION_DELETE) {
        cell.textLabel.text = NSLocalizedString(@"Delete Note", nil);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_DELETE) {
#ifdef DEBUG
    NSLog(@"%s", __PRETTY_FUNCTION__);
#endif
        [[self view] endEditing: YES];
        
        UIAlertController* actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * action) {

            // Cancel button tappped
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }]];

        [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete Note", nil)
                                                        style:UIAlertActionStyleDestructive
                                                      handler:^(UIAlertAction * action) {

            // Delete button tapped
            [self dismissViewControllerAnimated:YES completion:^{
                
                [self.viewController deleteEntry:self.entry];
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
            
        }]];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
        
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    // scroll to cursor
    [self scrollToCursorForTextView:textView];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self.tableView beginUpdates]; // This will cause an animated update of
    [self.tableView endUpdates];   // the height of your UITableViewCell
    [self scrollToCursorForTextView:textView]; // OPTIONAL: Follow cursor
}

- (void)scrollToCursorForTextView: (UITextView *)textView {
    CGRect cursorRect = [textView caretRectForPosition:textView.selectedTextRange.start];
    cursorRect = [self.tableView convertRect:cursorRect fromView:textView];
    if (![self rectVisible:cursorRect]) {
        cursorRect.size.height += 8; // To add some space underneath the cursor
        [self.tableView scrollRectToVisible:cursorRect animated:YES];
    }
}

- (BOOL)rectVisible: (CGRect)rect {
    CGRect visibleRect;
    visibleRect.origin = self.tableView.contentOffset;
    visibleRect.origin.y += self.tableView.contentInset.top;
    visibleRect.size = self.tableView.bounds.size;
    visibleRect.size.height -= self.tableView.contentInset.top + self.tableView.contentInset.bottom;
    return CGRectContainsRect(visibleRect, rect);
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, kbSize.height, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
}

- (void)keyboardWillHide:(NSNotification*)aNotification {
    [UIView animateWithDuration:0.35 animations:^{
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(self.tableView.contentInset.top, 0.0, 0.0, 0.0);
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }];
}

#pragma mark -

- (void)tapAction:(UITapGestureRecognizer *)sender {
    [[self view] endEditing: YES];
}

#pragma mark - Actions

- (void)cancelAction:(id)sender {
    if (!self.createNew) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)doneAction:(id)sender {
    if ([self.nameTextField.text length] > 0) {
        
    }
    
    if (self.lockedSwitch.on) {
        
    }
    
    self.document.noteName = self.nameTextField.text;
    self.document.noteContent = [self encryptedTextFromNoteText:self.contentTextView.text];
    self.document.requireUnlocked = self.lockedSwitch.on;
    
    [self.document saveToURL:[self.document fileURL] forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        [self.document closeWithCompletionHandler:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success) {
                    NSLog(@"Failed to close - %@", [self.document fileURL]);
                }
                [self.viewController detailViewControllerDidClose:self];
            });
        }];
    }];
    
    if (!self.createNew) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)switchAction:(id)sender {
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch *senderSwitch = (UISwitch *)sender;
        
        if (senderSwitch.tag == LOCKED_CONTROL_TAG) {
            NSLog(@"On/off: %@", [senderSwitch isOn] ? @"YES" : @"NO");
        }
    }
}

- (NSString *)encryptedTextFromNoteText:(NSString *)noteText {
    NSString *encryptedText = [noteText AES256EncryptWithKey:[[Settings settings] getSecKeyString]];
    if (encryptedText == nil) {
        //encryptedText = noteText;
        NSLog(@"Unable to encrypt note text!");
    }
    return encryptedText;
}

- (NSString *)decryptedTextFromNoteText:(NSString *)noteText {
    NSString *decryptedText = [noteText AES256DecryptWithKey:[[Settings settings] getSecKeyString]];
    if (decryptedText == nil) {
        //decryptedText = noteText;
        NSLog(@"Unable to decrypt note text!");
    }
    return decryptedText;
}

@end
