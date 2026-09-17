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