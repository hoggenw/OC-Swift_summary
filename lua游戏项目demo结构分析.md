#一、入口选择src文件下main.lua
   ####主要记录要点
   
   * main.lua文件中cc.FileUtils:getInstance():addSearchPath("base/res/")在新建项目中不存在，但判定不影响，不做修改
   * config.lua中做部分修改
   * cocos文件夹下 init.lua中代码添加debug优先输出（不确定）
   * packages文件下appbase 添加方法debug错误优先输出（不确定）