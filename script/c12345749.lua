--エクゾディア・ネクロス
--Exodia Necross
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)

	--"Exodia the Forbidden One": This card cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.headcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- "Exodia the Forbidden One": Negate effect when battle
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.headcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	-- "Exodia the Forbidden One": cards in the GY cannot be banished
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_REMOVE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_GRAVE,0)
	e5:SetCondition(s.headcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)

	-- "Right Arm of the Forbidden One": This card cannot be targeted
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.rightarmcon)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	-- "Right Arm of the Forbidden One": unaffected by your opponent's card effects
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetCondition(s.rightarmcon)
	e7:SetValue(s.unval)
	c:RegisterEffect(e7)
	-- "Right Arm of the Forbidden One": (quick effect) target and destroyed 1 card your opponent controls
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,6))
	e8:SetCategory(CATEGORY_DESTROY)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetRange(LOCATION_MZONE)
	e8:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e8:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e8:SetCountLimit(1,{id,6})
	e8:SetCondition(s.rightarmcon)
	e8:SetTarget(s.destg)
	e8:SetOperation(s.desop)
	c:RegisterEffect(e8)

	-- "Left Arm of the Forbidden One": no battle damage
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e9:SetTargetRange(1,0)
	e9:SetCondition(s.leftarmcon)
	c:RegisterEffect(e9)
	-- "Left Arm of the Forbidden One": Banish 1 trap your opponent control or in GY, and this card gains 500 ATK
	local e10=Effect.CreateEffect(c)
	e10:SetDescription(aux.Stringid(id,0))
	e10:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e10:SetType(EFFECT_TYPE_QUICK_O)
	e10:SetCode(EVENT_FREE_CHAIN)
	e10:SetRange(LOCATION_MZONE)
	e10:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e10:SetCountLimit(1,id)
	e10:SetCondition(s.leftarmcon)
	e10:SetTarget(s.removetraptg)
	e10:SetOperation(s.removetrapop)
	c:RegisterEffect(e10)
	-- "Left Arm of the Forbidden One": negate your opponent trap card or effects
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,3))
	e11:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e11:SetType(EFFECT_TYPE_QUICK_O)
	e11:SetCode(EVENT_CHAINING)
	e11:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCountLimit(1,{id,3})
	e11:SetCondition(s.negtrapcon)
	e11:SetTarget(s.negtraptg)
	e11:SetOperation(s.negtrapop)
	c:RegisterEffect(e11)
	
	-- "right leg of the Forbidden One": no effect damage
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_FIELD)
	e12:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e12:SetRange(LOCATION_MZONE)
	e12:SetCode(EFFECT_CHANGE_DAMAGE)
	e12:SetTargetRange(1,0)
	e12:SetCondition(s.rightlegcon)
	e12:SetValue(s.damval)
	c:RegisterEffect(e12)
	local e13=e12:Clone()
	e13:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e13)
	-- "right leg of the Forbidden One": Banish 1 spell your opponent control or in GY, and this card gains 500 ATK
	local e14=Effect.CreateEffect(c)
	e14:SetDescription(aux.Stringid(id,1))
	e14:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e14:SetType(EFFECT_TYPE_QUICK_O)
	e14:SetCode(EVENT_FREE_CHAIN)
	e14:SetRange(LOCATION_MZONE)
	e14:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e14:SetCountLimit(1,{id,1})
	e14:SetCondition(s.rightlegcon)
	e14:SetTarget(s.removespelltg)
	e14:SetOperation(s.removespellop)
	c:RegisterEffect(e14)
	-- "right leg of the Forbidden One": negate your opponent spell card or effects
	local e15=Effect.CreateEffect(c)
	e15:SetDescription(aux.Stringid(id,4))
	e15:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e15:SetType(EFFECT_TYPE_QUICK_O)
	e15:SetCode(EVENT_CHAINING)
	e15:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e15:SetRange(LOCATION_MZONE)
	e15:SetCountLimit(1,{id,4})
	e15:SetCondition(s.negspellcon)
	e15:SetTarget(s.negspelltg)
	e15:SetOperation(s.negspellop)
	c:RegisterEffect(e15)

	-- "left leg of the Forbidden One": gain 1000 ATK after battle
	local e16=Effect.CreateEffect(c)
	e16:SetCategory(CATEGORY_ATKCHANGE)
	e16:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e16:SetCode(EVENT_DAMAGE_STEP_END)
	e16:SetRange(LOCATION_MZONE)
	e16:SetCountLimit(1)
	e16:SetCondition(s.atkcon1000)
	e16:SetOperation(s.atkop1000)
	c:RegisterEffect(e16)
	-- "left leg of the Forbidden One": Banish 1 monster your opponent control or in GY, and this card gains 500 ATK
	local e17=Effect.CreateEffect(c)
	e17:SetDescription(aux.Stringid(id,2))
	e17:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e17:SetType(EFFECT_TYPE_QUICK_O)
	e17:SetCode(EVENT_FREE_CHAIN)
	e17:SetRange(LOCATION_MZONE)
	e17:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e17:SetCountLimit(1,{id,2})
	e17:SetCondition(s.leftlegcon)
	e17:SetTarget(s.removemonstertg)
	e17:SetOperation(s.removemonsterop)
	c:RegisterEffect(e17)
	-- "left leg of the Forbidden One": negate your opponent monster effects
	local e18=Effect.CreateEffect(c)
	e18:SetDescription(aux.Stringid(id,5))
	e18:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e18:SetType(EFFECT_TYPE_QUICK_O)
	e18:SetCode(EVENT_CHAINING)
	e18:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e18:SetRange(LOCATION_MZONE)
	e18:SetCountLimit(1,{id,5})
	e18:SetCondition(s.negmonstercon)
	e18:SetTarget(s.negmonstertg)
	e18:SetOperation(s.negmonsterop)
	c:RegisterEffect(e18)
end
s.listed_names={8124921,44519536,70903634,7902349,33396948}
CARD_EXODIA_HEAD=33396948
CARD_EXODIA_RIGHT_ARM=70903634
CARD_EXODIA_LEFT_ARM=7902349
CARD_EXODIA_RIGHT_LEG=8124921
CARD_EXODIA_LEFT_LEG=44519536
function s.headcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,CARD_EXODIA_HEAD)
end
function s.rightarmcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,CARD_EXODIA_RIGHT_ARM)
end
function s.leftarmcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,CARD_EXODIA_LEFT_ARM)
end
function s.rightlegcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,CARD_EXODIA_RIGHT_LEG)
end
function s.leftlegcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,CARD_EXODIA_LEFT_LEG)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x57a0000)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x57a0000)
		tc:RegisterEffect(e2)
	end
end

function s.unval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

function s.removetraptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsTrap),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,500)
end
function s.removetrapop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsTrap),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end

function s.negtrapcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return ep~=tp and re:IsTrapEffect() and Duel.IsChainNegatable(ev) and
	Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,CARD_EXODIA_LEFT_ARM)
end
function s.negtraptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rc=re:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,tp,0)
	end
end
function s.negtrapop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function s.damval(e,re,val,r,rp,rc)
	return (r&REASON_EFFECT)==0 and val or 0
end

function s.removespelltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSpell),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,500)
end
function s.removespellop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSpell),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end

function s.negspellcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return ep~=tp and re:IsSpellEffect() and Duel.IsChainDisablable(ev) 
	and Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,CARD_EXODIA_RIGHT_LEG)
end
function s.negspelltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.negspellop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
	if re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function s.atkcon1000(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,CARD_EXODIA_LEFT_LEG) and e:GetHandler():GetBattledGroupCount()>0
end
function s.atkop1000(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end

function s.removemonstertg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,c,1,tp,500)
end
function s.removemonsterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end

function s.negmonstercon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
	and Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,CARD_EXODIA_LEFT_LEG)
end
function s.negmonstertg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.negmonsterop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end