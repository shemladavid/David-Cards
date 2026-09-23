--Magician’s Threefold Command
local s,id=GetID()
function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--negate spell
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negspcon)
	e2:SetOperation(s.negspop)
	c:RegisterEffect(e2)
    --negate trap
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.negtrcon)
	e3:SetOperation(s.negtrop)
	c:RegisterEffect(e3)
	aux.DoubleSnareValidity(c,LOCATION_SZONE)
    --Negate monster effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.negmscon)
	e4:SetOperation(s.negmsop)
	c:RegisterEffect(e4)
	--Return during either player's Standby Phase
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e5:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
    e5:SetCondition(s.returncon)
    e5:SetTarget(s.returntg)
    e5:SetOperation(s.returnop)
    c:RegisterEffect(e5)
	--Banish a monster and return it to the field
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,0))
	e6:SetCategory(CATEGORY_REMOVE)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCountLimit(1,id)
	e6:SetTarget(s.rmvtg(s.rmvfilter1))
	e6:SetOperation(s.rmvop)
	c:RegisterEffect(e6)
	--Banish a monster that has its effects negated and return it to the field
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_REMOVE)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e7:SetCode(EVENT_CHAINING)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCountLimit(1,{id,1})
	e7:SetCondition(function(e,tp,eg,ep) return ep==1-tp end)
	e7:SetTarget(s.rmvtg(s.rmvfilter2))
	e7:SetOperation(s.rmvop)
	c:RegisterEffect(e7)
	--shuffle all cards in the hand into the deck and draw the same number of cards
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCountLimit(1,{id,2})
	e8:SetTarget(s.target)
	e8:SetOperation(s.activate)
	c:RegisterEffect(e8)
end

function s.negspcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,1,nil)
		and rp~=tp and re:IsSpellEffect() and Duel.IsChainDisablable(ev) 
end
function s.negspop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end

function s.negtrcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,1,nil)
		and rp==1-tp and re:IsTrapEffect() and Duel.IsChainDisablable(ev)
end
function s.negtrop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end

function s.negmscon(e,tp,eg,ep,ev,re,r,rp)
	-- the effect is not 41235896
	if re:GetHandler() and re:GetHandler():GetCode()==41235896 then return false end
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_SPELLCASTER),tp,LOCATION_MZONE,0,1,nil)
		and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
function s.negmsop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
		Duel.Destroy(rc,REASON_EFFECT)
	end
end

function s.returncon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()
end

function s.returntg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local owner=c:GetOwner()
    if chk==0 then
        return Duel.GetLocationCount(owner,LOCATION_SZONE)>0
            and c:CheckUniqueOnField(owner)
    end
end

function s.returnop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local owner=c:GetOwner()
    if c:IsRelateToEffect(e)
        and Duel.GetLocationCount(owner,LOCATION_SZONE)>0
        and c:CheckUniqueOnField(owner) then
        Duel.MoveToField(c,tp,owner,LOCATION_SZONE,POS_FACEUP,true)
    end
end

function s.rmvfilter1(c)
	return c:IsAbleToRemove() and Duel.GetMZoneCount(c:GetControler(),c)>0
end
function s.rmvfilter2(c)
	return c:IsDisabled() and c:IsType(TYPE_EFFECT) and c:IsAbleToRemove() and Duel.GetMZoneCount(c:GetControler(),c)>0
end
function s.rmvtg(filter)
	return function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
		if chkc then return chkc:IsLocation(LOCATION_MZONE) and filter(chkc) end
		if chk==0 then return Duel.IsExistingTarget(filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
	end
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,nil,REASON_EFFECT|REASON_TEMPORARY)>0 and tc:IsLocation(LOCATION_REMOVED)
		and not tc:IsReason(REASON_REDIRECT) then
		Duel.BreakEffect()
		Duel.ReturnToField(tc)
	end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if #g==0 then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	Duel.ShuffleDeck(p)
	Duel.BreakEffect()
	Duel.Draw(p,#g,REASON_EFFECT)
end