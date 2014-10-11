//
//  AuthVC.m
//  ShareFile
//
//  Created by Olga on 10/9/14.
//  Copyright (c) 2014 Bitcasa. All rights reserved.
//

#import "AuthVC.h"
#import "AppDelegate.h"
#import "BCFileListVC.h"
#import <BitcasaSDK/Session.h>
#import <BitcasaSDK/Folder.h>

@interface AuthVC ()
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation AuthVC
- (id)init
{
    self = [super initWithNibName:@"AuthVC" bundle:nil];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([[Session sharedSession] isLinked])
    {
        self.title = @"Signing in...";
        [self loadRootVC];
    }
    else
        self.title = @"Sign in";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)emailFinishedEditing:(id)sender
{

}

- (IBAction)passwordFinishedEditing:(id)sender
{

}

- (IBAction)loginAction:(id)sender
{
    [self.email resignFirstResponder];
    [self.password resignFirstResponder];
    
    _errorLabel.hidden = YES;
    [self reloadInputViews];
    
    AppDelegate* delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [delegate.session authenticateWithUsername:_email.text andPassword:_password.text completion:^(BOOL success)
     {
         if (success)
         {
             self.email.text = @"";
             self.password.text = @"";
             
             [self loadRootVC];
         }
         else
         {
             _errorLabel.hidden = NO;
         }
     }];
}

- (void)loadRootVC
{
    Folder* rootDir = [[Folder alloc] initRootContainer];
    [rootDir listItemsWithCompletion:^(NSArray *items)
     {
         BCFileListVC* fileList = [[BCFileListVC alloc] initWithDir:rootDir andItems:items];
         [self.navigationController pushViewController:fileList animated:YES];
     }];
}



@end
