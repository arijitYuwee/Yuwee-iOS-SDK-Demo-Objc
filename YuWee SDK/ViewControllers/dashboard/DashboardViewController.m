//
//  DashboardViewController.m
//  YuWee SDK
//
//  //Created by Yuwee on 28/01/20.
//  Copyright © 2020 Yuwee. All rights reserved.
//

#import "DashboardViewController.h"
//#import <YuWeeSDK/SessionHandler.h>
#import "CallController.h"
#import "CallViewController.h"
#import "ViewController.h"

@interface DashboardViewController (){
    
}

@end

@implementation DashboardViewController

- (void)viewDidLoad{
    self.navigationController.navigationBarHidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveTestNotification:) name:@"onAddMember" object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSLog(@"isConnected: %d",[[Yuwee sharedInstance] getConnectionManager].isConnected);
    
    [[[Yuwee sharedInstance] getCallManager] setIncomingCallEventDelegate:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)receiveTestNotification:(NSNotification *)notification{
    [self performSelector:@selector(presentGroupCall:) withObject:notification.userInfo afterDelay:2.0];
}

- (void)presentGroupCall:(NSDictionary *)dictDetails{
    [self presentGroupCallScreen:true withGroupName:dictDetails[kResult][kGroupInfo][kName] andMembers:dictDetails[kResult][kGroupInfo][kMembers]];
}

- (IBAction)onContactButtonPressed:(id)sender {
    
}

-(IBAction)onLogoutPressed:(id)sender {
    [[[Yuwee sharedInstance] getUserManager] logout];
    [self.navigationController popViewControllerAnimated:true];;
}

-(IBAction)onCallPressed:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *objVC = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController pushViewController:objVC animated:true];
}

-(IBAction)onChatPressed:(id)sender {

}

#pragma mark- Incoming Call delegate

- (void)onIncomingCall:(NSDictionary *)callData{
    NSLog(@"%s dictCallInfo =%@",__PRETTY_FUNCTION__,callData);
    
    [[AppDelegate sharedInstance] showIncomingCallingScreen:callData];
}

- (void)onIncomingCallAcceptSuccess:(NSDictionary *)callData{
    if ([callData[kisGroup] boolValue]) {
        [self presentGroupCallScreen:true];
    } else {
        [self presentCallScreen:true];
    }
}

- (void)onIncomingCallRejectSuccess:(NSDictionary *)callData{
    NSLog(@"Call rejected");
}

#pragma mark- CallManager delegate

- (void)onReadyToInitiateCall{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    [self showInviteCallAlert:@"call request sent"];
}

#pragma mark-

- (void)callData:(NSNotification *) notification{
    
    [[AppDelegate sharedInstance] showIncomingCallingScreen:notification.userInfo];
}

- (void)presentGroupCallScreen:(BOOL)isIncoming withGroupName:(NSString *)groupName andMembers:(NSArray *)arrMembers{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallViewController *callControllerVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callControllerVC.isGroupCall = true;
    callControllerVC.strGroupName = groupName;
    callControllerVC.isIncomingCall = isIncoming;
    callControllerVC.arrMembers = [arrMembers mutableCopy];
    callControllerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callControllerVC];
    
    [self presentViewController:navigationController animated:false completion:nil];
}

- (void)presentCallScreen:(BOOL)isIncoming{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallController *calVC = [storyboard instantiateViewControllerWithIdentifier:@"CallController"];
    calVC.isGroupCall = false;
    calVC.isIncomingCall = isIncoming;
    calVC.modalPresentationStyle = UIModalPresentationFullScreen;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:calVC];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)presentGroupCallScreen:(BOOL)isIncoming{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CallViewController *callControllerVC = [storyboard instantiateViewControllerWithIdentifier:@"CallViewController"];
    callControllerVC.isGroupCall = true;
    callControllerVC.isIncomingCall = isIncoming;
    callControllerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callControllerVC];
    [self presentViewController:navigationController animated:true completion:nil];
}

- (void)showInviteCallAlert:(NSString *)strMessage{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Call invitation sent"
                               message:strMessage
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    
    //Open UIAlert
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
}

@end

