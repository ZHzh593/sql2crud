# sql2crud

> **SQL 建表脚本 → 可运行的 Spring Boot + Vue 全栈 CRUD 项目，一步到位。**

给一个 `.sql` 文件，产出一套**能立刻 `mvn spring-boot:run` 起来**的完整工程：
Spring Boot 3.3.4 + MyBatis(XML) 后端、四套可选前端、建库脚本、运行说明、打包 ZIP。

Windows 桌面程序，**单文件 11.2 MB，免安装、免 Python 环境、双击即用**。

---

## 目录

- [它解决什么问题](#它解决什么问题)
- [下载与运行](#下载与运行)
- [四步生成一个项目](#四步生成一个项目)
- [生成的项目长什么样](#生成的项目长什么样)
- [每张表自动生成的接口](#每张表自动生成的接口)
- [功能开关](#功能开关)
- [五个齿轮：细粒度配置](#五个齿轮细粒度配置)
- [四套前端可选](#四套前端可选)
- [联表查询](#联表查询)
- [登录页](#登录页)
- [可视化画布设计器](#可视化画布设计器)
- [命令行模式与完整参数](#命令行模式与完整参数)
- [支持的 SQL 语法与类型映射](#支持的-sql-语法与类型映射)
- [已知限制](#已知限制)
- [常见问题](#常见问题)
- [第三方资源与许可](#第三方资源与许可)

---

## 它解决什么问题

做课设、机试、内部小后台时，最枯燥的一段永远是：**对着建表语句手写 entity / Mapper XML / Service / Controller / 前端列表页**。七八张表就是七八套近乎相同的样板代码，抄错一个字段名，编译或运行才炸。

这个工具把这段体力活自动化。你只需要维护 `.sql`（本来就要写的），其余由工具生成。

| 你输入 | 它输出 |
|---|---|
| `CREATE TABLE` 语句集合 | `pom.xml`、`application.yaml`、启动类、每张表的 Entity / Mapper 接口 / Mapper XML / Service / Controller、四套前端、`db/init.sql`、README、ZIP |

**生成的代码是干净的常规写法**——就是你自己会手写的那种，没有奇怪的抽象层、没有私有依赖、没有授权校验，拷进 IDEA 可以直接改。

---

## 下载与运行

### 下载

前往 [**Releases**](https://github.com/ZHzh593/sql2crud/releases/latest) 下载最新版 `sql2java.exe`。

### 系统要求

| 项 | 要求 |
|---|---|
| 操作系统 | Windows 10 / 11，**仅 x64** |
| 运行环境 | 无。不需要 Python、不需要 JDK、不需要 Node |
| 磁盘 | 约 30 MB（程序 11.2 MB + 生成物） |

### 完整性校验

```powershell
Get-FileHash .\sql2java.exe -Algorithm SHA256
```

当前版本应为：

```
2C555FCC6200122DC94D692A15B0BBA322A03B3CC37F262185654615F5732F94
```

### 首次运行提示

程序未做商业代码签名，Windows SmartScreen 会提示「已保护你的电脑」。

处理方式：点 **更多信息** → **仍要运行**。

---

## 四步生成一个项目

程序是四个页签，从左到右就是流程。

### ① 表结构

1. 点「浏览…」选中 `.sql` 文件
2. 点「解析 SQL」
3. 左侧列出所有表，**单击**查看字段映射，**双击**切换是否生成（✔ = 会生成）
4. 右侧显示每个字段：SQL 类型 → Java 类型、是否主键、是否必填、字段注释

### ② 功能与配置

- 勾选功能开关（Lombok / 分页 / 文件上传 / 报表 / 前端页面）
- 填「外观」：页面标题、主题色（有取色器和 7 个常用色块）
- 点开五个齿轮做细粒度配置（见下方[齿轮章节](#五个齿轮细粒度配置)）

### ③ 生成

1. 选输出目录
2. （可选）勾「生成后自动用 IDEA 打开」
3. 点「开始生成」

完成后会打印下一步命令：

```
mysql -uroot -p < out/demo/backend/src/main/resources/db/init.sql
cd out/demo/backend && mvn spring-boot:run
ZIP：D:\...\out\demo.zip
```

### ④ 可视化布局（可选）

在 900×520 画布上摆控件、拖坐标、右键绑定字段，生成绝对定位的前端页面。

---

## 生成的项目长什么样

```
out/<artifact>/
├─ backend/                          ← IDEA 打开这个（pom.xml 在这一层）
│  ├─ pom.xml                        Spring Boot 3.3.4 + mybatis-spring-boot-starter 3.0.3
│  └─ src/main/
│     ├─ java/com/example/<pkg>/
│     │  ├─ Application.java         启动类（勾上传时自动加 /uploads 静态映射）
│     │  ├─ entity/Xxx.java          字段 + 中文注释 + @JsonFormat 时间格式
│     │  ├─ mapper/XxxMapper.java
│     │  ├─ service/XxxService.java  写方法带 @Transactional
│     │  └─ controller/XxxController.java
│     └─ resources/
│        ├─ application.yaml         端口 / 数据源 / MyBatis / multipart 限制
│        ├─ db/init.sql              你上传的原始 SQL，可直接导入
│        └─ mapper/XxxMapper.xml     get / list / count / page / insert / update / delete
│
├─ frontend-vue/                     Vue 3 + Vite 真项目
│  ├─ package.json
│  ├─ vite.config.js                 已把 /api、/uploads 代理到后端端口
│  └─ src/{App.vue, api.js, main.js, style.css}
│
├─ frontend-static/                  Vue 离线版，零 npm，双击 index.html 就能看
├─ frontend-jquery/                  jQuery 1.12.4 本地版，带 start.bat
├─ frontend-html/                    原生 HTML + JS，零框架
└─ <artifact>.zip                    以上全部打包
```

**不勾「前后端分离」** 时退化为单工程：前端塞进 `backend/src/main/resources/static/`，`mvn spring-boot:run` 一个地址全解决。

---

## 每张表自动生成的接口

以表 `t_paper` 为例，类名前缀 `t_`/`tb_`/`tbl_`/`sys_` 会被剥掉（`t_paper → Paper`，`sys_user → SysUser`）。

| 方法 | 路径 | 参数 | 说明 |
|---|---|---|---|
| GET | `/api/paper/page` | `keyword`, `pageNum`, `pageSize` | 分页查询，返回 `{total, rows}` |
| GET | `/api/paper/get` | `id` | 按主键查一条 |
| POST | `/api/paper/save` | JSON body | 新增 |
| POST | `/api/paper/update` | JSON body | 修改 |
| GET | `/api/paper/delete` | `id` | 删除 |
| POST | `/api/paper/saveWithFile` | multipart + `file` | 仅勾上传且表内有 `*path*` 字段时生成 |

接口直接返回对象或字符串，**不做统一 Result 封装**——想改成 `{code,msg,data}` 自己加一层就行。

---

## 功能开关

| 开关 | 勾上之后 | 不勾 |
|---|---|---|
| **Lombok** | 实体用 `@Data`，代码量减半 | 生成完整 getter/setter |
| **分页** | 每张表多一个 `/page` 接口（count + limit）+ Service 的 `page()` | 只有 `/list` 返回 List |
| **文件上传** | 表内有 `*path*` 字段时生成 `/saveWithFile` + `uploads/` 目录映射 + yaml 里 multipart 限制 | 不生成上传代码 |
| **报表** | 生成 `ReportController`（`/api/report/counts` 各表条数）+ 前端「报表」页 | 不生成 |
| **前端页面** | 生成静态前端（含本地 `vue.global.prod.js`，离线可跑） | 只出后端 |

---

## 五个齿轮：细粒度配置

全部收在「② 功能与配置」页，点齿轮弹出。

### ⚙ 分页

- 每页默认条数
- 可选条数（如 `10,20,50`）
- 显示总条数 / 显示条数下拉 / 显示首页末页 —— 三个独立开关

落到后端 `@RequestParam(defaultValue="N")` 和前端 `SHOW_TOTAL` / `SHOW_SIZE_SELECT` / `SHOW_FIRST_LAST`。

### ⚙ 上传

- 最大 MB
- 允许扩展名（逗号分隔，白名单）
- 上传目录

同时写进 `application.yaml` 的 multipart 段和 Controller 里的 `MAX_UPLOAD_SIZE` / `ALLOWED_EXT` 双重校验。

### ⚙ 前端 / 端口

- Vue 端口、jQuery 端口、HTML 端口、Vue 离线版端口
- **是否前后端分离**

落到 `vite.config.js` 的 `server.port`、各前端目录的 `start.bat`、以及整体目录结构。

### ⚙ 联表查询

主表 + 关联列 + 从表 + 关联列 + 显示列，可加多条。

### ⚙ 登录

勾上后生成登录接口和三套前端登录遮罩。

---

## 四套前端可选

| 版本 | 依赖 | 启动方式 | 适合 |
|---|---|---|---|
| **Vue + Vite** | `npm install` | `npm run dev`（默认 5173，`/api` 自动代理到后端） | 要真做前后端分离 |
| **Vue 离线版** | 无，内置 `vue.global.prod.js` | 双击 `index.html` 或 `start.bat` | 离线环境、演示、答辩 |
| **jQuery 1.12.4** | 无，本地 `jquery.min.js` | 双击 `start.bat` | 老派风格、老师要求用 jQuery |
| **原生 HTML + JS** | 无 | 双击 `start.bat` | 不想碰框架 |

四套共用同一份按主题色生成的 CSS，界面风格一致：

- 顶栏主题色渐变 + 阴影，左侧菜单选中项填充主题色
- 统计卡片：白底 + 1px 边框 + 圆角 10px + 轻阴影
- 表格：表头浅蓝底、**隔行变色**、hover 高亮、操作列分色（修改蓝 / 删除红）
- 按钮：默认白底描边，主按钮主题色填充
- 底部灰字标注生成器与上传限制

**换配色只改一个地方**：工具里「主题色」填 `#e8590c`，重新生成，整套界面跟着变。

---

## 联表查询

典型场景：论文表 `t_paper` 里 `type` 存的是数字，要显示成类型中文名。

在 ⚙ 联表查询 里选：

```
主表 t_paper + 关联列 type + 从表 t_code + 关联列 id + 显示列 code_name
```

生成物：

```
PaperJoinMapper.java      pageJoin / countJoin
PaperJoinMapper.xml       LEFT JOIN t_code r ON r.id = p.type
PaperJoinService.java     count + offset/limit，默认条数走齿轮配置
PaperJoinController.java  GET /api/paper/join/page
实体 Paper 多一个字段       codeText（联表带出的中文名）
```

返回示例：

```json
{"total":2,"rows":[{"id":1,"title":"...","type":2,"codeText":"课程论文"}, ...]}
```

三套前端左侧菜单都会多一项「联表 · t_paper + t_code」，点进去是**只读列表**（分页 + 关键字），没有增删改。

> `count` 与 `list` 共用同一段 `<sql id="Where">`，保证分页不会算出空页。

---

## 登录页

勾 ⚙ 登录 后：

**后端** 生成 `LoginController`：

```
POST /api/login   {"username":"admin","password":"123456"}
→ 200 {"__ok":true,"user_name":"管理员","user_code":"admin","id":1}
```

**前端** 三套各多一个 `js/login.js`：

- 全屏登录遮罩（账号 / 密码 / 登录 / 重置）
- 未登录进不去
- 登录后 localStorage 记住，右上角显示「欢迎，xxx　退出」
- 空账号提示「请输入账号」，密码错提示「账号或密码错误」

> 登录逻辑是**明文比对用户表**，定位是演示/课设用，不是生产级认证。

---

## 可视化画布设计器

「④ 可视化布局」页是一块 900×520 画布，20px 网格，左上角为原点 `(0,0)`。

| 操作 | 效果 |
|---|---|
| 顶部 `+ 标签 / + 输入框 / + 下拉 / + 按钮 / + 表格` | 在画布左上角加控件 |
| **右键空白处** | 菜单：在这里添加控件 / 示例布局 / 清空 |
| **右键控件** | 属性…（改文字、**绑定字段**、X/Y/宽/高）/ 删除 |
| **左键拖动中间** | 移动，状态栏实时显示坐标 |
| **拖动四角蓝色角柄** | 改宽高 |
| `绑定表` 下拉 | 选定表后，「绑定字段」里就是该表的列名 |
| `示例布局` | 一键摆出「标签 + 输入框 + 按钮 + 表格」 |

勾了画布布局再生成，多出三个文件：

```
src/main/resources/static/designer.html     绝对定位页面
src/main/resources/static/js/designer.js    Vue 逻辑（列表 + 保存）
layout.json                                 布局存档（可再导入）
```

坐标怎么变成前端——就是一行 style：

```html
<input style="position:absolute;left:150px;top:18px;width:260px;height:28px;"
       placeholder="请输入标题" v-model="form.title">
```

- `left/top` = 拖出来的坐标
- `v-model` = 右键绑定的字段
- 按钮 → `@click="save"`，POST 到 `/api/{表}/save`
- 表格 → `v-for` 渲染 `/api/{表}/page` 的 `rows`

布局 JSON 也可以手写：

```json
{
  "table": "t_paper",
  "widgets": [
    {"type": "input",  "x": 150, "y": 18,  "w": 260, "h": 28,  "text": "请输入标题", "field": "title"},
    {"type": "button", "x": 150, "y": 140, "w": 110, "h": 32,  "text": "保存"},
    {"type": "table",  "x": 30,  "y": 190, "w": 700, "h": 260}
  ]
}
```

---

## 命令行模式与完整参数

适合批处理和自动化。

```bat
sql2java.exe --cli 输入.sql 输出目录 ^
  --group com.example --artifact demo --pkg com.example.demo --port 8080 ^
  --db-host 127.0.0.1 --db-port 3306 --db paper_db --db-user root --db-pass root ^
  --lombok 1 --pagination 1 --upload 1 --report 1 --vue 1 --zip 1 ^
  --open-idea 0 ^
  --title "论文管理系统" --theme "#2f6fed" ^
  --page-size 5 --page-sizes "5,10,20,50" ^
  --show-total 1 --show-size-select 1 --show-first-last 0 ^
  --upload-max-mb 10 --upload-exts "pdf,doc,docx" --upload-dir uploads ^
  --separate 1 --vue-port 5173 --jquery-port 8081 --html-port 8082 --static-port 8083 ^
  --login 1 ^
  --join "t_paper:type:t_code:id:code_name" ^
  --layout layout_paper.json
```

| 参数 | 说明 |
|---|---|
| `--cli` | 启用命令行模式 |
| `--artifact` / `--pkg` / `--group` | 项目名 / 包名 / groupId |
| `--port` | 后端端口 |
| `--db-host` `--db-port` `--db` `--db-user` `--db-pass` | 数据源 |
| `--lombok` `--pagination` `--upload` `--report` `--vue` `--zip` | 对应界面勾选框（1/0） |
| `--open-idea` | 1 = 生成完直接 IDEA 打开 |
| `--title` / `--theme` | 页面标题 / 主题色 |
| `--page-size` / `--page-sizes` | 默认条数 / 下拉可选 |
| `--show-total` `--show-size-select` `--show-first-last` | 分页三开关 |
| `--upload-max-mb` `--upload-exts` `--upload-dir` | 上传限制 |
| `--separate` | 1 = 前后端分目录 |
| `--vue-port` `--jquery-port` `--html-port` `--static-port` | 各前端端口 |
| `--login` | 1 = 生成登录页 |
| `--join` | 联表配置，格式 `主表:列:从表:列:显示列`，可写多次 |
| `--layout` | 画布布局 JSON 路径 |

---

## 支持的 SQL 语法与类型映射

### 语法范围

- `CREATE TABLE [IF NOT EXISTS] 表名 (...)`，表名可用反引号 / 双引号 / 方括号包裹
- 列定义：`列名 类型(...) [NOT NULL] [AUTO_INCREMENT] [PRIMARY KEY] [COMMENT '...']`
- 表级 `PRIMARY KEY (...)` 会识别；`UNIQUE / KEY / INDEX / CONSTRAINT / FOREIGN KEY` 跳过（不生成索引与约束代码）
- `--` 行注释与 `/* */` 块注释会被剥离

### 类型映射

| SQL 类型 | Java 类型 |
|---|---|
| `BIGINT` | `Long` |
| `INT` / `INTEGER` / `SMALLINT` / `MEDIUMINT` / `TINYINT` | `Integer` |
| `DECIMAL` / `NUMERIC` / `DOUBLE` / `FLOAT` / `REAL` | `BigDecimal` |
| `DATETIME` / `TIMESTAMP` / `DATE` | `LocalDateTime` |
| `TIME` | `LocalTime` |
| `VARCHAR` / `CHAR` / `NVARCHAR` / `TEXT` / `LONGTEXT` / `MEDIUMTEXT` / `TINYTEXT` / `JSON` | `String` |
| `BLOB` / `LONGBLOB` / `BINARY` / `VARBINARY` | `byte[]` |
| 其他未识别 | `String` |

### 命名转换

| 输入 | 输出 |
|---|---|
| `t_paper` | 类 `Paper`，路径 `/api/paper` |
| `sys_user` | 类 `SysUser`，路径 `/api/sysUser` |
| `user_name` | 属性 `userName` |
| 表名撞类名（`user` / `t_user` / `sys_user`） | 自动去重为 `User` / `TUser` / `SysUser` |

---

## 已知限制

- **只做单表 CRUD + 一层多对一联表**（主表外键 → 从表主键）。一对多、多对多未支持
- **联表页只读**，改数据回单表页
- **主题色换色需要重新生成**，不是运行时换肤
- 仅解析 MySQL 风格 `CREATE TABLE`；**视图、存储过程不处理**；外键约束不生成代码（DDL 里写了也不影响生成）
- 生成的登录是**明文比对**，仅演示用途
- 题目重复的 Ajax 校验尚未内置（依赖数据库唯一键报错）
- 前端均为单表操作界面，复杂查询需自己在 Mapper XML 里写

---

## 常见问题

| 现象 | 原因 / 处理 |
|---|---|
| 解析后表是空的 | SQL 里没有 `CREATE TABLE`，或文件不是 UTF-8。用记事本另存为 UTF-8 再试 |
| `mvn` 报找不到依赖 | 第一次需联网下载；之后可 `mvn -o` 离线构建 |
| 页面打开 404 | 没勾「前端页面」；确认 `src/main/resources/static/` 下有文件 |
| 上传接口 404 | 表里必须有名字带 `path` 的列，且勾了「文件上传」 |
| 时间显示成 `2026-11-12T09:37:00` | 实体已加 `@JsonFormat`，自己改字段时记得保留注解 |
| 数据库连不上 | 「② 功能与配置」里的库名/账号密码要和你本机一致 |
| 前端起不来 | `frontend-vue` 需要先 `npm install`；离线环境直接用 `frontend-static` |
| 双击后没有任何窗口 | 检查是否被杀软拦截；程序是 x64，32 位系统无法运行 |

---

## 第三方资源与许可

本项目代码以 [MIT License](LICENSE) 发布。

生成物与安装包内置以下第三方资源，版权归各自作者所有，均以 MIT 协议分发：

| 资源 | 版本 | 许可 |
|---|---|---|
| Vue | 3.x（`vue.global.prod.js`） | MIT |
| jQuery | 1.12.4（`jquery.min.js`） | MIT |
| Spring Boot | 3.3.4（生成物依赖） | Apache-2.0 |
| MyBatis Spring Boot Starter | 3.0.3（生成物依赖） | Apache-2.0 |

---

## 免责与定位

这是一个**面向课程设计、内部工具原型、教学演示**的代码脚手架生成器。生成的代码是起点不是终点，投入生产前请自行补充参数校验、权限控制、异常处理与测试。
