//
//  NoteEditorViewController.m
//  EncryptNote
//
//  Created by Nam Tran on 07/08/2021.
//

#import "NoteEditorViewController.h"
#import "Note.h"
#import "NoteDocument.h"
#import "MasterNoteViewController.h"

#define NUMBER_OF_SECTIONS 3
#define SECTION_NAME 0
#define SECTION_CONTENT 1
#define SECTION_LOCKED 2

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
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_CONTENT) {
        return 240.f;
    }
    return 49.f;//UITableViewAutomaticDimension;
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
    }
    
    if (indexPath.section == SECTION_NAME) {
        if (indexPath.row == 0) {
            if (self.note != nil) {
                self.nameTextField.text = self.note.noteName;
            }
            [self.nameTextField becomeFirstResponder];
        }
    }
    
    if (indexPath.section == SECTION_CONTENT) {
        if (indexPath.row == 0) {
            if (self.note != nil) {
                self.contentTextView.text = self.note.noteName;
            }
            //[self.contentTextView becomeFirstResponder];
        }
    }
    
    if (indexPath.section == SECTION_LOCKED) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Locked", nil);
            if (self.note != nil) {
                self.lockedSwitch.on = self.note.requireUnlocked;
            }
        }
    }
    
    return cell;
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
    //[textView becomeFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

#pragma mark -

- (void)tapAction:(UITapGestureRecognizer *)sender {
    [[self view] endEditing: YES];
}

#pragma mark - Actions

- (void)cancelAction:(id)sender {
    if (self.note != nil) {
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
    
    Note *note = [[Note alloc] initWithNoteName:self.nameTextField.text noteText:self.contentTextView.text requireUnlocked:self.lockedSwitch.on];
    [self.viewController saveNote:note];
    
    if (self.note != nil) {
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

@end
