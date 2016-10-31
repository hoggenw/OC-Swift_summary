# OC-Swift_summary
navigationController的popViewController需要一个返回项，否则会有警告，可以用以下方式去掉警告
```
_ = self.navigationController?.popViewController(animated: true)
```