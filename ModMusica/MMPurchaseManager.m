//
//  MMPurchaseManager.m
//  ModMusica
//
//  Created by Travis Henspeter on 7/8/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "MMPurchaseManager.h"
#import "ModMusicaDefs.h"

typedef void (^ProductRequestResponseHandler) (NSArray *products, NSError *error);
typedef void (^ProductPurchaseHandler) (id product, NSError *error);

@interface MMPurchaseManager () <SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic,strong)            NSMutableDictionary                     *purchaseHandlers;
@property (nonatomic,strong)            ProductRequestResponseHandler           productRequestResponseHandler;
@property (nonatomic,strong)            ProductPurchaseHandler                  productPurchaseHandler;

@end

@implementation MMPurchaseManager

+ (instancetype)sharedInstance
{
    static MMPurchaseManager *sharedInstance_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance_ = [[MMPurchaseManager alloc]init];
    });
    
    return sharedInstance_;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _products = [[NSMutableSet alloc]init];
        [[SKPaymentQueue defaultQueue]addTransactionObserver:self];
    }
    
    return self;
}

- (void)removePurchasehandlerForProductId:(id)productId
{
    if (!self.purchaseHandlers || !productId) {
        return;
    }
    
    if (![self.purchaseHandlers.allKeys containsObject:productId]) {
        return;
    }
    
    [self.purchaseHandlers removeObjectForKey:productId];
}

- (ProductPurchaseHandler)getPurchaseHandlerForProductId:(id)productId
{
    if (!self.purchaseHandlers) {
        return nil;
    }
    
    if (![self.purchaseHandlers.allKeys containsObject:productId]) {
        return nil;
    }
    
    return [self.purchaseHandlers[productId] copy];
    
    return nil;
}

- (void)addPurchaseHandler:(ProductPurchaseHandler)handler forProductId:(id)productId
{
    if (!handler || !productId) {
        return;
    }
    
    if (!self.purchaseHandlers) {
        self.purchaseHandlers = [NSMutableDictionary dictionary];
    }
    
    ProductPurchaseHandler toAdd = [handler copy];
    if ([self.purchaseHandlers.allKeys containsObject:productId]) {
        return;
    }
    
    self.purchaseHandlers[productId] = toAdd;
}

- (SKProductsRequest *)productsRequest
{
    //NSArray *productIds = @[kMarioProductId, kFantasyProductId, kMegaProductId, kMenaceProductId,kSadProductId,kFunkProductId,kMajesticProductId,kHappyProductId];
    NSArray *productIds = @[kGushiesProductId];
    NSSet *identifiers = [NSSet setWithArray:productIds];
    SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:identifiers];
    request.delegate = self;
    return request;
    
}

- (void)getProductsCompletion:(void(^)(NSArray *products, NSError *error))completion
{
    self.productRequestResponseHandler = [completion copy];
    SKProductsRequest *request = [self productsRequest];
    [[NSOperationQueue new]addOperationWithBlock:^{
        [request start];
    }];
}

- (SKProduct *)productWithName:(NSString *)productName
{
    if (!self.products || !self.products.allObjects.count || !productName) {
        return nil;
    }
    
    NSArray *products = self.products.allObjects;
    SKProduct *product = nil;
    for (SKProduct *myProduct in products.mutableCopy) {
        if ([myProduct.localizedTitle isEqualToString:productName]) {
            product = myProduct;
            break;
        }
    }

    return product;
}

+ (NSError *)transactionError:(NSString *)description
{
    return [NSError errorWithDomain:@"com.birdSound.modmusica.transaction" code:0 userInfo:@{@"description":description}];
}

- (void)buyProduct:(NSString *)productName completion:(void(^)(id product, NSError *error))completion
{
    if (![SKPaymentQueue canMakePayments]) {
        if (completion) {
            completion(nil,[MMPurchaseManager transactionError:@"You are not authorized to make this purchase"]);
        }
        return;
    }
    
    SKProduct *toBuy = [self productWithName:productName];
    if (!toBuy) {
        if (completion){
            completion(nil,[MMPurchaseManager transactionError:@"Sorry, that item is unavailable"]);
        }
            
        return;
    }
    
    [self addPurchaseHandler:completion forProductId:toBuy.productIdentifier];
    SKPayment *myPayment = [SKPayment paymentWithProduct:toBuy];
    [[SKPaymentQueue defaultQueue]addPayment:myPayment];
}

#pragma mark - SKProductRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    __weak MMPurchaseManager *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (response.products && response.products.count) {
            [weakself.products addObjectsFromArray:response.products];
        }
        
        if (weakself.productRequestResponseHandler) {
            weakself.productRequestResponseHandler(response.products,nil);
        }
    });
}

- (NSURL *)urlForProductId:(NSString *)productId
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *folderPath = [documentsPath stringByAppendingPathComponent:productId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderPath]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *bundlePath = [folderPath stringByAppendingPathComponent:@"bundle"];
    return [NSURL fileURLWithPath:bundlePath];
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    for (SKDownload *download in downloads) {
        BOOL finished = NO;
        NSString *contentPath = nil;
        NSError *error = download.error;
        switch (download.downloadState) {
            case SKDownloadStateCancelled:
            {
                finished = YES;
                error = [MMPurchaseManager transactionError:@"The download was cancelled"];
            }
                break;
            case SKDownloadStateFailed:
            {
                finished = YES;
            }
                break;
                
            case SKDownloadStateFinished:
            {
                finished = YES;
            }
                break;
                
                default:
                break;
        }
        
        if (finished || error) {
            
            if (!error) {
                NSURL *contentURL = download.contentURL;
                NSURL *copyToURL = [self urlForProductId:download.transaction.payment.productIdentifier];
                [[NSFileManager defaultManager] copyItemAtURL:contentURL toURL:copyToURL error:&error];
                contentPath = copyToURL.path;
            }
            
            ProductPurchaseHandler purchaseHandler = [self getPurchaseHandlerForProductId:download.transaction.payment.productIdentifier];
            
            if (purchaseHandler) {
                purchaseHandler(contentPath,error);
                [self removePurchasehandlerForProductId:download.transaction.payment.productIdentifier];
                [queue finishTransaction:download.transaction];
            }else{
                [queue finishTransaction:download.transaction];
                break;
            }
        }
        
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        
        BOOL finished = NO;
        NSError *error = transaction.error;
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
            {
                finished = YES;
            }
                break;
                case SKPaymentTransactionStateRestored:
            {
                finished = YES;
            }
                break;
                case SKPaymentTransactionStateFailed:
            {
                finished = YES;
            }
                break;
            default:
                break;
        }

        if (finished || error) {
            
            if (!error) {
                
                [queue startDownloads:transaction.downloads];
                
            }else{
                
                ProductPurchaseHandler purchaseHandler = [self getPurchaseHandlerForProductId:transaction.payment.productIdentifier];
                if (purchaseHandler) {
                    purchaseHandler(nil,error);
                    [self removePurchasehandlerForProductId:transaction.payment.productIdentifier];
                    [queue finishTransaction:transaction];
                }else{
                    [queue finishTransaction:transaction];
                    break;
                }
            }
            
        }
        
    }
}


@end
