CMD_ATLAS = "atlas" 
CMD_ATLAS_ENTER = "atlas.enter"---进入副本
CMD_ATLAS_FIGHT= "atlas.fight"---客户端提交战斗结果
CMD_ATLAS_GETINFO = "atlas.getinfo"  ----获取副本界面信息
CMD_ATLAS_BUYBATNUM = "atlas.buybatnum"  ----购买战斗次数
CMD_ATLAS_CRYSTALREWARDINFO = "atlas.cryrewinfo"  ----章节奖励领取信息
CMD_ATLAS_RECCRYSTALREWARD = "atlas.reccryrew"  ----领取章节奖励
CMD_ATLAS_SWEEP = "atlas.sweep"  ---副本扫荡
--

CMD_ATLAS_PET_ENTER = "atlas.petenter"---进入副本
CMD_ATLAS_PETT_FIGHT= "atlas.petfight"---客户端提交战斗结果
CMD_ATLAS_PET_GET_REWARD = "atlas.petgetrew"---领取宠物副本扫荡奖励
CMD_ATLAS_PET_GETINFO = "atlas.petgetinfo"---获取宠物副本界面信息
CMD_ATLAS_PET_SWEEP = "atlas.petsweep"---宠物副本扫荡
CMD_PET_UNLOCK="pet.unlock"


CMD_ATLAS_ACTION = "atlas.action"---行动
CMD_ATLAS_EVENT = "atlas.event"---完成剧情事件
CMD_ATLAS_REVIVE = "atlas.revive"---复活
CMD_ATLAS_EXIT = "atlas.exit"---离开副本
CMD_ATLAS_GAME1 = "atlas.game1"---猜拳游戏
CMD_ATLAS_GAME2 = "atlas.game2"---猜大小游戏
CMD_ATLAS_GAME3 = "atlas.game3"---刮刮卡游戏
CMD_ATLAS_GAME4 = "atlas.game4"---拼图游戏
CMD_ATLAS_GAME51 = "atlas.game51"---遇到强盗—给钱了事
CMD_ATLAS_GAME52 = "atlas.game52"---遇到强盗—与之搏命
CMD_ATLAS_GAME61 = "atlas.game61"---遇到盗贼—息事宁人
CMD_ATLAS_GAME62 = "atlas.game62"---遇到盗贼—追赶盗贼
CMD_ATLAS_CHANGENAME = "atlas.name"---命名
    
CMD_TEST = "test"
CMD_TEST_BATTLE = "test.bat"
CMD_TEST_GETBATTLEVEDIO = "test.getbatvedio"
CMD_TEST_CHECKCARD = "test.checkcard"
    
   ---服务端主动下发的命令
RECEIVE = "rec"
RECEIVE_BUDDY_INVITE = "rec.budinvite"

RECEIVE_IAP_MISSORDER = "rec.iapmo"---收到漏单
    
RECEIVE_UPDATESHARD = "rec.updateshard"---推送碎片信息给被掠夺的玩家（服务端主动返回）
    
RECEIVE_LOOT_MESSAGE = "rec.lootm" ---掠夺的消息(服务端主动推送）
    
RECEIVE_ARENA_MESSAGE = "rec.arenam"---竞技场消息(服务端主动推送)
RECEIVE_CHECK_UPDATE = "rec.chkupd"---检查版本更新 
    
RECEIVE_ACHIEVE_FINISH_NOTICE = "rec.afno" ---通知有成就完成
RECEIVE_PROMPT = "rec.prompt" ---红点提示（服务端主动下发）

RECEIVE_REWARD = "rec.reward" -- 推送奖励信息

RECEIVE_WORLD_BOSS_END = "wboss.endn" --世界boss结束

   ---系统
CMD_SYSTEM = "sys"
CMD_SYSTEM_HANDSHAKE = "sys.hs"
CMD_SYSTEM_INIT = "sys.init"---初始化所有数据
CMD_SYSTEM_RELOAD = "sys.reload"---刷新数据
---  CMD_SYSTEM_MAINTAIN = "sys.maintain"---系统维护
CMD_SYSTEM_PLAYER_INFO = "sys.pinfo" ---查看玩家(已上阵)
CMD_SYSTEM_RETIME = "sys.retime" ---恢复体力或是元气的时间
CMD_SYSTEM_CHANGE_NAME = "sys.changename"
CMD_SYSTEM_SYSROLLNOTICE = "sys.sysroll"
    
    
   ---市集
CMD_MARKET = "mkt"
CMD_MARKET_RECURIT = "mkt.recurit"---招募抽卡
CMD_MARKET_GET_SOUL = "mkt.getsoul"---抽取魂魄
CMD_MARKET_BUY_ITEM = "mkt.buyitem"---购买道具
    
   ---队伍操作相关
CMD_TEAM = "team"
CMD_TEAM_CHANGE_CARD = "team.chcard"---换人
CMD_TEAM_EXCHANGE_CARD = "team.exchcard"---交换位置
CMD_TEAM_CHANGE_FORMATION = "team.chfm"---换阵型
CMD_TEAM_RESET_ASSISTANT = "team.rstass"---小伙伴逆转
CMD_TEAM_SAVE = "team.save" --保存阵容
   ---卡牌操作相关
CMD_CARD = "card"
CMD_CARD_UPGRADE = "card.upgrade"---升级
CMD_CARD_RECURIT = "card.recurit"---招募
CMD_CARD_EQUIP = "card.equip"---穿上或者卸下装备
CMD_CARD_SKILL = "card.skill"---装备或者卸载技能
CMD_CARD_MERIDIAN_UPGRADE = "card.mdup"---经脉升级
CMD_CARD_MERIDIAN_RESET = "card.mdrs"---经脉重置
CMD_CARD_TRANSMIT = "card.transmit"---传功
CMD_CARD_EVOLVE = "card.evolve" ---进阶
CMD_CARD_RAISE_INFO = "card.rinfo"---卡牌培养详细
CMD_CARD_RAISE= "card.raise" ---卡牌培养
CMD_CARD_RAISE_CONFIRM = "card.rcon" ---卡牌培养确认
CMD_CARD_EXP_UPGRADE = "card.expug"  ---卡牌升级经验
CMD_CARD_AWAKEN = "card.awaken" ---卡牌觉醒
CMD_CARD_FIGHTSOUL = "card.fsoul" ---卡牌战魂
CMD_CARD_ACTIVATE_RELATION = "card.atrl" ---卡牌战魂
CMD_CARD_RAISE_INFO = "card.rinfo"
CMD_CARD_RAISE= "card.raise"    
CMD_CARD_RAISE_CONFIRM = "card.rcon"                        
CMD_CARD_WEAPON_UPGRADE = "card.wpup"   
CMD_CARD_TRANSMIT = "card.transmit"                                         


                    
   ---装备操作相关
CMD_EQU = "equ"
CMD_EQU_UPGRADE = "equ.upgrade"---升级
CMD_EQU_ACTIVATE = "equ.activate"---激活
CMD_EQU_ACTIVATE_ONEKEY = "equ.actok"---一键激活
CMD_EQU_UPQUALITY = "equ.upquality"---升品
CMD_EQU_QUICKUPGRADE = "equ.qkugd"---快速升级
CMD_EQU_RECAST = "equ.recast"---重铸
CMD_EQU_SELL = "equ.sell"---出售
CMD_EQU_MERGE = "equ.merge"---拼合
CMD_EQU_MELT="equ.metl"
   ---技能操作相关
CMD_SKILL = "skill"
CMD_SKILL_UPGRADE = "skill.upgrade"---升级
CMD_SKILL_UPGRADE_DEFAULT = "skill.ugddef"---升级天赋技能
CMD_SKILL_QUICK_UPGRADE = "skill.quickup" --快速升级

   ---技能操作相关
CMD_FORMATION = "fm"
CMD_FORMATION_UPGRADE = "fm.upgrade"---升级
   ---道具操作相关
CMD_ITEM = "item"
CMD_ITEM_USE = "item.use"
CMD_ITEM_USE_KEY = "item.usekey"---使用金银铜钥匙
CMD_ITEM_OPEN_BOX = "item.openbox"---开宝箱
CMD_ITEM_USE_KEY_NUM = "item.ukn"---批量使用金银铜钥匙
CMD_ITEM_OPEN_BOX_NUM = "item.obn"---批量开宝箱
CMD_ITEM_DIAMOND_BUY_HP = "item.dhp" ---钻石购买体力 
CMD_ITEM_DIAMOND_BUY_SKILLPOINT = "item.dskpt"--钻石购买体力
CMD_ITEM_SELL = "item.sell" ---出售道具
CMD_ITEM_DIAMOND_BUY_EVIL = "item.devil" ---出售道具
   --- 闯关
CMD_RUSH = "rush"
CMD_RUSH_GETINFO = "rush.getinfo"---获取闯关信息
CMD_RUSH_ENTER = "rush.enter"---进入闯关界面
CMD_RUSH_FIGHT = "rush.fight"---闯关战斗
CMD_RUSH_ADD = "rush.add"---属性加成
CMD_RUSH_RANK = "rush.rank"---闯关排行
    
   --- 活动——每日体力
CMD_DAYENG = "de"
CMD_DAYENG_INIT = "de.init"--- 初始化界面信息
CMD_DAYENG_ADD = "de.add"--- 获得体力
    
   --- 活动——保护貂蝉
CMD_PROTECT = "prot"
CMD_PROTECT_INIT = "prot.init"--- 初始化界面信息
CMD_PROTECT_PROTECT = "prot.protect"--- 保护
CMD_PROTECT_DRIVE = "prot.drive"--- 驱赶
CMD_PROTECT_REWARD = "prot.reward"--- 领取奖励
    
   --- 掠夺
CMD_LOOT = "loot"
CMD_LOOT_UPDATETIME = "loot.updatetime"--- 更新拼合剩余时间
CMD_LOOT_GETOPP = "loot.getopp"--- 获取对手列表
CMD_LOOT_FIGHT = "loot.fight"---掠夺战斗
CMD_LOOT_MAKE = "loot.make"---拼合残片
CMD_LOOT_MESSAGE_LIST = "loot.mlist" ---掠夺的消息集合
CMD_LOOT_VEDIO = "loot.vedio" ---录像回放
    
   --- 礼包
CMD_GIFTBAG = "giftb"
CMD_GIFTBAG_INIT = "giftb.init2"---礼包界面初始化
CMD_GIFTBAG_BUY = "giftb.buy"  ---购买礼包
CMD_GIFTBAG_OPEN_SERVER_INIT = "giftb.osi"---开服礼包界面初始化
CMD_GIFTBAG_GET_OPEN_SERVER = "giftb.getos"---领取开服礼包
CMD_GIFTBAG_LV_INIT = "giftb.lvi"---等级礼包界面初始化
CMD_GIFTBAG_GET_LV = "giftb.getlv"---领取等级礼包
CMD_GIFTBAG_BET = "giftb.bet"--立地成壕下注
    
   --- 关系(好友,仇敌)
CMD_RELATION = "relat"
CMD_RELATION_BUDDYLIST = "relat.buddylist"---我的好友列表
CMD_RELATION_BUDDYADDLIST = "relat.buddyaddlist" ---可以添加好友列表
CMD_RELATION_BUDDYADD = "relat.buddyadd" ---结交好友
CMD_RELATION_BUDDYSEARCH = "relat.buddysearch"---搜索
CMD_RELATION_BUDDYMESSAGELIST = "relat.buddymessagelist" ---好友的留言列表
CMD_RELATION_BUDDYMESSAGESEND = "relat.buddymessagesend" ---发送留言给我的好友
CMD_RELATION_BUDDYINFO = "relat.buddyinfo"---查看好友详细
CMD_RELATION_BUDDYFIGHT = "relat.buddyfight"---切磋
CMD_RELATION_BUDDYDELE = "relat.buddydele" ---删除好友
    
   --- 图鉴
CMD_ILLUSTRATION = "illus"
CMD_ILLUSTRATION_LIST = "illus.list" ---我的图鉴列表
    
   --- 成就
CMD_ACHIEVE = "achi"
CMD_ACHIEVE_LIST = "achi.list" ---我的成就列表
CMD_ACHIEVE_GET = "achi.get" ---领取我的已达成的成就

   --- 每日任务
CMD_DAYTASK = "dayt"  
CMD_DAYTASK_LIST = "dayt.list"---我的每日任务列表
CMD_DAYTASK_GET = "dayt.get"  ---领取我的每日任务奖励
    
   ---iap
CMD_IAP = "iap"
CMD_IAP_BUY = "iap.buy"---获取商品ID和订单号
CMD_IAP_CHECKRECEIPT = "iap.chkrcp"---验证appstore商品订单
CMD_IAP_CANCEL = "iap.cancel"---取消购买
CMD_IAP_CHECKMISSORDER = "iap.chkmo"---检查漏单
CMD_IAP_CHECKORDER = "iap.chkorder"---检查订单是否到达
    
   --- 招贤
CMD_TURNT = "turnt"
CMD_TURNT_LIST = "turnt.list"---招贤列表
CMD_TURNT_REFRESH = "turnt.refresh"---元宝刷新
CMD_TURNT_EMP = "turnt.emp" ---招贤
    
   --- 当铺
CMD_PAWN = "pawn"
CMD_PAWN_INFO = "pawn.info" ---当铺信息
CMD_PAWN_COM = "pawn.com"   ---开始组合
    
   --- 竞技场
CMD_ARENA = "arena" 
CMD_ARENA_INFO = "arena.info"    ----我的竞技场信息
CMD_ARENA_REFRESH = "arena.refresh"    ----刷新
CMD_ARENA_CHALLENGE = "arena.challenge"    ----挑战
CMD_ARENA_RECORD = "arena.record"    ----我的对战记录
CMD_ARENA_RANKHEGELIST = "arena.rankhegelist"    ----排名争霸
CMD_ARENA_LVHEGELIST = "arena.lvhegelist"    ----等级争霸
CMD_ARENA_GETRANKRE = "arena.getrankre"    ----领取排名争霸奖励
CMD_ARENA_GETLVRE = "arena.getlvre"      ----领取等级争霸奖励
CMD_ARENA_GETDAYRE = "arena.getdayre"    ----领取每日奖励
CMD_ARENA_RANK = "arena.rank"    ----排行榜
CMD_ARENA_CHECKRE = "arena.checkre"    ----查看战报
CMD_ARENA_RANKPAGE = "arena.rankpage"    ----跳转排行页
CMD_ARENA_MESSAGE_LIST = "arena.mlist"   ----竞技场消息列表
CMD_ARENA_VEDIO = "arena.vedio"    ----战斗回放
CMD_ARENA_CARD_INFO = "arena.cardinfo"   ----卡牌详细
CMD_ARENA_CLEAR_CD = "arena.clearcd"  ----清除CD
CMD_ARENA_BUY_NUM = "arena.buynum"-----购买次数
--
 
---签到
CMD_SIG = "sig"
CMD_SIG_INIT = "sig.init"---初始化签到界面信息
CMD_SIG_SIGN = "sig.sign"---签到
CMD_SIG_VIP = "sig.vip"---领取VIP奖励

---奇遇
CMD_ACT = "act"
CMD_ACT_GET_LIST = "act.getlist"
-- CMD_ACT_EXPENSE_RETURN = "act.getinfo2"---消费返利
-- CMD_ACT_EXPENSE_RETURN_GET = "act.rec2"---消费返利 领取
-- CMD_ACT_CHAEGE_RETURN = "act.getinfo3"---充值返利
-- CMD_ACT_CHAEGE_RETURN_GET = "act.rec3"---充值返利 领取
CMD_ACT_WEEKLY_RETURN = "act.getinfo4"---每周福利
CMD_ACT_WEEKLY_RETURN_GET = "act.rec4"---每周福利 领取
CMD_ACT_WEEKLY_RANK = "act.weekrank"---每周福利 周富豪榜
CMD_ACT_CHARGE_GIFT = "act.getrinfo"---充值优惠信息
CMD_ACT_GET_INFO_1 = "act.getinfo1"---获取限时兑换活动界面信息
CMD_ACT_GET_INFO_2 = "act.getinfo2"---获取限时消返活动界面信息
CMD_ACT_GET_INFO_3 = "act.getinfo3"---获取累计充返活动界面信息
CMD_ACT_GET_INFO_5 = "act.getinfo5"---获取仙人指路界面信息
CMD_ACT_GET_INFO_6 = "act.getinfo6"---充值返利
CMD_ACT_GET_INFO_7 = "act.getinfo7"---折扣商店
CMD_ACT_GET_INFO_9 = "act.getinfo9"---纯文本公告
CMD_ACT_GET_INFO_10 = "act.getinfo10"---获取排行活动界面信息
CMD_ACT_GET_INFO_28 = "act.getinfo28"---获取节日签到界面信息
CMD_ACT_BUY_5 = "act.buy5"---购买仙人指路物品
CMD_ACT_REC_5 = "act.rec5"---领取仙人指路奖励
CMD_ACT_REC_1 = "act.rec1"---获取限时兑换活动界面信息
CMD_ACT_REC_2 = "act.rec2"---获取限时消返活动界面信息
CMD_ACT_REC_3 = "act.rec3"---获取累计充返活动界面信息
CMD_ACT_REC_6 = "act.rec6"---充值返利
CMD_ACT_REC_7 = "act.rec7"---折扣商店
CMD_ACT_REC_9 = "act.rec9"---纯文本公告
CMD_ACT_REC_10 = "act.rec10"---获取排行活动界面信息   
CMD_ACT_REC_28 = "act.rec28"---节日签到 
CMD_ACT_WEEK_GIFT_INFO = "act.weekgiftinfo"--获取每周礼包界面信息
CMD_ACT_BUY_WEEK_GIFT = "act.buyweekgift"--购买每周礼包
    
   --- 喵月卡
CMD_MCARD = "mcard"
CMD_MCARD_GETINFO = "mcard.getinfo"--- 获取喵月卡界面信息
CMD_MCARD_BUY = "mcard.buy"--- 购买月卡
CMD_MCARD_REC = "mcard.rec"--- 领取月卡奖励
    
   --- 新抽卡系统
CMD_DRAW = "draw" ---抽卡
CMD_DRAW_LIST = "draw.list" ---抽卡列表
CMD_DRAW_GD_BUY = "draw.gdbuy" ---金币(免费)抽卡/金币十连抽/钻石(免费)抽卡/钻石十连抽
CMD_DRAW_SOUL_BUY = "draw.sbuy" ---魂匣购买
CMD_DRAW_HIGHT_BUY = "draw.hbuy"---将魂抽卡
CMD_DRAW_DBEXCHANGE = "draw.dbexchange"---将魂抽卡
   
   --- 点石成金
CMD_TURNGOLD = "tg"
CMD_TURNGOLD_INIT = "tg.init"--- 初始化点石成金界面信息
CMD_TURNGOLD_USE = "tg.use"--- 使用点石成金（包含一次和批量使用）
    
   --- 邮件
CMD_MAIL = "mail"
CMD_MAIL_LIST = "mail.list" --- 邮件列表
CMD_MAIL_GET = "mail.get" --- 领取邮件附件
CMD_MAIL_DEL = "mail.del" --- 删除邮件
CMD_MAIL_READ = "mail.read" ---读邮件
    
   --- 养成基金
CMD_FUND = "fund"
CMD_FUND_LIST = "fund.list"  --- 列表
CMD_FUND_BUY = "fund.buy" ---购买
CMD_FUND_GET = "fund.get" --- 领取
    
   --- 醉点金枝
CMD_CLICK = "click"
CMD_CLICK_INIT = "click.init"--- 初始化界面信息
CMD_CLICK_GETINFO = "click.getinfo"--- 获取对应类别的物品列表
CMD_CLICK_DRAW = "click.draw"--- 翻牌
CMD_CLICK_REC = "click.rec"--- 领取积分奖励
    
 
   --- 神秘商店
CMD_SHOP = "shop"
CMD_SHOP_INIT = "shop.info" ---初始化神秘商店信息
CMD_SHOP_REFRESH = "shop.refresh"---刷新神秘商店
CMD_SHOP_EXCHANGE = "shop.ex"---兑换
CMD_SHOP_BUY = "shop.buy"---购买
    
   --- 先到先得
CMD_FIRST = "first"
CMD_FIRST_GETINFO = "first.getinfo"--- 获取界面信息
CMD_FIRST_REC = "first.rec"--- 领取奖励(服务端同时会广播给其他客户端）
    
     
   --- 副本
CMD_3D_ATLAS = "atlas_3d"   
CMD_3D_ATLAS_FIGHT = "atlas_3d.fight"---副本战斗
    
   --- 战魂
CMD_3D_FIGHTSOUL = "fsoul_3d"  
CMD_3D_FIGHTSOUL_GET = "fsoul_3d.get"---获取战魂
CMD_3D_FIGHTSOUL_PICK = "fsoul_3d.pick"---拾取战魂
CMD_3D_FIGHTSOUL_SELL = "fsoul_3d.sell"---卖出战魂
CMD_3D_FIGHTSOUL_UNITY = "fsoul_3d.unity"---合成战魂


CMD_CHAT_FAMILY ="chat.family"
CMD_CHAT_WORLD = "chat.world" 
CMD_CHAT_PRIVATE  = "chat.private"
CMD_RECEIVE_CHAT = "rec.chat"
CMD_CHAT_INIT = "chat.init"
CMD_FAMILY_CHAT_INIT = "family.initchat"
CMD_ATLAS_ACT_ENTER = "atlas.actenter"--进入副本
CMD_ATLAS_ACT_FIGHT= "atlas.actfight"--客户端提交战斗结果
CMD_ATLAS_ACT_DOUBLE_REWARD = "atlas.actdourew"--副本双倍奖励
CMD_ATLAS_ACT_GETINFO = "atlas.actgetinfo"--获取副本界面信息
CMD_ATLAS_ACT_CLEARCD = "atlas.actclearcd" --清除副本CD  
CMD_ATLAS_FLOP = "atlas.flop" --精英副本翻牌  
    

CMD_PET = "pet"
CMD_PET_UPGRADE = "pet.upgrade"-- 宠物升级
CMD_PET_EVOLVE = "pet.evolve"-- 宠物升星
CMD_PET_UPGRADE_SKILL="pet.upsk"
 
CMD_BUDDY_LIST = "buddy.list"
CMD_BUDDY_GIVE = "buddy.give"
CMD_BUDDY_MESSAGE = "buddy.message"
CMD_BUDDY_FIGHT = "buddy.fight"
CMD_BUDDY_DEL = "buddy.del"
CMD_BUDDY_BLACK = "buddy.black"
CMD_BUDDY_FIND = "buddy.find"
CMD_BUDDY_INVITE = "buddy.invite"
CMD_BUDDY_APPLYLIST = "buddy.applylist"
CMD_BUDDY_ACCEPT = "buddy.accept"
CMD_BUDDY_REFUSE = "buddy.refuse"
CMD_BUDDY_GIVELIST = "buddy.givelist"
CMD_BUDDY_RECEIVE = "buddy.receive"
CMD_BUDDY_RECEIVE_ALL = "buddy.recall"
CMD_BUDDY_BLACKLIST = "buddy.blacklist"
CMD_BUDDY_DEL_BLACK = "buddy.delblack"
CMD_BUDDY_TEAM = "buddy.team"
CMD_BUDDY_MAILLIST = "buddy.maillist"--好友邮件列表
CMD_BUDDY_READMAIL = "buddy.readmail"--阅读邮件
CMD_BUDDY_DELMSG = "buddy.delmsg"
CMD_RECEIVE_BUDDY_ACCEPT = "rec.budaccept" 
CMD_RECEIVE_BUDDY_DEL = "rec.buddel" 

--军团
CMD_FAMILY  = "family"
CMD_FAMILY_GETINFO = "family.getinfo"
CMD_FAMILY_SET_DECLARATION = "family.setdec"
CMD_FAMILY_MEMBER_LIST = "family.memlist"
CMD_FAMILY_DISMISS = "family.dismiss"
RECEIVE_FAMILY_DISMISS = "rec.fammiss"
CMD_FAMILY_CANCEL_DISMISS = "family.cancelmiss"
CMD_FAMILY_APPOINT = "family.appoint"
RECEIVE_FAMILY_APPOINT = "rec.famappoint"
CMD_FAMILY_EXPEL = "family.expel"
RECEIVE_FAMILY_EXPEL = "rec.famexpel"
CMD_FAMILY_APPLY_LIST = "family.applist"
CMD_FAMILY_PASS = "family.pass"
RECEIVE_FAMILY_PASS = "rec.fampass"
CMD_FAMILY_REFUSE = "family.refuse"
CMD_FAMILY_REFUSE_ALL = "family.refuseall"
CMD_FAMILY_DYNAMIC = "family.dynamic"
CMD_FAMILY_SEARCH = "family.search"
CMD_FAMILY_CREATE = "family.create"
CMD_FAMILY_APPLY = "family.apply"
CMD_FAMILY_CANCEL_APPLY = "family.cancelapp"
CMD_FAMILY_SET_NOTICE = "family.setnotice"
CMD_FAMILY_FIGHT = "family.fight"
CMD_FAMILY_EXIT = "family.exit"
CMD_FAMILY_SET_APPLY = "family.setapply"
CMD_FAMILY_ADD_WOOD = "family.addwood"

--命魂(寻仙)
CMD_SPIRIT_INIT = "spirit.init"--初始化寻仙界面信息
CMD_SPIRIT_FIND = "spirit.find"--寻仙
CMD_SPIRIT_CALL = "spirit.call"--召唤
CMD_SPIRIT_CALLMORE = "spirit.callmore"--多次召唤
CMD_SPIRIT_EQU = "spirit.equ"--装备元神
CMD_SPIRIT_UPGRADE = "spirit.upgrade"--元神升级
CMD_SPIRIT_EXCHANGE = "spirit.exchange"--碎片兑换元神


CMD_CRUSADE_GETINFO = "cru.getinfo"
CMD_CRUSADE_ENTER_FIGHT = "cru.enterfight"      
CMD_CRUSADE_FIGHT= "cru.fight"                      
CMD_CRUSADE_FEATS= "cru.feats"   
CMD_CRUSADE_RECEIVE_FEATS= "cru.recfeats"                          
CMD_CRUSADE_SHARE= "cru.share" 
CMD_CRUSADE_BUY= "cru.buy"                                                     
CMD_CRUSADE_SHOP_BUY= "cru.shopbuy"   
CMD_CRUSADE_ADD_TOKEN= "cru.addtoken"   
CMD_CRUSADE_GETNUM= "cru.getnum"        
CMD_CRUSADE_CALLINFO= "cru.callinfo"
CMD_CRUSADE_CALL= "cru.call"                                  




CMD_ACT_GETINFO97 = "act.getinfo97" --- 获取财神送宝界面信息
CMD_ACT_REC97_DAY_REWARD = "act.rec97day"  ---  领取财神送宝每日奖励
CMD_ACT_REC97_BOX_REWARD = "act.rec97box"  ---  领取财神送宝宝箱奖励
    