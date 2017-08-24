//
//  Mailer.m
//  SMTPSender
//
//  Created by PhuongNQ on 10/26/13.
//
//

#import "Mailer.h"
#import <CFNetwork/CFNetwork.h>

@implementation Mailer
- (void) sendMail {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    SKPSMTPMessage *testMsg = [[SKPSMTPMessage alloc] init];
    testMsg.fromEmail = [defaults objectForKey:@"fromEmail"];
    
    testMsg.toEmail = [defaults objectForKey:@"toEmail"];
    testMsg.bccEmail = [defaults objectForKey:@"bccEmal"];
    testMsg.relayHost = [defaults objectForKey:@"relayHost"];
    
    testMsg.requiresAuth = [[defaults objectForKey:@"requiresAuth"] boolValue];
    
    if (testMsg.requiresAuth) {
        testMsg.login = [defaults objectForKey:@"login"];
        
        testMsg.pass = [defaults objectForKey:@"pass"];
        
    }
    
    testMsg.wantsSecure = [[defaults objectForKey:@"wantsSecure"] boolValue]; // smtp.gmail.com doesn't work without TLS!
    
    
    testMsg.subject = @"SMTPMessage Test Message";
    //testMsg.bccEmail = @"testbcc@test.com";
    
    // Only do this for self-signed certs!
    // testMsg.validateSSLChain = NO;
    testMsg.delegate = self;
    
    NSDictionary *plainPart = @{
                                kSKPSMTPPartContentTypeKey : @"text/plain",
                                kSKPSMTPPartMessageKey : @"This is a tést messåge.",
                                kSKPSMTPPartContentTransferEncodingKey : @"8bit"
                                };
    
    NSString *vcfPath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"vcf"];
    NSData *vcfData = [NSData dataWithContentsOfFile:vcfPath];
    
    NSDictionary *vcfPart = @{
                              kSKPSMTPPartContentTypeKey : @"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"test.vcf\"",
                              kSKPSMTPPartContentDispositionKey : @"attachment;\r\n\tfilename=\"test.vcf\"",
                              kSKPSMTPPartMessageKey : [vcfData base64EncodedStringWithOptions:0],
                              kSKPSMTPPartContentTransferEncodingKey : @"base64"
                              };
    
    testMsg.parts = @[plainPart,vcfPart];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [testMsg send];
    });
}

/*
 delegate methods
*/
-(void) messageSent:(SKPSMTPMessage *)message {
    NSLog(@"Send message succeeded");
}
-(void) messageFailed:(SKPSMTPMessage *)message error:(NSError *)error {
    NSLog(@"Send message failed");
}
@end
