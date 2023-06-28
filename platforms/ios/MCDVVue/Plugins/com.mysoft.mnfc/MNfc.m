/********* mnfc.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import <CoreNFC/CoreNFC.h>


typedef NS_ENUM(NSUInteger, NFCCallBackType) {
    NFCCallBackTypeOnStart,    // 扫描开始
    NFCCallBackTypeOnScan,     // 扫描结果
    NFCCallBackTypeOnClose,    // 扫描关闭
    NFCCallBackTypeOnError     // 扫描错误
};

@interface MNfc : CDVPlugin <NFCNDEFReaderSessionDelegate, NFCTagReaderSessionDelegate>{
    NSString* sessionCallbackId;
    BOOL _shouldRestart;
}

@property (strong, nonatomic) NFCReaderSession *nfcSession;

- (void)isSupportNFC:(CDVInvokedUrlCommand*)command;
- (void)startScan:(CDVInvokedUrlCommand*)command;

@end

@implementation MNfc

#pragma mark - Cordova Plugin Methods

- (void)isSupportNFC:(CDVInvokedUrlCommand *)command {
    BOOL isSupported = YES;
    if (@available(iOS 13.0, *)) {
        if (!NFCNDEFReaderSession.readingAvailable) {
            isSupported = NO;
        }
    } else {
        isSupported = NO;
    }
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:isSupported];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)startScan:(CDVInvokedUrlCommand*)command {
    _shouldRestart = NO;
    if (sessionCallbackId) {
        _shouldRestart = YES;
        [self cancelScan:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelScan:) object:nil];
    }
    sessionCallbackId = [command.callbackId copy];
    if (_shouldRestart == NO) {
        [self startNFCScanning];
    }
}

- (void)startNFCScanning {
    [self callBackWithResultType:NFCCallBackTypeOnStart params:nil];
    if (@available(iOS 13.0, *)) {
        if (!NFCNDEFReaderSession.readingAvailable) {
            [self sendErrorWithErrCode:10001 errMsg:@"当前设备NFC不可用"];
            return;
        }
        
        // 如果正在扫描，就不用重新打开了
        if (@available(iOS 13.0, *)) {
            self.nfcSession = [[NFCTagReaderSession alloc] initWithPollingOption:(NFCPollingISO14443 | NFCPollingISO15693) delegate:self queue:dispatch_get_main_queue()];
        }else {
            self.nfcSession = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:nil invalidateAfterFirstRead:TRUE];
        }
        self.nfcSession.alertMessage = @"请贴近NFC标签";
        [self.nfcSession beginSession];
        
    } else {
        [self sendErrorWithErrCode:10001 errMsg:@"需要iOS13之后系统，才能获取NFC的ID信息"];
    }
    [self performSelector:@selector(cancelScan:) withObject:nil afterDelay:61];
}

- (void)cancelScan:(CDVInvokedUrlCommand*)command API_AVAILABLE(ios(11.0)){
    if (self.nfcSession.isReady) {
        [self.nfcSession invalidateSession];
    }else {
        _shouldRestart = NO;
    }
    if (command) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancelScan:) object:nil];
    }
    [self callBackWithResultType:NFCCallBackTypeOnClose params:nil];
}


- (void)callBackWithResultType:(NFCCallBackType)type params:(NSDictionary *)params {
    if (sessionCallbackId == nil) {
        return;
    }
    
    CDVPluginResult *pluginResult = nil;
    switch (type) {
        case NFCCallBackTypeOnStart:
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[@0]];
            pluginResult.keepCallback = @(YES);
            break;
        case NFCCallBackTypeOnScan:
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[@1, params]];
            pluginResult.keepCallback = @(YES);
            break;
        case NFCCallBackTypeOnClose:
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:@[@2]];
            break;
        case NFCCallBackTypeOnError:
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsArray:@[@3, params]];
            pluginResult.keepCallback = @(YES);
            break;
        default:
            break;
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:sessionCallbackId];
    if (type == NFCCallBackTypeOnClose) {
        sessionCallbackId = nil;
    }
}

#pragma mark - NFCNDEFReaderSessionDelegate

// iOS 11 & 12
- (void) readerSession:(NFCNDEFReaderSession *)session didDetectNDEFs:(NSArray<NFCNDEFMessage *> *)messages API_AVAILABLE(ios(11.0)) {
    session.alertMessage = @"读取NFC标签成功";
    for (NFCNDEFMessage *message in messages) {
        [self fireNdefEvent: message];
    }
}

// iOS 13
- (void) readerSession:(NFCNDEFReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCNDEFTag>> *)tags API_AVAILABLE(ios(13.0)) {
    
    if (tags.count > 1) {
        session.alertMessage = @"检测到多个NFC标签，请移除多余标签后重试";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [session restartPolling];
        });
        return;
    }
    
    id<NFCMiFareTag> tag = [tags firstObject];
    [session connectToTag:tag completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [self closeSession:session withError:@"与NFC标签连接失败"];
            return;
        }
        [self processNDEFTag:session tag:tag];
    }];
}

- (void) readerSession:(NFCNDEFReaderSession *)session didInvalidateWithError:(NSError *)error API_AVAILABLE(ios(11.0)) {
    if (error.code == NFCReaderSessionInvalidationErrorFirstNDEFTagRead) {
        return;
    } else {
        NSString *message = @"NFC扫描失败";
        if (error.code == NFCReaderSessionInvalidationErrorSessionTimeout) {
            message = @"NFC扫描超时";
            [self callBackWithResultType:NFCCallBackTypeOnClose params:nil];
        }else if (error.code == NFCReaderSessionInvalidationErrorUserCanceled) {
            message = @"NFC扫描已取消";
            if (_shouldRestart) {
                [self startNFCScanning];
                _shouldRestart = NO;
            }else {
                [self callBackWithResultType:NFCCallBackTypeOnClose params:nil];
            }
        }else {
            message = error.localizedDescription;
            [self sendErrorWithErrCode:20001 errMsg:message];
        }
    }
}

- (void)processNDEFTag: (NFCReaderSession *)session tag:(__kindof id<NFCNDEFTag>)tag API_AVAILABLE(ios(13.0)) {
    [self processNDEFTag:session tag:tag metaData:[NSMutableDictionary new]];
}

- (void)processNDEFTag: (NFCReaderSession *)session tag:(__kindof id<NFCNDEFTag>)tag metaData: (NSMutableDictionary * _Nonnull)metaData API_AVAILABLE(ios(13.0)) {
    
    [tag queryNDEFStatusWithCompletionHandler:^(NFCNDEFStatus status, NSUInteger capacity, NSError * _Nullable error) {
        if (error) {
            [self closeSession:session withError:@"获取NFC标签状态失败"];
            return;
        }
        [self readNDEFTag:session status:status tag:tag metaData:metaData];
    }];
}

- (void)readNDEFTag:(NFCReaderSession * _Nonnull)session status:(NFCNDEFStatus)status tag:(id<NFCNDEFTag>)tag metaData:(NSMutableDictionary * _Nonnull)metaData  API_AVAILABLE(ios(13.0)){
    
    if (status == NFCNDEFStatusNotSupported) {
        [self fireTagEvent:metaData];
        return;
    }
    
    [tag readNDEFWithCompletionHandler:^(NFCNDEFMessage * _Nullable message, NSError * _Nullable error) {
        if (error && error.code != 403) {
            [self closeSession:session withError:@"读取NFC标签失败"];
            return;
        } else {
            session.alertMessage = @"读取NFC标签成功";
            [self fireNdefEvent:message metaData:metaData];
        }
        
    }];
    
}

#pragma mark - NFCTagReaderSessionDelegate

- (void)tagReaderSession:(NFCTagReaderSession *)session didDetectTags:(NSArray<__kindof id<NFCTag>> *)tags API_AVAILABLE(ios(13.0)) {
    if (tags.count > 1) {
        session.alertMessage = @"检测到多个NFC标签，请移除多余标签后重试";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            [session restartPolling];
        });
        return;
    }
    
    id<NFCTag> tag = [tags firstObject];
    NSMutableDictionary *tagMetaData = [self getTagInfo:tag];
    id<NFCNDEFTag> ndefTag = (id<NFCNDEFTag>)tag;
    
    [session connectToTag:tag completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [self closeSession:session withError:@"与NFC标签连接失败"];
            return;
        }

        [self processNDEFTag:session tag:ndefTag metaData:tagMetaData];
    }];
}

- (void)tagReaderSession:(NFCTagReaderSession *)session didInvalidateWithError:(NSError *)error API_AVAILABLE(ios(13.0)) {
    if (error.code == NFCReaderSessionInvalidationErrorFirstNDEFTagRead) {
        return;
    } else {
        NSString *message = @"NFC扫描失败";
        if (error.code == NFCReaderSessionInvalidationErrorSessionTimeout) {
            message = @"NFC扫描超时";
            [self callBackWithResultType:NFCCallBackTypeOnClose params:nil];
        }else if (error.code == NFCReaderSessionInvalidationErrorUserCanceled) {
            message = @"NFC扫描已取消";
            if (_shouldRestart) {
                [self startNFCScanning];
                _shouldRestart = NO;
            }else {
                [self callBackWithResultType:NFCCallBackTypeOnClose params:nil];
            }
        }else {
            message = error.localizedDescription;
            [self sendErrorWithErrCode:20001 errMsg:message];
        }
    }
}

#pragma mark - internal implementation
- (NSMutableDictionary *) getTagInfo:(id<NFCTag>)tag API_AVAILABLE(ios(13.0)) {
    NSMutableDictionary *tagInfo = [NSMutableDictionary new];
    NSData *uid;
    NSString *type;
    switch (tag.type) {
        case NFCTagTypeFeliCa:
            type = @"NFCTagTypeFeliCa";
            uid = nil;
            break;
        case NFCTagTypeMiFare:
            type = @"NFCTagTypeMiFare";
            uid = [[tag asNFCMiFareTag] identifier];
            break;
        case NFCTagTypeISO15693:
            type = @"NFCTagTypeISO15693";
            uid = [[tag asNFCISO15693Tag] identifier];
            break;
        case NFCTagTypeISO7816Compatible:
            type = @"NFCTagTypeISO7816Compatible";
            uid = [[tag asNFCISO7816Tag] identifier];
            break;
        default:
            type = @"Unknown";
            uid = nil;
            break;
    }
    [tagInfo setValue:type forKey:@"type"];
    if (uid) {
        [tagInfo setValue:uid forKey:@"id"];
    }
    return tagInfo;
}

- (void)sendErrorWithErrCode:(NSInteger)errCode errMsg:(NSString *)message {
    [self callBackWithResultType:NFCCallBackTypeOnError params:@{@"errCode":@(errCode), @"errMsg":message}];
    [self callBackWithResultType:NFCCallBackTypeOnClose params:nil];
}

- (void) closeSession:(NFCReaderSession *) session  API_AVAILABLE(ios(11.0)){
    [session invalidateSession];
    [self callBackWithResultType:NFCCallBackTypeOnClose params:nil];
}

- (void) closeSession:(NFCReaderSession *) session withError:(NSString *) errorMessage  API_AVAILABLE(ios(11.0)){
    if (@available(iOS 13.0, *)) {
        [session invalidateSessionWithErrorMessage:errorMessage];
    } else {
        [session invalidateSession];
    }
    [self sendErrorWithErrCode:20001 errMsg:errorMessage];
}

-(void) fireTagEvent:(NSDictionary *)metaData API_AVAILABLE(ios(11.0)) {
    [self fireNdefEvent:nil metaData:metaData];
}

-(void) fireNdefEvent:(NFCNDEFMessage *) ndefMessage API_AVAILABLE(ios(11.0)) {
    [self fireNdefEvent:ndefMessage metaData:nil];
}

-(void) fireNdefEvent:(NFCNDEFMessage *) ndefMessage metaData:(NSDictionary *)metaData API_AVAILABLE(ios(11.0)) {
    
    if (sessionCallbackId) {
        NSData *uid = metaData[@"id"];
        if (!uid) {
            [self sendErrorWithErrCode:20001 errMsg:@"无法获取NFC标签ID信息"];
            return;
        }
        NSString *uidStr = [self convertDataBytesToHex:uid];
        [self callBackWithResultType:NFCCallBackTypeOnScan params:@{@"id": uidStr}];
    }
    [self closeSession:self.nfcSession];
}

- (NSString *)convertDataBytesToHex:(NSData *)dataBytes {
    if (!dataBytes || [dataBytes length] == 0) {
        return @"";
    }
    NSMutableString *hexStr = [[NSMutableString alloc] initWithCapacity:[dataBytes length]];
    [dataBytes enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char *)bytes;
        for (NSInteger i = 0; i < byteRange.length; i ++) {
            NSString *singleHexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xFF];
            if ([singleHexStr length] == 2) {
                [hexStr appendString:singleHexStr];
            } else {
                [hexStr appendFormat:@"0%@", singleHexStr];
            }
        }
    }];
    return [hexStr uppercaseString];
}
@end
