# OC-Swift_summary
###navigationController的popViewController需要一个返回项，否则会有警告，可以用以下方式去掉警告
```
_ = self.navigationController?.popViewController(animated: true)
```
###修改关联仓库的邮箱
```
git remote origin set-url [url]
```
###如果你想先删后加的话
```
git remote rm origin
git remote add origin [url]
```
###查看用户名和邮箱地址：
```
git config user.name
git config user.email
```
###修改提交的用户名和Email
```
git config --global user.name "Your Name"  
 git config --global user.email you@example.com
```

###基本的正则表达式的应用
```
NSString *telePhoneCharset = @"((\\d{11})|^((\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})|(\\d{4}|\\d{3})-(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1})|(\\d{7,8})-(\\d{4}|\\d{3}|\\d{2}|\\d{1}))$)"; //座机加手机号
```
###简单手机的正则表达式
```
 regex = @"^1\\d{10}$";
```
###身份证号码的正则表达式
```
regex = @"^(\\d{15}$|^\\d{18}$|^\\d{17}(\\d|X|x))$";
```
###11月4日
获取字符串size的方法
```
"A".size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 20)])
```
方法OC
```
[self boundingRectWithSize:maxSize options:options attributes:attributes context:nil];
```

改为swift
```
self.boundingRect(with: maxSize,options: options,attributes: attributes,context: nil)
```
###小tip
涉及到视图显示的，查一下视图显示结果或许更好

###https_afnet情况下自签名访问
#pragma mark - https测试
    //AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy = securityPolicy;
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    manager.securityPolicy.validatesDomainName = NO;