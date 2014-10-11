//
//  BCFileListVC.m
//  ShareFile
//
//  Created by Olga on 10/8/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "BCFileListVC.h"
#import "AppDelegate.h"
#import <BitcasaSDK/Session.h>
#import <BitcasaSDK/File.h>
#import <BitcasaSDK/Folder.h>
#import <BitcasaSDK/Item.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface BCFileListVC ()
@property (nonatomic, strong) Folder* currDir;
@property (nonatomic, strong) NSArray* items;
@end

typedef enum : NSUInteger {
    cancel_index = 2,
    create_folder = 0,
    upload_file = 1,
} ActionSheetCases;

@implementation BCFileListVC

- (id)initWithDir:(Folder*)dir andItems:(NSArray*)items
{
    self = [super init];
    if (self)
    {
        _currDir = dir;
        _items = items;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    if (!_currDir.name)
        self.title = @"Root";
    else
        self.title = _currDir.name;
    
    if ([self.navigationController.viewControllers count] == 2)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFileOrDirectory:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)logout:(id)sender
{
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.session unlink];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)addFileOrDirectory:(id)sender
{
    UIActionSheet* dirOrFile = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Create Folder", @"Upload File", nil];
    [dirOrFile showInView:self.view];
}

- (void)createFolder
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Folder Name" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)uploadFile
{
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)insertItemIntoTable:(Item*)item
{
    NSMutableArray* mutableItems = [_items mutableCopy];
    [mutableItems addObject:item];
    _items = mutableItems;
    
    [self.tableView reloadData];
    if (_items.count > 0)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_items.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSURL* imageURL = info[UIImagePickerControllerReferenceURL];
    [_currDir uploadContentsOfFile:imageURL delegate:self];
        
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TransferManager delegate
- (void)file:(File*)uploadedFile didCompleteUploadWithError:(NSError*)err
{
    [self insertItemIntoTable:uploadedFile];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField* nameTextField = [alertView textFieldAtIndex:0];
    [_currDir createFolder:nameTextField.text completion:^(Container *newDir)
    {
        if (!nameTextField.text || [nameTextField.text isEqualToString:@""])
            return;
        
        [self insertItemIntoTable:newDir];
    }];
}

#pragma mark - UIActionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case cancel_index:
            break;
        case create_folder:
            [self createFolder];
            break;
        case upload_file:
            [self uploadFile];
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    Item* item = (Item*)_items[indexPath.row];
    cell.textLabel.text = item.name;
    
    if ([item isKindOfClass:[Folder class]])
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = _items[indexPath.row];
    if ([item isKindOfClass:[Folder class]])
    {
        Folder* selectedDir = (Folder*)item;
        [selectedDir listItemsWithCompletion:^(NSArray *items)
         {
             BCFileListVC* fileList = [[BCFileListVC alloc] initWithDir:selectedDir andItems:items];
             [self.navigationController pushViewController:fileList animated:YES];
         }];
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        Item* item = [_items objectAtIndex:indexPath.row];
        [item deleteWithCompletion:^(BOOL success)
         {
             if (!success)
                 return;
             
            NSMutableArray* mutableItems = [_items mutableCopy];
             [mutableItems removeObjectAtIndex:indexPath.row];
             _items = mutableItems;
             
             [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         }];
        
    }
}


@end
