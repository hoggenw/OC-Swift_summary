# SVN  & Git

PS：本文所有`$`符号之后为在终端中执行的命令。

## 版本控制系统

### 版本控制

版本控制（Version Control）的作用是追踪文件的变化。为什么需要版本控制？简单说，就是当你出错了，可以很容易地回到没出错时的状态。

你可能已经在不知不觉中，布置了自己的版本控制系统。比如，创建了类似下面这样的文件名：

* 论文_0510.doc
* 论文_0514.doc
* 论文_0521.doc
* 论文_修改版.doc
* 论文_最终不修改版.doc

这就是软件中为什么有"Save As"命令的原因。它使得你可以在不破坏源文件的基础上，得到一个类似的新文件。文件的多版本保存是一个常见问题，通常的解决办法是这样的：

* 做一个文件备份（比如Document.old.txt）。
* 在文件名中加入版本号或日期（比如Document_V1.txt，DocumentMarch2007.txt）。
* 在多人编辑的环境下，共享一个文件目录，并且要求每个人编辑完以后，在文件上做出标识。

### 什么是版本控制系统（VCS）？

大型的、频繁修改的、多人编写的软件项目，需要一个版本控制系统（简称VCS，行话叫做"文件数据库"），追踪文件的变化，避免出现混乱。

一次典型的使用过程是这样的：

 爱丽丝add一个文件（list.txt）进入repo。然后，她又把这个文件check out，做了一次编辑（在文件中加入milk这个单词）。接着，她将修改后的文件check in，并附有一条checking message（"加入了新的条目"）。第二天早上，鲍勃update了他本地的working set，看到了list.txt的最新修订版，其中包含了单词"milk"。如果他使用changelog或diff，都可以发现前一天爱丽丝加入"milk"这个词。

网上有许多VCS软件可供选择，并且都有详细的教程或手册，比如SVN、CVS、RCS、Git、Perforce等等。

### 版本库

版本库又名仓库，英文名repository，你可以简单理解成一个目录，这个目录里面的所有文件都可以被版本控制系统管理起来，每个文件的修改、删除，都能跟踪，以便任何时刻都可以追踪历史，或者在将来某个时刻可以“还原”。



## SVN

在Mac环境下，由于Mac自带了SVN的服务器端和客户端功能，所以我们可以在不装任何第三方软件的前提下使用SVN功能，不过还需做一下简单的配置。

### 为什么使用SVN

1. **进行权限管理，针对不同的人，开放不同的权限。**比如Alex是进行A项目的，Bob进行B项目的，那么SVN可以有效的管理每个人看到的项目，Alex不可能获得Bob的项目，同样Bob也不可能获得Alex的项目。
2. **对于代码进行追踪，代码不会遗失。**不如今天代码修改乱了，需要恢复到某一天的，那么我们只需要选择一下恢复的日期即可进行恢复。

### 搭建SVN服务器

#### 1. 创建代码仓库，存储客户端上传的代码

先在`~/Desktop`目录（这个目录可以是任意非中文路径）新建一个svn目录，以后可以在svn目录下创建多个仓库目录。

打开终端，切换到该目录`cd ~/Desktop/svn`，创建一个`learnsvn`仓库，输入命令：`svnadmin create ./learnsvn`，执行成功后，会发现在该目录下多了一个LimitFree目录。

#### 2. 配置SVN的用户权限

主要是修改./learnsvn/conf目录下的三个文件

- 打开svnserve.conf，将下列配置项前面的#和空格都去掉
  
  ``` shell
  # anon-access = read  
  # auth-access = write  
  # password-db = passwd
  # authz-db = authz
  ```
  
  anon-access = read代表匿名访问的时候是只读的，若改为anon-access = none代表禁止匿名访问，需要帐号密码才能访问
  
- 打开passwd，在[users]下面添加帐号和密码
  
  ``` shell
  [users]
  # harry = harryssecret
  # sally = sallyssecret
  chaosky = 123
  student = 123456
  ```
  
  帐号是chaosky，密码是123
  
- 打开authz，配置用户组和权限
  
  我们可以将在passwd里添加的用户分配到不同的用户组里，以后的话，就可以对不同用户组设置不同的权限，没有必要对每个用户进行单独设置权限。
  
  在[groups]下面添加组名和用户名，多个用户之间用逗号(,)隔开
  
  ``` shell
  [groups]  
  topgroup=chaosky,student
  ```
  
  说明chaosky和student都是属于topgroup这个组的，接下来再进行权限配置。
  
  使用[/]代表svn服务器中的所有资源库
  
  ``` shell
  [/]  
  @topgroup = rw
  ```
  
  上面的配置说明topgroup这个组中的所有用户对所有资源库都有读写(rw)权限，组名前面要用@
  
  如果是用户名，不用加@，比如chaosky这个用户有读写权限
  
  ``` shell
  [/]  
  chaosky = rw
  ```

#### 3. 启动SVN服务器

在终端输入命令：`svnserve -d -r ~/Desktop/svn`或`svnserve -d -r ~/Desktop/svn/learnsvn`

没有任何提示就说明启动成功了
I
#### 4. 关闭SVN服务器

打开活动监视器，输入svnserve，强制退出进程。

### 使用SVN客户端功能

SVN客户端有两种使用方式，命令行和GUI界面软件（CornerStone）

#### 命令行工具

``` shell
usage: svn <subcommand> [options] [args]
Subversion command-line client.
Type 'svn help <subcommand>' for help on a specific subcommand.
Type 'svn --version' to see the program version and RA modules
  or 'svn --version --quiet' to see just the version number.

Most subcommands take file and/or directory arguments, recursing
on the directories.  If no arguments are supplied to such a
command, it recurses on the current directory (inclusive) by default.

Available subcommands:
   add
   auth
   blame (praise, annotate, ann)
   cat
   changelist (cl)
   checkout (co)
   cleanup
   commit (ci)
   copy (cp)
   delete (del, remove, rm)
   diff (di)
   export
   help (?, h)
   import
   info
   list (ls)
   lock
   log
   merge
   mergeinfo
   mkdir
   move (mv, rename, ren)
   patch
   propdel (pdel, pd)
   propedit (pedit, pe)
   propget (pget, pg)
   proplist (plist, pl)
   propset (pset, ps)
   relocate
   resolve
   resolved
   revert
   status (stat, st)
   switch (sw)
   unlock
   update (up)
   upgrade

Subversion is a tool for version control.
For additional information, see http://subversion.apache.org/
```

#### CornerStone

![](http://7vzrbk.com1.z0.glb.clouddn.com/images/QQ20151223-0@2x.png)

### 添加代码仓库

![](http://7vzrbk.com1.z0.glb.clouddn.com/images/QQ20151223-1@2x.png)

### 填写SVN仓库信息

![](http://7vzrbk.com1.z0.glb.clouddn.com/images/QQ20151223-2@2x.png)

### 基本操作

#### checkout（检出）

#### add（添加文件）

#### delete（删除文件）

#### modify （修改文件）

#### commit（提交）

#### update（更新）

#### resolve conflict（解决冲突）

#### revert（恢复初始状态）



## Git

### 安装Git

直接从AppStore安装Xcode，Xcode集成了Git，不过默认没有安装，你需要运行命令`xcode-select --install`安装“Command Line Tools”，点“Install”就可以完成安装了。

### 创建版本库

1. 选择一个合适的地方，创建一个空目录：
   
   ``` shell
   $ mkdir learngit
   $ cd learngit
   ```
   
2. 通过`git init`命令把这个目录变成Git可以管理的仓库：
   
   ``` shell
   $ git init
   Initialized empty Git repository in /Users/Chaosky/Desktop/learngit/.git/
   ```
   
   瞬间Git就把仓库建好了，而且告诉你是一个空的仓库（empty Git repository），细心的读者可以发现当前目录下多了一个.git的目录，这个目录是Git来跟踪管理版本库的，没事千万不要手动修改这个目录里面的文件，不然改乱了，就把Git仓库给破坏了。

### 把文件添加到版本库

1. 编写一个README.md文件，内容如下：
   
   ``` 
   Git is a version control system.
   Git is free software.
   ```
   
   一定要放到learngit目录下（子目录也行），因为这是一个Git仓库，放到其他地方Git再厉害也找不到这个文件。
   
2. 用命令`git add`告诉Git，把文件添加到仓库：
   
   ``` shell
   $ git add readme.txt
   ```
   
   执行上面的命令，没有任何显示，这就对了，Unix的哲学是“没有消息就是好消息”，说明添加成功。
   
3. 用命令`git commit`告诉Git，把文件提交到仓库：
   
   ``` shell
   $ git commit -m "wrote a readme file"
   [master (root-commit) cb926e7] wrote a readme file
   1 file changed, 2 insertions(+)
   create mode 100644 readme.txt
   ```
   
   简单解释一下git commit命令，-m后面输入的是本次提交的说明，可以输入任意内容，当然最好是有意义的，这样你就能从历史记录里方便地找到改动记录。
   
   git commit命令执行成功后会告诉你，1个文件被改动（我们新添加的readme.txt文件），插入了两行内容（readme.txt有两行内容）。
   
   为什么Git添加文件需要add，commit一共两步呢？因为commit可以一次提交很多文件，所以你可以多次add不同的文件，比如：
   
   ``` shell
   $ git add file1.txt
   $ git add file2.txt file3.txt
   $ git commit -m "add 3 files."
   ```

### 工作区和暂存区

- #### 工作区（Working Directory）
  
  就是你在电脑里能看到的目录。


- #### 版本库（Repository）
  
  Git的版本库里存了很多东西，其中最重要的就是称为stage（或者叫index）的暂存区，还有Git为我们自动创建的第一个分支master，以及指向master的一个指针叫HEAD。
  
  ![](http://www.liaoxuefeng.com/files/attachments/001384907702917346729e9afbf4127b6dfbae9207af016000/0)
  
  前面讲了我们把文件往Git版本库里添加的时候，是分两步执行的：
  
  第一步是用`git add`把文件添加进去，实际上就是把文件修改添加到暂存区；
  
  ![版本库状态](http://www.liaoxuefeng.com/files/attachments/001384907720458e56751df1c474485b697575073c40ae9000/0)
  
  第二步是用`git commit`提交更改，实际上就是把暂存区的所有内容提交到当前分支。
  
  ![版本库状态](http://www.liaoxuefeng.com/files/attachments/0013849077337835a877df2d26742b88dd7f56a6ace3ecf000/0)
  
  你可以简单理解为，需要提交的文件修改通通放到暂存区，然后，一次性提交暂存区的所有修改。
  
  ​

### 版本库管理

- #### git status
  
  查看仓库当前的状态，要随时掌握工作区的状态，使用git status命令。
  
- #### git diff
  
  如果git status告诉你有文件被修改过，用git diff可以查看修改内容。
  
- #### git log
  
  显示从最近到最远的提交日志。在Git中，用HEAD表示当前版本，也就是最新的提交，上一个版本就是HEAD^ ，上上一个版本就是HEAD^^ ，当然往上100个版本写100个^比较容易数不过来，所以写成HEAD~100。
  
- #### git reset --hard commit_id
  
  在版本的历史之间进行切换，`commit_id`为提交版本的id。
  
- #### git reflog
  
  用来记录你的每一次命令
  
- #### 撤销修改
  
  场景1：当你改乱了工作区某个文件的内容，想直接丢弃工作区的修改时，用命令`git checkout -- README.md`。
  
  场景2：当你不但改乱了工作区某个文件的内容，还添加到了暂存区时，想丢弃修改，分两步，第一步用命令`git reset HEAD README.md`，就回到了场景1，第二步按场景1操作。
  
- #### git rm
  
  用于删除一个文件。如果一个文件已经被提交到版本库，那么你永远不用担心误删，但是要小心，你只能恢复文件到最新版本，你会丢失最近一次提交后你修改的内容。

### 远程仓库

分布式版本控制系统通常也有一台充当“中央服务器”的电脑，而充当"中央服务器"角色的仓库就是远程仓库，但这个服务器的作用仅仅是用来方便“交换”大家的修改，没有它大家也一样干活，只是交换修改不方便而已。

如果有自己的私有仓库地址，则无需执行下面几个操作。

- #### 注册远程仓库账号
  
  - Git@OSC：开源中国Git托管平台
    
    地址：<http://git.oschina.net>
    
  - Github：世界最大的Git项目托管平台
    
    地址：<https://github.com>
    
  - Coding：国内新兴的Git托管平台
    
    地址：<https://coding.net>
  
- #### 添加公钥到Git托管平台
  
  1. ##### 生成公钥
     
     SSH Keys：SSH key 可以让你在你的电脑和 Git托管平台之间建立安全的加密连接。
     
     你可以按如下命令来生成sshkey：
     
     ``` shell
     $ ssh-keygen -t rsa -C "xxxxx@xxxxx.com"
     ```
     
     其中`xxxxx@xxxxx.com`需要填写邮箱信息
     
     生成SSH key时，如果不清楚需要输入的信息，可以全部输入Enter键。
     
  2. ##### 查看你的public key，并把他添加到Git托管平台
     
     ``` shell
     $ cat ~/.ssh/id_rsa.pub
     ```
     
     具体添加的位置，查看具体的托管平台。一般来说，在个人资料中可以找到`SSH-KEYS`类似的字样就是添加公钥的地方。
     
  3. ##### 测试是否添加成功
     
     测试Git@OSC输入命令：
     
     ``` shell
     $ ssh -T git@git.oschina.net
     Welcome to Git@OSC, yourname! 
     ```
     
     测试Github输入命令：
     
     ``` shell
     $ ssh -T git@github.com
     Hi chaoskyme! Youve successfully authenticated, but GitHub does not provide shell access.
     ```
  
  生成SSH key只需要生成一次，不同的网站再将公钥拷贝到网站上即可。
  
- #### 在Git托管平台上创建项目


- #### 添加远程仓库
  
  关联一个远程仓库命令：
  
  ``` shell
  $ git remote add origin git@server-name:path/repo-name.git
  ```
  
  其中`origin`表示远程仓库的别名，默认为`origin`
  
  `git@server-name:path/repo-name.git`表示项目在Git托管平台上的ssh 地址。
  
  关联远程仓库只需要执行上面的命令**一次**即可。
  
  关联后，第一次推送master分支的所有内容命令：
  
  ``` shell
  $ git push -u origin master
  ```
  
  此后，每次本地提交后，只要有必要，推送最新修改就可以使用命令：
  
  ``` shell
  $ git push origin master
  ```
  
  分布式版本系统的最大好处之一是在本地工作完全不需要考虑远程库的存在，也就是有没有联网都可以正常工作，而SVN在没有联网的时候是拒绝干活的！当有网络的时候，再把本地提交推送一下就完成了同步，真是太方便了！
  
- #### 克隆远程仓库
  
  ``` shell
  $ git clone git@server-name:path/repo-name.git <repo-name>
  ```
  
- #### 从远程分支获取最新版本到本地，有2个命令
  
  - **git fetch**：相当于是从远程获取最新版本到本地，不会自动merge
    
    ``` shell
    $ git fetch origin master
    $ git log -p master..origin/master
    $ git merge origin/master
    ```
    
    以上命令的含义：
    
    首先从远程的origin的master主分支下载最新的版本到origin/master分支上;
    
    然后比较本地的master分支和origin/master分支的差别;
    
    最后进行合并。
    
  - **git pull**：相当于是从远程获取最新版本并merge到本地
    
    ``` shell
    $ git pull origin master
    ```
    
    上述命令其实相当于git fetch 和 git merge
  
  在实际使用中，git fetch更安全一些
  
  因为在merge前，我们可以查看更新情况，然后再决定是否合并

### 分支管理

Git鼓励大量使用分支：

查看分支：`git branch`

创建分支：`git branch <name>`

切换分支：`git checkout <name>`

创建+切换分支：`git checkout -b <name>`

合并某分支到当前分支：`git merge <name>`

删除分支：`git branch -d <name>`

当Git无法自动合并分支时，就必须首先解决冲突。解决冲突后，再提交，合并完成。

用`git log --graph`命令可以看到分支合并图。

推送分支，就是把该分支上的所有本地提交推送到远程库。推送时，要指定本地分支，这样，Git就会把该分支推送到远程库对应的远程分支上：

``` shell
$ git push origin master
```



### 标签管理

`git tag <name>`用于新建一个标签，默认为HEAD，也可以指定一个commit id；

`git tag -a <tagname> -m "blablabla..."`可以指定标签信息；

`git tag -s <tagname> -m "blablabla..."`可以用PGP签名标签；

`git tag`可以查看所有标签

`git push origin <tagname>`可以推送一个本地标签；

`git push origin —tags`可以推送全部未推送过的本地标签；

`git tag -d <tagname>`可以删除一个本地标签；

`git push origin :refs/tags/<tagname>`可以删除一个远程标签。



### Git常用命令速查表

![](https://dn-coding-net-production-pp.qbox.me/100e4dc6-0317-409f-9ff9-935890315137.jpg)

### 参考文章

1. <http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000>
2. 参考书籍：《Git权威指南》
3. <http://backlogtool.com/git-guide/cn/>

## SVN vs Git （集中式 vs 分布式）

先说集中式版本控制系统，版本库是集中存放在中央服务器的，而干活的时候，用的都是自己的电脑，所以要先从中央服务器取得最新的版本，然后开始干活，干完活了，再把自己的活推送给中央服务器。中央服务器就好比是一个图书馆，你要改一本书，必须先从图书馆借出来，然后回到家自己改，改完了，再放回图书馆。

![central-repo](http://www.liaoxuefeng.com/files/attachments/001384860735706fd4c70aa2ce24b45a8ade85109b0222b000/0)

集中式版本控制系统最大的毛病就是必须联网才能工作。

那分布式版本控制系统与集中式版本控制系统有何不同呢？首先，分布式版本控制系统根本没有“中央服务器”，每个人的电脑上都是一个完整的版本库，这样，你工作的时候，就不需要联网了，因为版本库就在你自己的电脑上。既然每个人电脑上都有一个完整的版本库，那多个人如何协作呢？比方说你在自己电脑上改了文件A，你的同事也在他的电脑上改了文件A，这时，你们俩之间只需把各自的修改推送给对方，就可以互相看到对方的修改了。

和集中式版本控制系统相比，分布式版本控制系统的安全性要高很多，因为每个人电脑里都有完整的版本库，某一个人的电脑坏掉了不要紧，随便从其他人那里复制一个就可以了。而集中式版本控制系统的中央服务器要是出了问题，所有人都没法干活了。

在实际使用分布式版本控制系统的时候，其实很少在两人之间的电脑上推送版本库的修改，因为可能你们俩不在一个局域网内，两台电脑互相访问不了，也可能今天你的同事病了，他的电脑压根没有开机。因此，分布式版本控制系统通常也有一台充当“中央服务器”的电脑，但这个服务器的作用仅仅是用来方便“交换”大家的修改，没有它大家也一样干活，只是交换修改不方便而已。

![distributed-repo](http://www.liaoxuefeng.com/files/attachments/0013848607465969378d7e6d5e6452d8161cf472f835523000/0)