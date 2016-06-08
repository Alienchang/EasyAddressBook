//
//  EasyAddressBook.m
//  WangQiuJia-1-2015
//
//  Created by Alienchang on 6/7/16.
//  Copyright © 2016 网球家. All rights reserved.
//

#import "EasyAddressBook.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import <objc/runtime.h>


#pragma mark --Class EasyAddressBookModel
@interface EasyAddressBookModel()

@end

@implementation EasyAddressBookModel

- (void)setPhoneNumbers:(NSArray *)phoneNumbers{
    _phoneNumbers = phoneNumbers;
}
- (void)setNamePrefix:(NSString *)namePrefix{
    _namePrefix = [namePrefix copy];
}
- (void)setGivenName:(NSString *)givenName{
    _givenName = [givenName copy];
}
- (void)setMiddleName:(NSString *)middleName{
    _middleName = [middleName copy];
}
- (void)setFamilyName:(NSString *)familyName{
    _familyName = [familyName copy];
}
- (void)setNickname:(NSString *)nickname{
    _nickname = [nickname copy];
}

- (NSString *)description {
    NSDictionary *permanentProperties = [self dictionaryWithValuesForKeys:[self getAllProperties]];
    
    return [NSString stringWithFormat:@"<%@: %p> %@", self.class, self, permanentProperties];
}

- (NSArray *)getAllProperties
{
    u_int count;
    objc_property_t *properties     = class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        [propertiesArray addObject:[NSString stringWithUTF8String: propertyName]];
    }
    free(properties);
    return propertiesArray;
}
@end


#pragma mark --Class EasyAddressBook
@interface EasyAddressBook(){
    ABAddressBookRef *_addressBook;
    CGFloat          _systemVersion;
    NSMutableArray   *_dataSource;
}
@end

@implementation EasyAddressBook

- (id)init{
    self = [super init];
    if (self) {
        _systemVersion = [[UIDevice currentDevice] systemVersion].floatValue;

        _dataSource = [@[] mutableCopy];
    }
    
    return self;
}

+ (instancetype)shareManger{
    static EasyAddressBook *manger = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!manger) {
            manger = [[EasyAddressBook alloc]init];
        }
    });
    return manger;
}

#pragma mark -- 获取通讯录
+ (NSArray <EasyAddressBookModel *>*)contacts{
    return [[EasyAddressBook shareManger] contacts];
}
/**
 *  异步获取通讯录
 */
+ (void)contactsWithBlock:(fetchContactsSuccessBlock)contactsBlock{
    if (contactsBlock) {
        
        dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(queue, ^{
            
            NSArray *contacts = [[EasyAddressBook shareManger] contacts];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                contactsBlock(contacts);
                
            });
            
        });
    }
}

- (NSArray <EasyAddressBookModel *>*)contacts{
    if (_systemVersion >= 9) {
        CNContactStore          * store = [[CNContactStore alloc] init];
        CNContactFetchRequest *fetchReq = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactIdentifierKey, CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataAvailableKey, CNContactImageDataKey]];
        
        fetchReq.sortOrder = CNContactSortOrderUserDefault;//For showing contact same as phonebook sorting
        
        [store enumerateContactsWithFetchRequest:fetchReq error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL  *_Nonnull stop) {
            EasyAddressBookModel *easyAddressBookModel = [EasyAddressBookModel new];
            
            NSMutableArray *numbers = [@[] mutableCopy];
            NSArray *phoneNumbers   = contact.phoneNumbers;
            
            for (CNLabeledValue *labelValue in phoneNumbers) {
                
                CNPhoneNumber *phoneNumber = labelValue.value;
                NSString      *phoneValue  = phoneNumber.stringValue;
                [numbers addObject:phoneValue];
                
            }
            
            [easyAddressBookModel setNickname:[NSString stringWithFormat:@"%@%@",contact.givenName,contact.familyName]];
            [easyAddressBookModel setPhoneNumbers:numbers];
            
            [_dataSource addObject:easyAddressBookModel];
        }];
    }else{
        [_dataSource addObjectsFromArray:[self loadPersonByABAddress]];
    }
    
    return _dataSource;
}

/**
 *  iOS 9以后不推荐ABAddressBook
 *
 */
- (NSArray <EasyAddressBookModel *>*)loadPersonByABAddress
{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    __block NSArray *contacts = nil;
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error){
            
            CFErrorRef *error1 = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
            contacts = [self copyAddressBook:addressBook];
            
        });
        
    }else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        contacts = [self copyAddressBook:addressBook];
        
    }else{
        
        contacts = nil;
        
    }
    
    return contacts;
}

- (NSArray <EasyAddressBookModel *>*)copyAddressBook:(ABAddressBookRef)addressBook
{
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    NSMutableArray *contacts = [@[] mutableCopy];
    
    for (NSInteger i = 0; i < numberOfPeople; i++){
        
        EasyAddressBookModel *easyAddressBookModel = [EasyAddressBookModel new];
        
        ABRecordRef person      = CFArrayGetValueAtIndex(people, i);
        NSString *firstName     = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName      = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        ABMultiValueRef phone   = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSMutableArray *phoneNumbers = [@[] mutableCopy];
        
        for (NSInteger k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            NSString * personPhone = (__bridge NSString *)ABMultiValueCopyValueAtIndex(phone, k);
            [phoneNumbers addObject:personPhone];
        }
        
        [easyAddressBookModel setNickname:[NSString stringWithFormat:@"%@%@",lastName,firstName]];
        [easyAddressBookModel setPhoneNumbers:phoneNumbers];
        
        [contacts addObject:easyAddressBookModel];
    }
    return contacts;
}
@end

