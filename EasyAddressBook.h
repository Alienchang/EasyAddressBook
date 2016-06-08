//
//  EasyAddressBook.h
//  WangQiuJia-1-2015
//
//  Created by Alienchang on 6/7/16.
//  Copyright © 2016 网球家. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^fetchContactsSuccessBlock)(NSArray *array);

@interface EasyAddressBookModel :NSObject
@property (readonly, copy) NSString *identifier;

@property (readonly, copy) NSString *namePrefix;
@property (readonly, copy) NSString *givenName;
@property (readonly, copy) NSString *middleName;
@property (readonly, copy) NSString *familyName;
@property (readonly, copy) NSString *previousFamilyName;
@property (readonly, copy) NSString *nameSuffix;
@property (readonly, copy) NSString *nickname;

@property (readonly, copy) NSString *phoneticGivenName;
@property (readonly, copy) NSString *phoneticMiddleName;
@property (readonly, copy) NSString *phoneticFamilyName;
@property (readonly, strong ,nonatomic) NSArray *phoneNumbers;
@end
@interface EasyAddressBook : NSObject

+ (NSArray <EasyAddressBookModel *>*)contacts;
/**
 *  异步获取通讯录
 */
+ (void)contactsWithBlock:(fetchContactsSuccessBlock)contactsBlock;
@end
