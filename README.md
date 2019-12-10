# soulmanga

# 创建新项目

```
vapor new soulmangaapi --branch=4
```

# Ubuntu 下进行部署

# 安装 swift

https://swift.org/

# 安装sqlite 库

```
apt-get update -y && apt-get install -y libsqlite3-dev
```

# 构建二进制

```
swift build -c release
```

# migrate 数据库

```
./Run migrate
```

# 后台运行

```
nohup vapor run serve &
```