--Malak, the Old God of Sovereignty
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	--Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
    --"Old God" effects cannot be negated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.effectfilter)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISEFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.effectfilter)
	c:RegisterEffect(e3)
	--Special Summon this and 1 "Old God" monster from your hand or GY
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
    --Mill 1 "Old God" card to the GY and Special Summon "Old God" from your Deck
	local e12=Effect.CreateEffect(c)
	e12:SetDescription(aux.Stringid(id,1))
	e12:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e12:SetType(EFFECT_TYPE_IGNITION)
	e12:SetRange(LOCATION_MZONE)
	e12:SetCountLimit(1,{id,1})
	e12:SetTarget(s.target)
	e12:SetOperation(s.operation)
	c:RegisterEffect(e12)
    --(Quick Effect) Tribute 1 "Old God" monster; return "Old God" cards from your GY to your Deck and then you can banish cards your opponent controls up to the number of shuffled cards
	local e13=Effect.CreateEffect(c)
	e13:SetDescription(aux.Stringid(id,2))
	e13:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e13:SetType(EFFECT_TYPE_QUICK_O)
    e13:SetCode(EVENT_FREE_CHAIN)
	e13:SetRange(LOCATION_MZONE)
    e13:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e13:SetCountLimit(1,{id,2})
	e13:SetCost(s.millcost)
    e13:SetTarget(s.milltg)
    e13:SetOperation(s.millop)
	c:RegisterEffect(e13)
end

local SET_OLD_GOD=0x653
s.listed_series={SET_OLD_GOD}

function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_RITUAL)==SUMMON_TYPE_RITUAL
            or (se:IsHasType(EFFECT_TYPE_ACTIONS) and se:GetHandler():IsSetCard(SET_OLD_GOD))
end

function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:GetHandler():IsSetCard(SET_OLD_GOD)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ch=Duel.GetCurrentChain()-1
	if ch<=0 then return false end
	local cplayer=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER)
	local ceff=Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_EFFECT)
	return ep==1-tp and cplayer==tp and ceff:GetHandler():IsSetCard(SET_OLD_GOD)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_OLD_GOD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_HAND,0,1,c,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE|LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_HAND,0,1,e:GetHandler(),e,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_HAND,0,1,1,e:GetHandler(),e,tp)
		if #g>0 then
			g:AddCard(e:GetHandler())
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end

function s.tgfilter(c,e,tp)
	return c:IsSetCard(SET_OLD_GOD) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,c,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_OLD_GOD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g==0 then return end
	Duel.SendtoGrave(g,REASON_EFFECT)
	local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #og>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
        if #tc>0 then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
	end
end

function s.costfilter(c)
	return c:IsSetCard(SET_OLD_GOD) and c:IsReleasable()
end
function s.millcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function s.tdfilter(c)
    return c:IsSetCard(SET_OLD_GOD) and c:IsAbleToDeck()
end
function s.milltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	local gy = Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    -- store N = current number of Old God in GY (this is BEFORE the shuffle)
    local N = #gy
    e:SetLabel(N)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
function s.millop(e,tp,eg,ep,ev,re,r,rp)
    local N = e:GetLabel() or 0
    if N<=0 then return end

    local gy = Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)

    local ct_shuffled = 0
    if #gy>0 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local sg = gy:Select(tp,0,#gy,nil)
            if #sg>0 then
                local moved = Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
                if moved>0 then
                    local og = Duel.GetOperatedGroup()
                    ct_shuffled = og:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
                end
            end
        end
    end

    local og2 = Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
    if #og2==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local maxban = math.min(N,#og2)
	local rg = nil
	if maxban==#og2 then
		maxban = math.min(maxban,ct_shuffled)
		rg = og2
	else
		rg = og2:Select(tp,maxban,maxban,nil)
	end
    if #rg>0 then
        if ct_shuffled>0 then
            Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
        else
            Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
        end
    end
end
