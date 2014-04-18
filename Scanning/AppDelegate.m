//
//  AppDelegate.m
//  Scanning
//
//  Created by mac on 14-3-28.
//  Copyright (c) 2014年 trends-china. All rights reserved.
//

#define  EXCUTE_URL  @"http://albuminterface.panker.cn/index.aspx?_action=SetAlubmExcuteStatus&documentGuid=%@&status=1"

#import "AppDelegate.h"
#import "AFNetworking.h"

@implementation AppDelegate
{
    NSTimer *_timer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(selectFile) userInfo:nil repeats:YES];
    NSLog(@"----start-----");
}

- (void)selectFile
{
    NSLog(@"*****");
    NSError * error= nil;
    
    NSFileManager * fm = [NSFileManager defaultManager];
    NSArray *allArray = [fm contentsOfDirectoryAtPath:@"/Users/mac/ios/Project"
                                                error:&error];
    NSString *allFilePath = @"/Users/mac/ios/Project";
    for (NSString *fileName in allArray)
    {
        if ([[NSArray arrayWithContentsOfFile:@"/Users/mac/ios/files.plist"] indexOfObject:fileName] == NSNotFound)
        {
            if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@/%@",allFilePath,fileName,@"start"]])
            {
                NSLog(@"---startHave-----");
                [self runSh:[NSString stringWithFormat:@"%@/%@/WeiXiangce",allFilePath,fileName]];
                
                NSString *ipa = [NSString stringWithFormat:@"%@/%@/WeiXiangce/build/ipa-build/",allFilePath,fileName];
                NSLog(@"name - %@",fileName);
                [self copyIpa:ipa WithIpaName:fileName];
                
                NSMutableArray *allShFileArray = [NSArray arrayWithContentsOfFile:@"/Users/mac/ios/files.plist"];
                [allShFileArray insertObject:fileName atIndex:[allShFileArray count]];
                [allShFileArray writeToFile:@"/Users/mac/ios/files.plist" atomically:YES];
            }
        }
    }
}

- (int)runSh:(NSString *)path
{
    NSString *filePathStr = [NSString stringWithFormat:@"/Users/mac/ios/ipa-build.sh %@",path];
    const char * filePathChar = [filePathStr UTF8String];
    
    return system(filePathChar);
}

- (void)copyIpa:(NSString *)ipaPath WithIpaName:(NSString *)ipaNewName
{
    
    NSFileManager * fm = [NSFileManager defaultManager];
    NSError * error= nil;
    
    for (NSString *ipaName in [fm contentsOfDirectoryAtPath:ipaPath
                                                      error:&error])
    {
        if ([ipaName hasSuffix:@".ipa"])
        {
            if ([fm createDirectoryAtPath:[NSString stringWithFormat:@"/Library/TomCat/webapps/iosData/packages/%@",ipaNewName]
              withIntermediateDirectories:YES
                               attributes:nil
                                    error:&error])
            {
                [fm copyItemAtPath:[NSString stringWithFormat:@"%@/%@",ipaPath,ipaName]
                            toPath:[NSString stringWithFormat:@"/Library/TomCat/webapps/iosData/packages/%@/%@.ipa" ,ipaNewName,ipaNewName]
                             error:&error];
                NSLog(@"Success");
                
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:EXCUTE_URL,ipaNewName]]];
                
                NSLog(@"url = %@",[NSString stringWithFormat:EXCUTE_URL,ipaNewName]);
                AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
                {
                    NSLog(@"---%@",operation.responseString);
                } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                    
                    NSLog(@"Failure: %@", error);
                    
                 }];
                
                [operation start];
            }
        }
        
    }
    NSLog(@"-------");
    
}


@end
