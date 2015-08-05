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
typedef void (^ProductDownloadProgressHandler)(id product, double progress);

@interface MMPurchaseManager () <SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (nonatomic,strong)            NSMutableDictionary                     *purchaseHandlers;
@property (nonatomic,strong)            NSMutableDictionary                     *downloadProgressHandlers;
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

- (void)removeDownloadProgressHandlerForProductId:(id)productId
{
    if (!self.downloadProgressHandlers || !productId) {
        return;
    }
    
    if (![self.downloadProgressHandlers.allKeys containsObject:productId]) {
        return;
    }
    
    [self.downloadProgressHandlers removeObjectForKey:productId];
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

- (ProductDownloadProgressHandler)getDownloadProgressHandlerForProductId:(id)productId
{
    if (!self.downloadProgressHandlers) {
        return nil;
    }
    
    if (![self.downloadProgressHandlers.allKeys containsObject:productId]) {
        return nil;
    }
    
    return [self.downloadProgressHandlers[productId] copy];
    
    return nil;
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

- (void)addDownloadProgressHandler:(ProductDownloadProgressHandler)handler forProductId:(id)productId
{
    if (!handler || !productId) {
        return;
    }
    
    if (!self.downloadProgressHandlers) {
        self.downloadProgressHandlers = [NSMutableDictionary dictionary];
    }
    
    ProductDownloadProgressHandler toAdd = [handler copy];
    if ([self.downloadProgressHandlers.allKeys containsObject:productId]) {
        return;
    }
    
    self.downloadProgressHandlers[productId] = toAdd;
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
    NSArray *productIds = @[kGushiesProductId,kMarioProductId,kFantasyProductId,kMegaProductId];
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

- (void)buyProduct:(NSString *)productName progress:(void (^)(id product, double downloadProgress))progress completion:(void (^)(id product, NSError *error))completion
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
    
    [self addPurchaseHandler:[completion copy] forProductId:toBuy.productIdentifier];
    
    if (progress) {
        [self addDownloadProgressHandler:[progress copy]forProductId:toBuy.productIdentifier];
    }
    
    SKPayment *myPayment = [SKPayment paymentWithProduct:toBuy];
    [[SKPaymentQueue defaultQueue]addPayment:myPayment];
}

- (void)buyProduct:(NSString *)productName completion:(void(^)(id product, NSError *error))completion
{
    [self buyProduct:productName progress:nil completion:completion];
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
                
                case SKDownloadStateActive:
            {
                ProductDownloadProgressHandler progress = [self getDownloadProgressHandlerForProductId:download.transaction.payment.productIdentifier];
                if (progress) {
                    progress(download.transaction.payment.productIdentifier,download.progress);
                }
            }
                break;
                
                default:
                break;
        }
        
        if (finished || error) {
            ProductDownloadProgressHandler progressHandler = [self getDownloadProgressHandlerForProductId:download.transaction.payment.productIdentifier];
            if (!error) {
                if (progressHandler) {
                    progressHandler(download.transaction.payment.productIdentifier,85.0);
                }
                NSURL *contentURL = download.contentURL;
                NSURL *copyToURL = [self urlForProductId:download.transaction.payment.productIdentifier];
                if (progressHandler) {
                    progressHandler(download.transaction.payment.productIdentifier,90.0);
                }
                [[NSFileManager defaultManager] copyItemAtURL:contentURL toURL:copyToURL error:&error];
                if (progressHandler) {
                    progressHandler(download.transaction.payment.productIdentifier,95.0);
                }
                contentPath = copyToURL.path;
            }
            
            ProductPurchaseHandler purchaseHandler = [self getPurchaseHandlerForProductId:download.transaction.payment.productIdentifier];
            
            if (purchaseHandler) {
                purchaseHandler(contentPath,error);
                if (progressHandler) {
                    progressHandler(download.transaction.payment.productIdentifier,100.0);
                    [self removeDownloadProgressHandlerForProductId:download.transaction.payment.productIdentifier];
                }
                [self removePurchasehandlerForProductId:download.transaction.payment.productIdentifier];
                [queue finishTransaction:download.transaction];
            }else{
                if (progressHandler) {
                    progressHandler(download.transaction.payment.productIdentifier,100.0);
                    [self removeDownloadProgressHandlerForProductId:download.transaction.payment.productIdentifier];
                }
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
