# 更新日志

本项目所有值得注意的变更都记在这里。版本号跟随安装包文件名旁的数字。

---

## v1.4 · 2026-11-12

「齿轮收口 + 取色器 + 画布缩放 + 登录页」，并用一份真实机试题做了端到端验收。

### 界面

- 删掉了「页面 / 分页 / 上传」那一整块重复的输入框，全部收进齿轮
- 只剩「外观」一小块：页面标题 + 主题色
- 主题色改成 **系统取色器**（「取色…」按钮）+ 右侧 7 个常用色块，点一下就换
- 齿轮从 3 个扩到 5 个：⚙ 分页、⚙ 上传、⚙ 前端/端口、⚙ 联表查询、⚙ 登录

### 修复

- **「前端/端口」齿轮点了没反应**：根因是 `state` 里没初始化 `separate`，弹窗一构造就抛 `KeyError`，在没有控制台的 exe 里表现成"点了没反应"。两处补默认值，并给所有齿轮点击套上 `try/except` + 错误弹窗
- 新增自测入口 `sql2java.exe 某.sql --selftest`，逐个打开齿轮并把结果写进 `_selftest.log`
  ```
  修复前： 分页 OK / 上传 OK / 前端端口 FAIL KeyError('separate') / 联表 OK / 登录 OK
  修复后： 分页 OK / 上传 OK / 前端端口 OK / 联表 OK / 登录 OK
  ```

### 画布

- 选中控件后四角出现蓝色角柄
- **拖角柄改宽高**（nw / ne / sw / se 四边都可），拖中间仍是移动
- 状态栏实时显示：`改大小：button → 120×40 @ (435,353)`

### 新增登录页

- 后端 `LoginController`：`POST /api/login {"username","password"}` → 命中返回用户信息 + `__ok:true`
- 三套前端各多一个 `js/login.js`：登录遮罩（账号 / 密码 / 登录 / 重置），未登录进不去，登录后 localStorage 记住，右上角显示「欢迎，xxx　退出」
- Vue(Vite) 版在 `src/login.js`，`main.js` 自动引入

### 验收（真实机试题 docx）

按 docx 建库（`t_user` / `t_code` / `t_paper` + 测试数据）后一条命令生成，13 项自动验收全过：

```
登录遮罩出现 / 标题=论文管理系统 / 空账号提示「请输入账号」/ 错密码提示「账号或密码错误」/
登录后遮罩消失 / 右上角「欢迎，管理员 退出」/ 论文列表 3 行 /
联表菜单在 / 联表显示中文类型「毕业论文」/ 新增表单打开 / 无 JS 异常 /
jQuery 版也有登录遮罩 / jQuery 登录成功进列表
→ 通过 13 项，失败 0 项
```

后端接口同样验证：

```
GET  /api/paper/page?pageNum=1&pageSize=5  → 200  total=2 pageSize=5
POST /api/login {"username":"admin","password":"123456"}
     → {"__ok":true,"user_name":"管理员","user_code":"admin","id":1}
GET  /api/paper/join/page                  → 200  带 codeText 中文类型
```

### 尚未完成

- 题目重复的 Ajax 校验（docx 里明确要「论文题目已经存在」）

---

## v1.3 · 2026-11-11

「齿轮设置 + 三套独立前端 + 联表查询」。

### 高级设置收进齿轮

| 齿轮 | 可调项 | 落到哪 |
|---|---|---|
| ⚙ 分页 | 默认条数、可选条数、显示总条数 / 条数下拉 / 首页末页 | `defaultValue` + `SHOW_TOTAL` / `SHOW_SIZE_SELECT` / `SHOW_FIRST_LAST` |
| ⚙ 上传 | 最大 MB、允许扩展名、上传目录 | yaml multipart + `MAX_UPLOAD_SIZE` / `ALLOWED_EXT` |
| ⚙ 前端/端口 | Vue / jQuery / HTML / 静态版端口、是否前后端分离 | `vite.config.js` 的 `server.port`、各前端 `start.bat`、目录结构 |
| ⚙ 联表查询 | 主表 + 关联列 + 从表 + 关联列 + 显示列，可加多条 | JoinMapper / XML / Service / Controller |

齿轮开关实测生效：

```
--show-first-last 0 →
浏览器里 首页隐藏: true | 末页隐藏: true | 上一页可见: true | 行数: 3  → PASS
```

### 三种前端各自是独立项目

```
out/demo/
├─ backend/            IDEA 打开（pom.xml）
├─ frontend-vue/       IDEA 打开（Vue3 + Vite，端口写死 + /api 代理）
├─ frontend-static/    Vue 离线版 + start.bat
├─ frontend-jquery/    jQuery 1.12.4 + 本地 jquery.min.js + start.bat
└─ frontend-html/      原生 JS + start.bat
```

每个前端目录都有 `README.md`（写端口和启动方式）和 `start.bat`（双击就开）。

### 联表查询（表间外键 → 中文名）

生成 `PaperJoinMapper` / `PaperJoinMapper.xml` / `PaperJoinService` / `PaperJoinController`，实体多一个 `codeText` 字段：

```
LEFT JOIN t_code r ON r.id = p.type
GET /api/paper/join/page?pageNum=1&pageSize=5
→ 200 {"total":2,"rows":[{...,"type":2,"codeText":"课程论文"}, ...]}
```

### 修掉的逻辑错误

| 问题 | 现象 | 修法 |
|---|---|---|
| 表名撞类名 | `t_user` / `user` / `sys_user` 都变 `User`，表被覆盖 | 两轮去重：`user→User`、`t_user→TUser`、`sys_user→SysUser` |
| 控制器路径重复 | 变成 `/api/paper/api/paper/page` → 404 | 方法上只写 `/page`，前缀交给类级 `@RequestMapping` |
| 联表条数写死 | Service 里 `pageSize` 硬编码 10 | 改成从配置传参 |
| yaml 占位符没展开 | 生成出 `max-file-size: %(max_mb)dMB` | multipart 段先格式化再拼 |
| jQuery 保存按钮失效 | 绑定在 `$(function(){})` 外面，DOM 顺序一变就失效 | 全部移进 ready |
| 原生 HTML 版只能删 | 没有增改 | 补新增/修改表单 |
| 首页/末页关不掉 | 齿轮开关没用 | `SHOW_FIRST_LAST` 贯穿三套前端 |
| 联表 count 与 list 不一致 | 分页算出空页 | 两处共用同一段 `<sql id="Where">` |

### 尚未完成

- 一对多 / 多对多联表（目前只做多对一）
- 联表结果的增删改（联表页只读）
- 主题色运行时换肤

---

## v1.2 · 2026-11-10

「一切在工具里配，前端单独成项目」。

### 新增配置项

| 配置 | 作用 | 写到哪里 |
|---|---|---|
| 页面标题 | 顶部栏文字 | 前端 html 的 `<title>` / `.logo` |
| 主题色 | 按钮、表头、选中菜单、统计数字 | CSS 变量 `--primary`（多套前端共用） |
| 每页默认条数 | 打开就是 N 条/页 | 后端 `@RequestParam(defaultValue="N")` + 前端初始值 |
| 可选条数 | 下拉里的 5/10/20/50 | 前端 `PAGE_SIZES` |
| 上传上限(MB) | 超了报「上传文件格式不正确」 | yaml multipart + Controller 的 `MAX_UPLOAD_SIZE` |
| 允许扩展名 | 白名单，逗号分隔 | Controller 的 `ALLOWED_EXT` |
| 前端形态 | all / vue / jquery / html | 决定生成哪几套前端 |

这一块的意义：**学生不用改任何代码**。想 20 条一页、想 25MB、想橙色主题，全在界面上点。

### 前后端分成两个 IDEA 项目

```
out/<artifact>/
├─ backend/            ← 打开这个（pom.xml 在这一层）
├─ frontend-vue/       ← 或打开这个（Vue3 + Vite 真项目）
├─ frontend-static/    零 npm 的 Vue 预览
├─ frontend-jquery/    jQuery 1.12.4（零 npm）
├─ frontend-html/      原生 HTML + JS（零框架）
└─ *.zip
```

前端 `npm run dev` 起 5173，`/api` 自动代理到后端 8080。

### 三套前端都验过

| 版本 | 依赖 | 实测 |
|---|---|---|
| Vue 离线版 | 本地 `vue.global.prod.js` | 3 张统计卡片、表格 4 行、分页信息、无 JS 异常 |
| jQuery 版 | 本地 `jquery.min.js` 1.12.4 | 主题色 `rgb(47,111,237)`、表格 4 行、隔行变色、分页、新增表单弹出、无异常 |
| 原生 HTML 版 | 无 | 主题色、表格 4 行、分页按钮、无异常 |

```
node tests/frontends_ui_check.mjs
→ 通过 16 项，失败 0 项
```

### 样式细节

三套前端共用同一份按主题色生成的 CSS：顶栏主题色渐变 + 阴影、左侧菜单圆角块选中填充、统计卡片白底 + 1px 边框 + 圆角 10px + 轻阴影、表格表头浅蓝底 + 隔行变色 + hover 高亮、操作列分色（修改蓝 / 删除红）、按钮默认白底描边主按钮主题色填充、表单标签右对齐 + 聚焦描边变主题色、底部灰色小字说明。

---

## v1.1 · 2026-11-09

### 生成后自动用 IDEA 打开

「③ 生成」页勾上（默认勾着），生成完立刻执行 `idea64.exe <生成的项目目录>`。IDEA 路径按顺序找：

```
1) 环境变量 IDEA_HOME / IDEA_PATH
2) D:\tool\IntelliJ IDEA*\bin\idea64.exe
3) C:\Program Files\JetBrains\IntelliJ IDEA*\bin\idea64.exe
4) %LOCALAPPDATA%\Programs\IntelliJ IDEA*\bin\idea64.exe
5) %LOCALAPPDATA%\JetBrains\Toolbox\apps\IDEA\*\*\bin\idea64.exe
```

找不到就退回「用资源管理器打开目录」，不会报错卡住。CLI 也支持：`--open-idea 1`。

### 画布布局

「④ 可视化布局」页，900×520 画布，20px 网格，左上角是原点 `(0,0)`。

| 操作 | 效果 |
|---|---|
| 顶部 `+ 标签 / + 输入框 / + 下拉 / + 按钮 / + 表格` | 在画布左上角加控件 |
| 右键空白处 | 在这里添加控件 / 示例布局 / 清空 |
| 右键控件 | 属性…（文字、绑定字段、X/Y/宽/高）/ 删除 |
| 左键拖动 | 改坐标，状态栏实时显示 |

生成三个文件：`designer.html`（绝对定位页面）、`designer.js`（Vue 逻辑）、`layout.json`（布局存档，可再导入）。

坐标到前端就是一行 style：

```html
<input style="position:absolute;left:150px;top:18px;width:260px;height:28px;"
       placeholder="请输入标题" v-model="form.title">
```

为什么用绝对定位而不是拖拽组件库：所见即所得，坐标改了就真跟着动；不引任何前端框架/打包器，纯 HTML + Vue，拷走就能用；考试/作业场景里"摆在哪"比"响应式布局"重要得多。

---

## v1.0 · 2026-11-08

首个可用版本。

- tkinter 原生窗口（不嵌网页），四页签：① 表结构 ② 功能与配置 ③ 生成 ④ 可视化布局
- SQL 解析：`CREATE TABLE` → 表名、字段、类型、主键、自增、必填、注释；索引/外键/INSERT 跳过
- 类型映射：`BIGINT→Long`、`INT/TINYINT→Integer`、`DECIMAL→BigDecimal`、`DATETIME/TIMESTAMP→LocalDateTime`、`VARCHAR/TEXT→String`、`BLOB→byte[]`
- 生成 Spring Boot 3.3.4 + MyBatis（XML）后端，每表 Entity / Mapper / Service / Controller
- 每张表六个接口：`/page` `/get` `/save` `/update` `/delete` `/saveWithFile`
- 功能开关：Lombok、分页、文件上传、报表、前端页面
- 生成 Vue 3 单页 + 建库脚本 + README + ZIP
- 支持命令行：`sql2java.exe --cli 输入.sql 输出目录 --artifact ...`

实测（`paper.sql` 三张表）：

```
解析：3 张表（t_code 2 字段 / t_user 4 字段 / t_paper 9 字段）
生成：23 个文件 + ZIP
mvn -o -DskipTests package  → 成功，jar 26 MB
java -jar 启动              → http://localhost:8082/  HTTP 200
/api/paper/page?pageNum=1&pageSize=5  → total=2 page=1/1
/api/report/counts                    → {'t_code':5,'t_user':1,'t_paper':2}
界面（无头 Edge 真点）7 项全过
```

---

## 版本对照

| 版本 | 主题 | 关键能力 |
|---|---|---|
| v1.0 | 能生成 | SQL 解析 + Spring Boot + Vue 单页 + CLI |
| v1.1 | 省事 | 自动开 IDEA、画布布局 |
| v1.2 | 可配置 | 标题/主题色/分页/上传配置、前后端分离、三套前端 |
| v1.3 | 成体系 | 齿轮配置、独立前端项目、联表查询、8 个 bug 修复 |
| v1.4 | 打磨 | 齿轮收口、取色器、画布缩放、登录页、机试题验收 |
