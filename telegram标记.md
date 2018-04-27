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
##### 开发新加参数（标记）
##### 聊天框自适应视图方法 （标记）
##### 点击对话左侧按钮弹出选择的ActionSheetmenu（标记）
##### //RootController所在位置 （标记）
#####  //tabbar设置title和image  （标记）
##### 转发消息发送
##### 创建MessageViewModel （标记）
##### 设置链接信息的webfooter方法 （标记)
##### 替换红包位置判断执行处  （标记)

##### TGMessage 消息载体 （标记，log）
##### 获取链接附加内容的地方 （标记）
##### //代理配置
##### 模型视图构造处：预计在此处更换视图（标记）
##### chat_envelope_new chat_envelope_old （标记）红包图片
##### 发送的消息添加到视图上时构建模型 （标记）
##### 尝试二次更新视图 （标记）
##### 修改发送红包视图大小失败的地方 （标记）
##### 钱包功能切入地方 （标记）




#####  进入登陆输入手机号码页面    （标记）
##### 输入电话号码下一步执行     （标记）

##### 输入验证码页面 （标记）

##### 此处添加登陆账号操作 （标记）
##### 此处要预存一下登陆的电话号码 （标记）

##### 添加登录后用户信息获取判断与设置 （标记）

```
文件：TGTelegramNetworking.m- (void) fetchProxySettingFromServer {    NSString *strURL = @"https://api.example.com/socks5";    NSURL *url = [NSURL URLWithString:strURL];    NSURLRequest *request = [NSURLRequest requestWithURL:url];    [self sendSyncWithRequest:request];}- (void)sendSyncWithRequest:(NSURLRequest *)request{    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];    NSDictionary *jdict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];    NSString *status = jdict[@"status"];    NSString *succStatus = @"0";    if([succStatus isEqualToString:status]){        NSData *data = nil;        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];        dict[@"ip"] = jdict[@"ip"];        dict[@"port"] = jdict[@"port"];        dict[@"username"] = jdict[@"user"];        dict[@"password"] = jdict[@"pass"];        dict[@"token"] = jdict[@"token"];        dict[@"inactive"] = @(FALSE);        data = [NSKeyedArchiver archivedDataWithRootObject:dict];        [TGDatabaseInstance() setCustomProperty:@"socksProxyData" value:data];    }}+ (void)preload {        [[TGTelegramNetworking alloc] fetchProxySettingFromServer];        initialSocksProxyData = [TGDatabaseInstance() customProperty:@"socksProxyData"];}
```



```
服务器socks5接口https://github.com/yknext/socks-managersocks5服务器，redis用户名密码认证https://github.com/yknext/gost
```




##### 设置代理方法完成执行处
这个方法为设置完代理后的执行地方



//我使用的代理方法

```
[[MTSocksProxySettings alloc] initWithIp:_addressItem.username port:(uint16_t)[_portItem.username intValue] username:_usernameItem.username password:_passwordItem.username]
  NSData *data = nil;
            if (updatedSettings != nil) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                if (updatedSettings.ip != nil && updatedSettings.port != 0) {
                    dict[@"ip"] = updatedSettings.ip;
                    dict[@"port"] = @(updatedSettings.port);
                }
                if (updatedSettings.username.length != 0) {
                    dict[@"username"] = updatedSettings.username;
                }
                if (updatedSettings.password.length != 0) {
                    dict[@"password"] = updatedSettings.password;
                }
                dict[@"inactive"] = @(inactive);
                data = [NSKeyedArchiver archivedDataWithRootObject:dict];
            } else {
                data = [NSData data];
            }
            [TGDatabaseInstance() setCustomProperty:@"socksProxyData" value:data];
            strongSelf->_proxySettings = inactive ? nil : updatedSettings;
            strongSelf->_useProxyItem.variant = (!inactive && updatedSettings != nil) ? TGLocalized(@"ChatSettings.ConnectionType.UseSocks5") : TGLocalized(@"GroupInfo.SharedMediaNone");
            
            [[[TGTelegramNetworking instance] context] updateApiEnvironment:^MTApiEnvironment *(MTApiEnvironment *apiEnvironment) {
                return [apiEnvironment withUpdatedSocksProxySettings:inactive ? nil : updatedSettings];
            }];
```
