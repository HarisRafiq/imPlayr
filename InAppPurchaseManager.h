//
//  InAppPurchaseManager.h
//  AirDab
//
//  Created by Haris Rafiq on 11/9/13.
//  Copyright (c) 2013 Haris Rafiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"


@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    }
+ (InAppPurchaseManager *)sharedInstance;
@property (nonatomic, strong) SKProduct *proUpgradeProduct;

@property (nonatomic, strong)  SKProductsRequest *productsRequest;
- (void)loadStore;
-(NSString *)price;
- (BOOL)canMakePurchases;
- (void)purchaseProUpgrade;
- (void)restoreCompletedTransactions;
-(BOOL)isAdOptOut;
 @end

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end