//
//  YuviTimeStartCallView.m
//  YuViTime
//
//  Created by Mac-1 on 7/17/17.
//  Copyright © 2017 satabdi. All rights reserved.
//

#import "YuviTimeStartCallView.h"
#import "YuviTimeAddressFieldCell.h"
#import "UIImageView+WebCache.h"
#import <YuWeeSDK/Yuwee.h>
#import "CallController.h"

#define kHeightConstantForEmailField 20.0f
#define kHeightMargin 5.0f

@interface YuviTimeStartCallView () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSString *strLoginUserEmail;
}
@property (weak, nonatomic) IBOutlet UILabel *lblParticipantsViewPlaceholder;

@end

@implementation YuviTimeStartCallView
{
    NSMutableArray *_tokens, *_contactArray,*arrSelectedTokenContent;
    NSMutableArray *arrContacts;
    BOOL isGroupTypeContactSelected;

}

- (IBAction)btnDismissPopupClicked:(UIButton *)sender{

    [_popUpInvite dismiss:true];
}

+ (instancetype)initWithNib{
    
    return [[[NSBundle mainBundle] loadNibNamed:[NSString stringWithFormat:@"%@", [self class]] owner:nil options:nil] firstObject];
}

- (void)initialize {
    _tokens = [[NSMutableArray alloc] init];
     arrSelectedTokenContent = [[NSMutableArray alloc] init];
    [_addedParticipantsListView reloadData];
    _contactsTableView.tableFooterView = [[UIView alloc] init];
    _contactsTableView.layer.cornerRadius = 3.0;
    _contactsTableView.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor blackColor]);
    
    [_txtGroupName becomeFirstResponder];
}


- (void)setDelegate:(id<YuviTimeStartCallViewDelegate>)delegate_StartCall{
    
    _delegate_StartCall = delegate_StartCall;
}

- (void)setPopUpInvite:(KLCPopup *)popUpInvite{
    
    _popUpInvite = popUpInvite;
}

- (void)setArrExistingEmail:(NSArray *)arrExistingEmail{
    
    _arrExistingUsers = arrExistingEmail;
}

- (IBAction)btnAdduser:(id)sender{
    
    strLoginUserEmail =  [[NSUserDefaults standardUserDefaults] objectForKey:kEmail];
    
    _contactsTableView.hidden = true;
    _addedParticipantsListView.hidden = false;
    
    if (_txtSearchContact.text.length != 0) {
        
        if (![self validateUnknownEmail:_txtSearchContact.text onViewController:[UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController]){
            
            if ([[_txtSearchContact.text lowercaseString] isEqualToString:strLoginUserEmail]){
                //Show toast
                //Get Call VC screen object
                _txtSearchContact.text = @"";
                [_contactsTableView setHidden:true];
                [self.popUpInvite dismiss:true];
                return;
            }else{
                //Add unknown emails
                NSMutableDictionary *dictUnknown = [[NSMutableDictionary alloc] init];
                [dictUnknown setObject:_txtSearchContact.text forKey:kEmail];
                [dictUnknown setObject:_txtSearchContact.text forKey:kName];
                [arrSelectedTokenContent addObject:dictUnknown];
                [_tokens addObject:_txtSearchContact.text];
                [_addedParticipantsListView reloadData];
            }
            
        }
        
        if(arrSelectedTokenContent.count)
            [self.delegate_StartCall didAddUsersWithEmails:arrSelectedTokenContent andGroupName:_txtGroupName.text];
            // [self.delegate_StartCall didAddUsersWithEmails:arrSelectedTokenContent];
        
        _txtGroupName.text = @"";
        _txtSearchContact.text = @"";
    }else {
        
       UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                  message:@"Please enter email to add member in call."
                 delegate:nil
        cancelButtonTitle:nil
        otherButtonTitles:@"OK", nil];
        
        [alert show];
    }

}



#pragma mark- SEARCH

- (IBAction)txtFieldEditingDidChange:(UITextField *)sender {
  
    if (sender.text.length==0){
        _contactsTableView.hidden = true;
    }else{
        _contactsTableView.hidden = false;
    }
    
    _addedParticipantsListView.hidden = !_contactsTableView.hidden;
    NSString *strTrimmed = [sender.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email CONTAINS[cd] %@ || name CONTAINS[cd] %@",strTrimmed,strTrimmed];
    _contactArray = [[arrContacts filteredArrayUsingPredicate:predicate] mutableCopy];
    [_contactsTableView reloadData];
    
}

#pragma mark - UITextFieldDelegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]){
        
        if ([self isStringIsValidEmail:textField.text]) {
            //Add unknown emails
            NSMutableDictionary *dictUnknown = [[NSMutableDictionary alloc] init];
            [dictUnknown setObject:textField.text forKey:kEmail];
            [dictUnknown setObject:textField.text forKey:kName];
            [arrSelectedTokenContent addObject:dictUnknown];
            
            [_tokens addObject:textField.text];
            [_addedParticipantsListView reloadData];
            _contactsTableView.hidden = true;

        }else{
           
            
        }
    }
    [textField resignFirstResponder];
    return true;
}

- (BOOL)isStringIsValidEmail:(NSString *)checkString{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if ([_delegate_StartCall respondsToSelector:@selector(txtFieldShouldBeginEditing:)])
         [_delegate_StartCall txtFieldShouldBeginEditing:textField];
    
    if ([textField.text isEqualToString:@""])
        _contactsTableView.hidden = true;
    else
        _contactsTableView.hidden = false;

    
    return true;
}

#pragma mark - ZFTokenField DataSource
- (CGFloat)lineHeightForTokenInField:(ZFTokenField *)tokenField{
    return kHeightConstantForEmailField;
}

- (NSUInteger)numberOfTokenInField:(ZFTokenField *)tokenField{
    return _tokens.count;
}

- (UIView *)tokenField:(ZFTokenField *)tokenField viewForTokenAtIndex:(NSUInteger)index{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"TokenView" owner:nil options:nil];
    UIView *view = nibContents[0];
    UILabel *label = (UILabel *)[view viewWithTag:2];
    UIButton *button = (UIButton *)[view viewWithTag:3];
    
    [button addTarget:self action:@selector(tokenDeleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    label.text = arrSelectedTokenContent[index][kName];
    
    CGSize size = [label sizeThatFits:CGSizeMake(1000, kHeightConstantForEmailField)];
    view.frame = CGRectMake(0, 0, size.width + 97, kHeightConstantForEmailField);
    return view;
}

#pragma mark - ZFTokenField Delegate

- (CGFloat)tokenMarginInTokenInField:(ZFTokenField *)tokenField{
    return kHeightMargin;
}

- (void)tokenField:(ZFTokenField *)tokenField didReturnWithText:(NSString *)text{
    
}

- (void)tokenField:(ZFTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index
{
    NSLog(@"%s",__PRETTY_FUNCTION__);

}

- (BOOL)tokenFieldShouldEndEditing:(ZFTokenField *)textField
{
    return true;
}

- (void)tokenDeleteButtonPressed:(UIButton *)tokenButton
{
    NSUInteger index = [_addedParticipantsListView indexOfTokenView:tokenButton.superview];
    if (index != NSNotFound) {
        [_tokens removeObjectAtIndex:index];
        [arrSelectedTokenContent removeObjectAtIndex:index];
        [_addedParticipantsListView reloadData];
    }
    
    _lblParticipantsViewPlaceholder.hidden = _tokens.count;

}


# pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _contactArray.count + 1;
}

- (YuviTimeAddressFieldCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YuviTimeAddressFieldCell *cell =[[NSBundle mainBundle] loadNibNamed:@"YuviTimeStartCallView" owner:self options:nil][1];

    UIImage *defaultPeopleImage = [UIImage imageNamed:@"defult_people_icon"];
    
    cell.lblEmail.text = _txtSearchContact.text;
    cell.imgUser.image = defaultPeopleImage;
    cell.constraintForImageWidth.constant = 40;
    
    return cell;
}

- (BOOL)validateUnknownEmail:(NSString*)strEmail onViewController:(UIViewController *)viewController{
    
    if([self isStringIsValidEmail:strEmail]){
        
       if([self.userEmail isEqualToString:strEmail]){
           
           [_popUpInvite dismiss:true];
           
           _txtSearchContact.text = @"";
           
           [self btnDismissPopupClicked:nil];
           
             return true;
           
       }
        
    }
    else{
        
        [_popUpInvite dismiss:true];
        
        _txtSearchContact.text = @"";
        
        [self btnDismissPopupClicked:nil];

          return true;
    }
    
    return false;
}

# pragma mark - UITableViewDelegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)showAlertWithClassObject:(UINavigationController *)navCallVC scheduleCallVCObj:(UIViewController *)presentedVCObj message:(NSString*)strMessage{
    [self btnDismissPopupClicked:nil];
    
    strLoginUserEmail =  [[NSUserDefaults standardUserDefaults] objectForKey:kEmail];
    
    NSString *strTitle = @"Invalid Email";
    NSString *strMessageSubtitle = [NSString stringWithFormat:@"You can not add yourself! Your email address '%@' is removed from the list.",strLoginUserEmail];
    
    if (strMessage){
        strTitle = @"Blocked Email";
        strMessageSubtitle = strMessage;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:strTitle
                                                                             message:strMessageSubtitle
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (![presentedVCObj isKindOfClass:[UIViewController class]]) {
            [self.popUpInvite showAtCenter:CGPointMake(presentedVCObj.view.frame.size.width/2,self.frame.size.height / 2 - navCallVC.navigationBar.frame.size.height)
                                    inView:presentedVCObj.view];
            [presentedVCObj.view layoutIfNeeded];
        }
    }]];
    
    [presentedVCObj presentViewController:alertController animated:YES completion:nil];
}

@end
