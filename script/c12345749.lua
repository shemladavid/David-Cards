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
	-- "Exodia the Forbidden One": Negate when battle
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.headcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	-- "Right Arm of the Forbidden One": This card cannot be targeted
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.rightarmcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- "Right Arm of the Forbidden One": Negate opponent cards activation or effects
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))
	e6:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1,id)
	e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e6:SetCondition(s.negatecon)
	e6:SetTarget(s.negatetg)
	e6:SetOperation(s.negateop)
	c:RegisterEffect(e6)
	-- "Left Arm of the Forbidden One": no battle damage
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e7:SetTargetRange(1,0)
	e7:SetCondition(s.leftarmcon)
	c:RegisterEffect(e7)
	-- "Left Arm of the Forbidden One": Banish 1 trap your opponent control or in GY, and this card gains 500 ATK
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,0))
	e8:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetRange(LOCATION_MZONE)
	e8:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e8:SetCountLimit(1,id)
	e8:SetCondition(s.leftarmcon)
	e8:SetTarget(s.removetraptg)
	e8:SetOperation(s.removetrapop)
	c:RegisterEffect(e8)
	-- "right leg of the Forbidden One": no effect damage
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCode(EFFECT_CHANGE_DAMAGE)
	e9:SetTargetRange(1,0)
	e9:SetCondition(s.rightlegcon)
	e9:SetValue(s.damval)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e10)
	-- "right leg of the Forbidden One": Banish 1 spell your opponent control or in GY, and this card gains 500 ATK
	local e11=Effect.CreateEffect(c)
	e11:SetDescription(aux.Stringid(id,1))
	e11:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e11:SetType(EFFECT_TYPE_QUICK_O)
	e11:SetCode(EVENT_FREE_CHAIN)
	e11:SetRange(LOCATION_MZONE)
	e11:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e11:SetCountLimit(1,{id,1})
	e11:SetCondition(s.rightlegcon)
	e11:SetTarget(s.removespelltg)
	e11:SetOperation(s.removespellop)
	c:RegisterEffect(e11)
	-- "left leg of the Forbidden One": gain 1000 ATK after battle
	local e12=Effect.CreateEffect(c)
	e12:SetCategory(CATEGORY_ATKCHANGE)
	e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e12:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e12:SetRange(LOCATION_MZONE)
	e12:SetCountLimit(1)
	e12:SetCondition(s.atkcon1000)
	e12:SetOperation(s.atkop1000)
	c:RegisterEffect(e12)
	-- "left leg of the Forbidden One": Banish 1 monster your opponent control or in GY, and this card gains 500 ATK
	local e13=Effect.CreateEffect(c)
	e13:SetDescription(aux.Stringid(id,2))
	e13:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e13:SetType(EFFECT_TYPE_QUICK_O)
	e13:SetCode(EVENT_FREE_CHAIN)
	e13:SetRange(LOCATION_MZONE)
	e13:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e13:SetCountLimit(1,{id,2})
	e13:SetCondition(s.leftlegcon)
	e13:SetTarget(s.removemonstertg)
	e13:SetOperation(s.removemonsterop)
	c:RegisterEffect(e13)
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

function s.negatecon(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp~=tp and Duel.IsChainNegatable(ev) and Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil,CARD_EXODIA_RIGHT_ARM)
end
function s.negatetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
function s.negateop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
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