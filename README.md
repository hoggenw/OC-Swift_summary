# OC-Swift_summary
navigationController的popViewController需要一个返回项，否则会有警告，可以用以下方式去掉警告
```
_ = self.navigationController?.popViewController(animated: true)
```
修改关联仓库的邮箱
```
git remote origin set-url [url]
```
如果你想先删后加的话
```
git remote rm origin
git remote add origin [url]
```
查看用户名和邮箱地址：
```
git config user.name
git config user.email
```
修改提交的用户名和Email
```
git config --global user.name "Your Name"  
 git config --global user.email you@example.com
```