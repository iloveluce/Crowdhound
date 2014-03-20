
- (void)requestFinished:(ASIHTTPRequest *)request
{
    
    if (request.responseStatusCode == 400) {
         NSLog(@"Invalid code");
    } else if (request.responseStatusCode == 403) {
         NSLog(@"already used code");
    } else if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        NSString *unlockCode = [responseDict objectForKey:@"unlock_code"];
        
        if ([unlockCode compare:@"com.razeware.test.unlock.cake"] == NSOrderedSame) {
            NSLog(@"good to go used code");
        } else {
            NSLog(@"good to go used code");        }
        
    } else {
        NSLog(@"Unexpected error");
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
     NSLog(@" error");
}

