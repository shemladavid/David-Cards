-- Floowandereeze & True Friendship
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
	-- Reveal 1 monster in hand, return it to Deck bottom, add same type
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- Normal Summon Winged Beast monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e2:SetTarget(s.smtg)
    e2:SetOperation(s.smop)
    c:RegisterEffect(e2)
    --disable special summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_SPSUMMON)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,2})
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
    c:RegisterEffect(e3)
end

function s.thfilter(c,tp)
	if not c:IsMonster() then return false end
	local typ = c:GetType() & TYPE_MONSTER
	return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil,typ)
end
function s.addfilter(c,typ)
	return c:IsType(TYPE_MONSTER) and (c:GetType() & TYPE_MONSTER)==typ and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- Select 1 monster in hand to reveal
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if not tc then return end
	local typ = tc:GetType() & TYPE_MONSTER

	Duel.ConfirmCards(1-tp,tc)
	Duel.ShuffleHand(tp)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local dg=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil,typ)
	if #dg>0 then
		local addcard=dg:GetFirst()
		Duel.SendtoHand(addcard,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,addcard)
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end


function s.smfilter(c)
    return c:IsRace(RACE_WINGEDBEAST) and c:IsType(TYPE_MONSTER) and c:IsSummonable(true,nil)
end
function s.smtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.smfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.smop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local g=Duel.SelectMatchingCard(tp,s.smfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.Summon(tp,g:GetFirst(),true,nil)
    end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp~=ep and Duel.GetCurrentChain()==0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSummonType,SUMMON_TYPE_TRIBUTE),tp,LOCATION_MZONE,0,1,nil)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
end