--[[Author: Arshart   arshartcloud@gmail.com
	这是一个针对2019 3v3的扩展
	这个扩展可能会损害身份局的功能，请不要在此扩展使用身份局
	module("extensions.3v32019", package.seeall)
]]--
extension_3v32019 = sgs.Package("3v32019")

nuanzhuadd1card = sgs.CreateTriggerSkill{
	name = "nuanzhuadd1card",
	events = {sgs.GameStart, sgs.Damage},
	global = true,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
			if player:getRole() == "lord" then
	            for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:getRole() == "lord" then
						p:drawCards(1, self:objectName())
					end
				end
			end
		end
		return false
	end
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("nuanzhuadd1card") then skills:append(nuanzhuadd1card) end
sgs.Sanguosha:addSkills(skills)

huangquan3v32019 = sgs.General(extension_3v32019, "huangquan3v32019", "shu", 3, true)
xuhuang3v32019 = sgs.General(extension_3v32019, "xuhuang3v32019", "wei", 4, true)
sunshangxiang3v32019 = sgs.General(extension_3v32019, "sunshangxiang3v32019", "wu", 3, false)
guanyu3v32019 = sgs.General(extension_3v32019, "guanyu3v32019", "shu", 4, true)
dianwei3v32019 = sgs.General(extension_3v32019, "dianwei3v32019", "wei", 4, true)
huangyueying3v32019 = sgs.General(extension_3v32019, "huangyueying3v32019", "shu", 3, false)
zhenji3v32019 = sgs.General(extension_3v32019, "zhenji3v32019", "wei", 3, false)
sunquan3v32019 =  sgs.General(extension_3v32019, "sunquan3v32019", "wu", 4, true)

choujin = sgs.CreateTriggerSkill{
	name = "choujin3v32019",
	events = {sgs.GameStart, sgs.Damage},
	global = true,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data, room)
		if event == sgs.GameStart then
			if RIGHT(self, player) then
				local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "choujin-invoke", false, sgs.GetConfig("face_game", true))
	            if to then
					room:broadcastSkillInvoke(self:objectName(), 1)
					room:addPlayerMark(player, self:objectName().."engine")
					if player:getMark(self:objectName().."engine") > 0 then
						room:addPlayerMark(to, "@aim")
						room:addPlayerMark(to, "aim"..player:objectName())
						room:removePlayerMark(player, self:objectName().."engine")
					end
				end
			end
		else
            local damage = data:toDamage()
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
--				if damage.to:getMark("aim"..p:objectName()) > 0 and damage.to:isAlive() and player:isAlive() and damage.from and room:askForSkillInvoke(p, self:objectName(), data) then
				if damage.from and damage.to:getMark("aim"..p:objectName()) > 0 and damage.to:isAlive() and player:isAlive() and string.sub(damage.from:getRole(), 1, 1) == string.sub(p:getRole(), 1, 1)  then
                    SendComLog(self, p, 2)
                    damage.from:drawCards(1, self:objectName())
				end
			end
		end
		return false
	end
}
huangquan3v32019:addSkill(choujin)

zhongjian3v32019Card = sgs.CreateSkillCard{
	name = "zhongjian3v32019",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
    filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
        room:obtainCard(targets[1], self, false)
        room:drawCards(source, 1)
	end
}
zhongjian3v32019 = sgs.CreateOneCardViewAsSkill{
	name = "zhongjian3v32019",
    filter_pattern = ".",
	view_as = function(self,card)
		local skillcard = zhongjian3v32019Card:clone()
		skillcard:addSubcard(card)
		return skillcard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#zhongjian3v32019")
	end
}
huangquan3v32019:addSkill(zhongjian3v32019)

duanliang_buff = sgs.CreateTargetModSkill{
	name = "#duanliang3v3",
	pattern = "SupplyShortage",
	distance_limit_func = function(self, from, card, to)
		if from:hasSkill("duanliang") and to and to:getHandcardNum() >= from:getHandcardNum() then
			return 1000
		end
		return 0
	end
}
xuhuang3v32019:addSkill("duanliang")
xuhuang3v32019:addSkill(duanliang_buff)
extension_3v32019:insertRelatedSkills("duanliang", "#duanliang3v3")
xuhuang3v32019:addSkill("jiezi")

sunshangxiang3v32019:addSkill("xiaoji")
jieyin3v32019Card = sgs.CreateSkillCard{
	name = "jieyin3v32019",
	will_throw = true,
    filter = function(self, targets, to_select)
		return #targets == 0 and to_select:isMale() and to_select:isWounded()
	end,
	on_use = function(self, room, source, targets)
		room:recover(source, sgs.RecoverStruct(source))
        room:recover(targets[1], sgs.RecoverStruct(source))
	end
}
jieyin3v32019 = sgs.CreateViewAsSkill{
    n = 2,
	name = "jieyin3v32019",
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self,cards)
		if #cards < 2 then
			return nil
		end
		local skillcard = jieyin3v32019Card:clone()
		for _, c in ipairs(cards) do
			skillcard:addSubcard(c)
		end
		return skillcard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#jieyin3v32019")
	end
}
sunshangxiang3v32019:addSkill(jieyin3v32019)

wusheng3v32019 = sgs.CreateOneCardViewAsSkill{
	name = "wusheng3v32019",
	view_filter = function(self, card)
		return card:isRed()
	end,
	view_as = function(self, card)
		local vs_card = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
		vs_card:addSubcard(card:getId())
		vs_card:setSkillName(self:objectName())
		return vs_card
	end,
	enabled_at_play = function(self, player)
		local poi = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, -1)
		if poi and poi:isAvailable(player) then
			return true
		end
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end
}
guanyu3v32019:addSkill(wusheng3v32019)
zhongyi3v32019Card = sgs.CreateSkillCard{
	name = "zhongyi3v32019",
	will_throw = false,
	target_fixed = true,
	on_use = function(self, room, source, targets)
		source:addToPile("yi", self)
	end
}
zhongyi3v32019VS = sgs.CreateViewAsSkill{
	name = "zhongyi3v32019",
	n = 99999,
	expand_pile = "yi",
	view_filter = function(self, selected, to_select)
		return to_select:isRed()
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local skillcard = zhongyi3v32019Card:clone()
		for _, c in ipairs(cards) do
			skillcard:addSubcard(c)
		end
		skillcard:setSkillName(self:objectName())
		return skillcard
	end,
	enabled_at_play = function(self, player)
		return player:getPile("yi"):isEmpty()
	end,
}
zhongyi3v32019 = sgs.CreateTriggerSkill{
	name = "zhongyi3v32019",
	global = true,
	events = {sgs.DamageCaused},
	view_as_skill = zhongyi3v32019VS,
	on_trigger = function(self, event, player, data, room)
		local damage = data:toDamage()
		for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
			if damage.card and damage.from and damage.card:isKindOf("Slash") and not p:getPile("yi"):isEmpty() then
				if string.sub(damage.from:getRole(), 1, 1) == string.sub(p:getRole(), 1, 1) and string.sub(damage.from:getRole(), 1, 1) ~= string.sub(damage.to:getRole(), 1, 1) then
					room:fillAG(p:getPile("yi"), p)
					local id = room:askForAG(p, p:getPile("yi"), false, self:objectName())
					room:clearAG()
					room:throwCard(sgs.Sanguosha:getCard(id), sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", p:objectName(), self:objectName(), ""), nil)
					damage.damage = damage.damage + 1
					data:setValue(damage)
				end
			end
		end

	end
}
guanyu3v32019:addSkill(zhongyi3v32019)
--
	qiangxi3v32019Card = sgs.CreateSkillCard{
		name = "qiangxi3v32019",
		filter = function(self, targets, to_select)
			if #targets ~= 0 or to_select:objectName() == sgs.Self:objectName()  then return false end--
			local rangefix = 0
			if not self:getSubcards():isEmpty() and sgs.Self:getWeapon() and sgs.Self:getWeapon():getId() == self:getSubcards():first() then
				local card = sgs.Self:getWeapon():getRealCard():toWeapon()
				rangefix = rangefix + card:getRange() - sgs.Self:getAttackRange(false)
			end
			return to_select:getMark(self:objectName().."y-Clear")==0  and sgs.Self:inMyAttackRange(to_select, rangefix);
		end,
		on_effect = function(self, effect)
			local room = effect.to:getRoom()
			if self:getSubcards():isEmpty() then
				room:loseHp(effect.from)
				room:addPlayerMark(effect.from, self:objectName().."i-Clear")
	else
		     room:addPlayerMark(effect.from, self:objectName().."n-Clear")
			end
			room:broadcastSkillInvoke("qiangxi3v32019", math.random(1,2))
			room:damage(sgs.DamageStruct(self:objectName(), effect.from, effect.to))
			room:addPlayerMark(effect.to, self:objectName().."y-Clear")
		end
	}
	qiangxi3v32019 = sgs.CreateViewAsSkill{
		name = "qiangxi3v32019",
		n = 1,
		enabled_at_play = function(self, player)
			return player:usedTimes("#qiangxi3v32019") < 2
		end,
		view_filter = function(self, selected, to_select)
			return sgs.Self:getMark(self:objectName().."n-Clear")==0 and #selected == 0 and to_select:isKindOf("Weapon") and not sgs.Self:isJilei(to_select)
		end,
		view_as = function(self, cards)
			if #cards == 0 and sgs.Self:getMark(self:objectName().."i-Clear")==0 then
				return qiangxi3v32019Card:clone()
	       elseif #cards == 1 and sgs.Self:getMark(self:objectName().."n-Clear")==0 then
				local card = qiangxi3v32019Card:clone()
				card:addSubcard(cards[1])
				return card
			else
				return nil
			end
		end
	}
dianwei3v32019:addSkill(qiangxi3v32019)

LuaNosJizhi = sgs.CreateTriggerSkill{
	name = "LuaNosJizhi" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.CardUsed} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isNDTrick() and room:askForSkillInvoke(player, self:objectName()) then
			player:drawCards(1, self:objectName())
		end
		return false
	end
}

LuaNosQicai = sgs.CreateTargetModSkill{
	name = "LuaNosQicai" ,
	pattern = "TrickCard" ,
	distance_limit_func = function(self, from)
		if from:hasSkill(self:objectName()) then
			return 1000
		else
			return 0
		end
	end
}
huangyueying3v32019:addSkill(LuaNosQicai)
huangyueying3v32019:addSkill(LuaNosJizhi)

LuaLuoshen = sgs.CreateTriggerSkill{
		name = "LuaLuoshen",
		frequency = sgs.Skill_Frequent,
		events = {sgs.EventPhaseStart, sgs.FinishJudge},
		on_trigger = function(self, event, player, data)
			local room = player:getRoom()
			if event == sgs.EventPhaseStart then
				if player:getPhase() == sgs.Player_Start then
					while player:askForSkillInvoke(self:objectName()) do
						local judge = sgs.JudgeStruct()
						judge.pattern = ".|black"
						judge.good = true
						judge.reason = self:objectName()
						judge.who = player
						judge.time_consuming = true
						room:judge(judge)
						if judge:isBad() then
							break
						end
					end
				end
			elseif event == sgs.FinishJudge then
				local judge = data:toJudge()
				if judge.reason == self:objectName() then
					local card = judge.card
					if card:isBlack() then
						player:obtainCard(card)
						return true
					end
				end
			end
			return false
		end
	}
zhenji3v32019:addSkill(LuaLuoshen)
zhenji3v32019:addSkill("qingguo")

LuaZhihengCard = sgs.CreateSkillCard{
			name = "LuaZhihengCard",
			target_fixed = true,
			mute = true,
			on_use = function(self, room, source, targets)
				if source:isAlive() then
					room:drawCards(source, self:subcardsLength(), "zhiheng")
				end
			end
		}
		LuaZhiheng = sgs.CreateViewAsSkill{
			name = "LuaZhiheng",
			n = 999,
			view_filter = function(self, selected, to_select)
				return not sgs.Self:isJilei(to_select)
			end,
			view_as = function(self, cards)
				if #cards == 0 then return nil end
				local zhiheng_card = LuaZhihengCard:clone()
				for _,card in pairs(cards) do
					zhiheng_card:addSubcard(card)
				end
				zhiheng_card:setSkillName(self:objectName())
				return zhiheng_card
			end,
			enabled_at_play = function(self, player)
				return not player:hasUsed("#LuaZhihengCard") and player:canDiscard(player, "he")
			end,
			enabled_at_response = function(self, target, pattern)
				return pattern == "@zhiheng"
			end
		}

sunquan3v32019:addSkill(LuaZhiheng)

sgs.LoadTranslationTable{

    ["3v32019"]="3v3 2019",
    ["huangquan3v32019"]="黄权3v3",
    ["&huangquan3v32019"]="黄权",
    ["#huangquan3v32019"]="道绝殊途",
    ["choujin3v32019"]="筹进",
    [":choujin3v32019"]="锁定技，游戏开始时，你指定一名其他角色；每当己方角色对其造成一次伤害后，摸一张牌",
    ["choujin-invoke"]="请选择一名筹进的目标",
    ["zhongjian3v32019"]="忠谏",
    [":zhongjian3v32019"]="出牌阶段限一次，你可以交给一名己方角色一张牌，然后你摸一张牌",
	["~huangquan3v32019"] = "阿我死了",

    ["xuhuang3v32019"]="徐晃3v3",
    ["&xuhuang3v32019"]="徐晃",
    ["#xuhuang3v32019"]="周亚夫之风",
    [":duanliang"] = "你可以将一张黑色基本牌或黑色装备牌当【兵粮寸断】使用；你可以对距离2的角色使用【兵粮寸断】，若一名角色的手牌数大于或等于你的手牌数，你对其使用【兵粮寸断】没有距离限制。",
	["~xuhuang3v32019"] = "阿我死了",

    ["sunshangxiang3v32019"]="孙尚香3v3",
    ["&sunshangxiang3v32019"]="孙尚香",
    ["#sunshangxiang3v32019"]="弓腰姬",
	["jieyin3v32019"] = "结姻",
	[":jieyin3v32019"] = "出牌阶段限一次，你可以弃置两张手牌，令你与一名已受伤的男性角色各回复1点体力",
	["~sunshangxiang3v32019"] = "阿我死了",

	["guanyu3v32019"]="关羽3v3",
    ["&guanyu3v32019"]="关羽",
    ["#guanyu3v32019"]="美髯公",
	["wusheng3v32019"] = "武圣",
	[":wusheng3v32019"] = "你可以将一张红色牌当【杀】使用或打出",
	["zhongyi3v32019"] = "忠义",
	[":zhongyi3v32019"] = "出牌阶段，若你的武将牌上没有牌，你可以将任意张红色牌置于武将牌上，称为“义”。己方角色使用【杀】对敌方角色造成伤害时，若你有“义”，则移去一张“义”令此伤害+1",
	["~guanyu3v32019"] = "阿我死了",

	["dianwei3v32019"] ="典韦3v3",
    ["&dianwei3v32019"]="典韦",
	["#dianwei3v32019"] = "古之恶来",
	["qiangxi3v32019"] = "强袭",
	[":qiangxi3v32019"]= "出牌阶段各限一次，你可以弃置一张武器牌或失去一点体力值，然后选择一个目标对其造成一点伤害（不能选择相同目标）。",
	["$qiangxi3v320191"] = "看我三步之内，取你小命。",
	["$qiangxi3v320192"] = "吃我一击。",
	["~dianwei3v32019"] = "主公快走！。",

	["huangyueying3v32019"] ="黄月英3v3",
    ["&huangyueying3v32019"]="黄月英",
	["#huangyueying3v32019"] = "归隐的杰女",
	["LuaNosQicai"] = "奇才",
	[":LuaNosQicai"]= "锁定技，你使用锦囊牌时无距离限制。",
	["LuaNosJizhi"] = "集智",
	[":LuaNosJizhi"]= "每当你使用非延时类锦囊牌选择目标后，你可以摸一张牌。",
	["~huangyueying3v32019"] = "按我司了！。",

	["zhenji3v32019"] ="甄姬3v3",
    ["&zhenji3v32019"]="甄姬",
	["#zhenji3v32019"] = "薄幸的美人",
	["LuaLuoshen"] = "洛神",
	[":LuaLuoshen"]= "准备阶段开始时，你可以进行一次判定，若判定结果为黑色，你获得生效后的判定牌且你可以重复此流程。",
	["~zhenji3v32019"] = "按我司了！。",

	["sunquan3v32019"] ="孙权3v3",
    ["&sunquan3v32019"]="孙权",
	["#sunquan3v32019"] = "年轻的贤君",
	["~sunquan3v32019"] = "啊我司了！。",
	["LuaZhiheng"] = "制衡",
	[":LuaZhiheng"]= "出牌阶段限一次，你可以弃置至少一张牌：若如此做，你摸等量的牌。",
}

return {extension_3v32019}
