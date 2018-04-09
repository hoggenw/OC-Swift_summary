#####//hoggen 聊天页面的cell
标记的是聊天页面显示的cell

#####//hoggen 聊天页面获取图片和视频发送的按钮

##### #pragma mark - 发送文字消息 
发送文字消息按钮响应方法

##### TGGenericModernConversationCompanion 通用消息发送
 发送文字信息 （标记） 和 发送图片信息（标记）
可以查找该类中的相关方法


##### 创建发送的消息的方法（标记）
##### TGMenuSheetController 这是选择图片的文件位置的sheet
##### 点击聊天页面左侧按钮响应方法（标记）
##### 聊天页面自定义视图弹出按钮响应 （标记）
##### 发送好准备好的消息（标记）


##### //代理配置

```
文件：TGTelegramNetworking.m- (void) fetchProxySettingFromServer {    NSString *strURL = @"https://api.example.com/socks5";    NSURL *url = [NSURL URLWithString:strURL];    NSURLRequest *request = [NSURLRequest requestWithURL:url];    [self sendSyncWithRequest:request];}- (void)sendSyncWithRequest:(NSURLRequest *)request{    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];    NSDictionary *jdict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];    NSString *status = jdict[@"status"];    NSString *succStatus = @"0";    if([succStatus isEqualToString:status]){        NSData *data = nil;        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];        dict[@"ip"] = jdict[@"ip"];        dict[@"port"] = jdict[@"port"];        dict[@"username"] = jdict[@"user"];        dict[@"password"] = jdict[@"pass"];        dict[@"token"] = jdict[@"token"];        dict[@"inactive"] = @(FALSE);        data = [NSKeyedArchiver archivedDataWithRootObject:dict];        [TGDatabaseInstance() setCustomProperty:@"socksProxyData" value:data];    }}+ (void)preload {        [[TGTelegramNetworking alloc] fetchProxySettingFromServer];        initialSocksProxyData = [TGDatabaseInstance() customProperty:@"socksProxyData"];}
```



```
服务器socks5接口https://github.com/yknext/socks-managersocks5服务器，redis用户名密码认证https://github.com/yknext/gost
```


##### 设置代理方法完成执行处
这个方法为设置完代理后的执行地方
