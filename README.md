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