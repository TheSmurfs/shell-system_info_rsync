# 综合实验 
（组内成员共同讨论完成，组长统一负责） 要求如下： 

1) 每位成员提供2台全新LINUX主机，每台主机需要多个硬盘多个网卡，硬盘容量组内自定义，硬盘或网上数量>=2。（例如有6位成员，则组内就有12台LINUX主机可用） 

2) 每台主机都需要使用bond通信，组内其中一台LINUX主机专门用于存放备份文件，该台LINUX主机不需要安装MYSQL，创建一个文件系统/backup，用于存放备份文件，该目录需要使用LVM进行管理。 组内其它的LINUX主机都需要安装源码MYSQL-5.7.14，并且初始化时指定的datadir目录需要使用lvm进行管理 注意：刚装好MYSQL后马上创建一个快照，以便后面的工具验证。 

3) 按天对mysql的日志文件进行转储，转储规则是日志文件大于20M，保留7份最新的转储日志文件。

4) 开机能自动启动mysql服务。

5) 编写巡检工具： l 该工具能够在组内任意一台LINUX主机上运行并且能一键式完成以下工作。 l 该工具能够收集本机的和远程收集组内其它LINUX主机的信息，包括：OS信息、主机名、网卡信息、路由表信息、CPU信息、物理内存和交换空间信息、硬盘信息、文件系统信息、进程信息。不同类型的信息需要存放在不同的文件。 这些信息都需要按主机IP进行存放在不同的目录中。 l 该工具能够分析每台主机是否健康并且生成健康报告（后缀名为.csv的文件，每行内容以逗号为分隔符）。 在WINDOWS上看到的健康报告文件（CSV文件）如下图：

![image](http://note.youdao.com/yws/public/resource/b0699f571b79f520be12ce033e9345f5/xmlnote/F3BEDAF829AA4004AA507BAD44F833BB/1646)

健康检查标准如下： CPU检查：查看CPU总核数是否等于物理CPU个数X每个CPU的核数，不相等就报异常 内存检查：如果使用了交换空间，就报异常 硬盘空间：检查/dev开头的空间（除了特殊的），是否已用超过80%，超过就报异常 文件系统读写检查：除了特殊的文件系统，都要能够读写，否则就报异常 进程检查：检查mysql服务是否存在，不存在就报异常。 健康报告内容格式如下图：

![image](http://note.youdao.com/yws/public/resource/b0699f571b79f520be12ce033e9345f5/xmlnote/7DE616863C894F4BAACCC9498AC41F4C/1647)

l 该工具最后还要将前面收集到的所有主机信息以及所有主机的健康报告，统一压缩打包并通过rsync工具备份到备份机器上，远程备份目录为/backup/system_check/ 压缩文件名需要带日期时间，并且保证远程备份目录中的文件只保留3份新的。

6) 编写自动部署“监控mysql服务以及自动备份datadir目录”的工具： l 该工具能在组内任意一台LINUX主机上运行并且能只需在任意一台机器上执行一次本工具，就能完成以下工作。 l 该工具能够在所有MYSQL的主机（本机或者远程主机）上，创建计划任务：每天04：00自动将datadir目录通过rsync工具备份到备份机器上，远程备份目录为/backup/mysql_datadir/，按主机IP进行存放在不同的目录中。 l 该工具能够在所有MYSQL的主机（本机或者远程主机）上，创建计划任务： 每分钟检查mysql的服务是否运行，如果停止运行，则自动拉起mysql服务。 

7) 以上2个工具，都要求尽量灵活，不能硬编码。 例如：添加、删除一台主机，或者一台主机的IP有变化，不需要修改脚本就能让工具能够正常工作。 考虑点可能有：主机IP、用户名密码、备份目录、计划任务的时间、空间阈值等 

8) 以上2个工具，只要在组内的随意一台主机上运行就能完成相应的功能，不需要在每台主机上都运行，但要保证工具能够在每台主机上正常运行工作。

9) 可以使用公私钥或者expect来解决自动登录的问题。 

10) rsync工具需要使用校验选项，确保远程备份的文件是完整的。 

11) 工具需要由每位成员共同开发完成，组内讨论后组长负责分配每位成员需要开发的功能。有不清楚的地方，可以派组长来咨询老师。