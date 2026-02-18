# Godot Roguelite Shooter 构建日志

> 构建日期: 2026-02-18
> 引擎版本: Godot v4.6.1.stable (win64)
> 导出模板: 4.6.1.stable (Windows x86_64)
> 项目路径: D:\MCP\mcp_test\outputs\godot_game_pro\

---

## 项目概览

**类型**: 俯视角 2D Roguelite 射击游戏 (Top-down Roguelite Shooter)
**语言**: GDScript
**渲染器**: GL Compatibility (OpenGL)
**分辨率**: 1280×720 canvas_items 拉伸

## 文件清单

### 脚本 (14 个 .gd)
| 文件 | 功能 |
|------|------|
| scripts/autoload/game_manager.gd | 全局单例: 游戏状态、玩家属性、分数、输入映射、存档 |
| scripts/player.gd | 玩家: WASD 移动、鼠标瞄准、左键射击、无敌帧 |
| scripts/bullet.gd | 玩家子弹: 直线飞行、碰敌伤害、自动销毁 |
| scripts/enemy_bullet.gd | 敌方子弹: 直线飞行、碰玩家伤害 |
| scripts/base_enemy.gd | 敌人基类 (class_name BaseEnemy): HP、移动、接触伤害、掉落 |
| scripts/melee_enemy.gd | 近战型: 直线追逐玩家 (红色圆形) |
| scripts/ranged_enemy.gd | 远程型: 保持距离 + 射击 (橙色六边形) |
| scripts/dash_enemy.gd | 冲锋型: 蓄力→冲刺→冷却 (紫色菱形) |
| scripts/health_pickup.gd | 生命恢复拾取物 (绿色十字, 15s 超时) |
| scripts/xp_pickup.gd | 经验值拾取物 (蓝色光球, 玩家靠近吸附) |
| scripts/main.gd | 主场景: 竞技场绘制、摄像机跟随、波次管理 |
| scripts/ui/hud.gd | HUD: 生命条、分数、波次、XP、等级、波次公告 |
| scripts/ui/pause_menu.gd | 暂停菜单: ESC 触发, 继续/重开/退出 |
| scripts/ui/game_over.gd | 游戏结束: 分数显示、最高分、新纪录提示 |
| scripts/ui/upgrade_menu.gd | 升级菜单: 6 种升级随机三选一 |

### 场景 (9 个 .tscn)
| 文件 | 节点类型 | 碰撞层 |
|------|----------|--------|
| scenes/main.tscn | Node2D (引用全部子场景+UI) | — |
| scenes/player.tscn | CharacterBody2D | Layer 1 (Player) |
| scenes/bullet.tscn | Area2D | Layer 2, Mask 4 |
| scenes/enemy_bullet.tscn | Area2D | Layer 8, Mask 1 |
| scenes/melee_enemy.tscn | CharacterBody2D | Layer 4 |
| scenes/ranged_enemy.tscn | CharacterBody2D | Layer 4 |
| scenes/dash_enemy.tscn | CharacterBody2D | Layer 4 |
| scenes/health_pickup.tscn | Area2D | Layer 16, Mask 1 |
| scenes/xp_pickup.tscn | Area2D | Layer 16, Mask 1 |

### 配置 (2 个)
- project.godot — 项目配置、Autoload、物理层命名
- export_presets.cfg — Windows Desktop 导出预设

## 核心机制

1. **操控**: WASD/方向键 移动 + 鼠标瞄准 + 左键射击
2. **3类敌人**: 近战追逐 / 远程射击 / 蓄力冲刺
3. **波次系统**: 每轮敌人数=3+wave×2, 波次>3后HP和移速递增
4. **升级系统**: 经验达标升级, 弹出3选1 (伤害/射速/生命/移速/弹速/弹丸大小)
5. **掉落系统**: 击杀必掉XP(蓝球, 自动吸附), 30%掉HP(绿十字)
6. **暂停菜单**: ESC 触发, 全屏半透明遮罩
7. **游戏结束**: 显示分数+最高纪录, 可重开/退出
8. **本地存档**: ConfigFile 保存最高分到 user://highscore.cfg

## 碰撞层设计

| 层 | Bit | 用途 |
|----|-----|------|
| 1 | 1 | Player |
| 2 | 2 | PlayerBullet |
| 3 | 4 | Enemy |
| 4 | 8 | EnemyBullet |
| 5 | 16 | Pickup |

## 构建过程

1. 全部 26 个游戏源文件通过 AI 从零编写
2. 首次导出发现 Godot 4.6 类型推断更严格:
   - `xp_pickup.gd:30`: `:=` 无法推断 `dir` 类型 (源自 `get_nodes_in_group` 返回 `Array[Node]`)
   - `player.gd:52`: `:=` 无法推断 `gun_pos` 类型 (源自 `$GunPoint` 返回 `Node`)
3. 修复: 将问题行的 `:=` 改为 `=` (显式动态类型)
4. 第二次导出: 0 错误, 全部脚本编译通过

## 导出结果

- **文件**: `build/RogueliteShooter.exe`
- **大小**: ~99.6 MB (embed_pck=true)
- **导出命令**:
  ```
  Godot_v4.6.1-stable_win64_console.exe --headless --path <project> --export-release "Windows Desktop" build/RogueliteShooter.exe
  ```
- **状态**: ✅ 成功 (exit code 0, 0 errors)
