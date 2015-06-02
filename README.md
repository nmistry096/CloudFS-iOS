# CloudFS SDK for iOS
  
The **CloudFS SDK for iOS** enables iOS developers to easily work with [CloudFS Cloud Storage Platform](https://www.bitcasa.com/cloudfs/) and build scalable solutions.

* [REST API Documentation](https://developer.bitcasa.com/cloudfs-api-documentation/)
* [Blog](http://blog.bitcasa.com/) 

## Getting Started

If you have already [signed up](http://access.bitcasa.com/Sign-Up/Info/Prototype/) and obtained your credentials you can get started in minutes.


Cloning the git repository

  ```bash
  $ git clone https://github.com/bitcasa/CloudFS-iOS.git
  ```

## Using the SDK

Use the credentials you obtained from Bitcasa admin console to create a client session. This session can be used for all future requests to Bitcasa.

```objective-c
CFSSession *session = [[CFSSession alloc] initWithServerURL:serverUrl clientId:appId clientSecret:appSecret];
[session  authenticateWithUsername:email andPassword:password completion:^(NSString token, BOOL success, CFSError error){ //YOUR CODE }];
```

Getting the root folder

```objective-c
[fileSystem rootWithCompletion:^(CFSFolder root, CFSError error) { //YOUR CODE }];
```

Getting the contents of a folder

```objective-c
[folder listWithCompletion:^(NSArray items, CFSError error) { //YOUR CODE }];
```

Creating a sub folder under root folder

```objective-c
[folder createFolder:folderName whenExists:CFSItemExistsRename completion:^(CFSFolder newDir, CFSError error) { //YOUR CODE }];
```
Uploading a file to a folder

```objective-c
[folder upload:localFilePath progress:^(NSInteger uploadId, NSString path, int64_t completedBytes, int64_t totalBytes) { } completion:^(NSInteger uploadId, NSString path, CFSFile cfsFile, CFSError error) { //your code }];
```

Downloading a file to a local destination

```objective-c
[file download:localPath progress:^(NSInteger transferId, NSString path, int64_t completedBytes, int64_t totalBytes) { //Your code } completion:^(NSInteger transferId, NSString path, CFSFile file, CFSError error) { //you code }];
```

Deleting a file

```objective-c
[file deleteWithCommit:YES force:NO completion:^(BOOL success, CFSError *error) { //YOUR CODE }];
```

Creating a user (for paid accounts only)

```objective-c
[session setAdminCredentialsWithAdminClientId:clientId adminClientSecret:adminSecret];
[session createAccountWithUsername:[self getRandomEmail] password:@"test123" email:nil firstName:nil lastName:nil logInTocreatedUser:NO WithCompletion:^(CFSUser user, CFSError error) { //YOUR CODE }];
```

Create an user plan (for paid accounts only)

```objective-c
[session setAdminCredentialsWithAdminClientId:clientId adminClientSecret:adminSecret];
[session createPlanWithName:[self getRandomEmail] limit:@"1024" completion:^(CFSPlan *plan, CFSError *error) { //YOUR CODE }];					
```

## Test Suite

The tests that exist are functional tests designed to be used with a CloudFS test user. They use API credentials on your free CloudFS account. You should add the credentials to the file 'BitcasaSDK Tests\BitcasaConfig.plist' (Use BitcasaSDK Tests\BitcasaConfigTemplate.plist as a reference to create the config file.
To run the tests, open XCode and choose target as 'BitcasaSDK Tests' and run 'Test'.

## Support

If you have any questions, comments or encounter any bugs please contact us at sdks@bitcasa.com.