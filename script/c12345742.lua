-- Ojama Realm
local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --swap ad
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCondition(s.atcon)
	e2:SetCode(EFFECT_SWAP_BASE_AD)
	c:RegisterEffect(e2)
    -- Ojama cards cannot be targeted by opponent's card effects
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_ONFIELD, 0)
    e3:SetTarget(function(e, c) return c:IsSetCard(SET_OJAMA) end)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
    -- Add 2 "Ojama" cards to hand and you can discard 1 card
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1,id)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
    -- Fusion Summon
    local params = {
        fusfilter = s.fusfilter,
        matfilter = aux.FALSE,
        extrafil = s.extrafil,
        stage2 = s.stage2,
        extratg = s.extratg
    }
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1, {id, 1})
    e5:SetTarget(Fusion.SummonEffTG(params))
    e5:SetOperation(Fusion.SummonEffOP(params))
    c:RegisterEffect(e5)
    -- negate
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 2))
    e6:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_CHAINING)
    e6:SetCountLimit(1, {id, 2})
    e6:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCondition(s.ngcon)
    e6:SetTarget(s.ngtg)
    e6:SetOperation(s.ngop)
    c:RegisterEffect(e6)
    -- Special Summon from GY
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 3))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_IGNITION)
    e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCountLimit(1, {id, 3})
    e7:SetTarget(s.sptg)
    e7:SetOperation(s.spop)
    c:RegisterEffect(e7)
end
s.listed_series={SET_OJAMA}

function s.atcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_OJAMA),e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end

-- Fusion filter: only “Ojama” Fusion Monsters
function s.fusfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_OJAMA)
end
-- Extra‐materials: Hand/Deck/Extra/Field → GY  OR  GY → shuffle (flagged)
function s.extrafil(e, tp, mg1)
	-- (a) monsters from Hand/Deck/Extra/Field that can be sent to GY
	local g1 = Duel.GetMatchingGroup(
		Fusion.IsMonsterFilter(Card.IsAbleToGrave),
		tp,
		LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_MZONE,
		0,
		nil
	)
	-- (b) "Ojama" monsters in GY that can be shuffled into the Deck
	local g2 = Duel.GetMatchingGroup(s.shufflefilter, tp, LOCATION_GRAVE, 0, nil)
	for sc in aux.Next(g2) do
		sc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)
	end
	g2:KeepAlive()

	-- allow mixing any combination
	aux.FCheckAdditional = aux.FCheckMix or function() return true end
	aux.GCheckAdditional = aux.GCheckMix or function() return true end

	return g1:Merge(g2)
end
-- “Ojama” monsters in GY that can be shuffled
function s.shufflefilter(c)
	return c:IsSetCard(SET_OJAMA) and c:IsMonster() and c:IsAbleToDeck()
end

-- After selecting materials: only shuffle those that were flagged (originated in GY)
function s.stage2(e, tc, tp, sg, chk)
	if chk == 1 then
		local todeck = sg:Filter(function(c)
			return c:GetFlagEffect(id) > 0
		end, nil)
		if #todeck > 0 then
			Duel.SendtoDeck(todeck, nil, SEQ_DECKSHUFFLE,
			                REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
		end
	end
end

-- Declare zones: will send some to GY and shuffle some from GY → Deck
function s.extratg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 0, tp,
	                               LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_MZONE)
	Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 0, tp, LOCATION_GRAVE)
end


function s.thfilter(c)
    return c:IsSetCard(SET_OJAMA) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk==0 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		return g:GetClassCount(Card.GetCode)>=2
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetClassCount(Card.GetCode)>=2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=g:Select(tp,1,1,nil)
		g1:Merge(g2)
		Duel.SendtoHand(g1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g1)
        if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) and
           Duel.SelectYesNo(tp,aux.Stringid(id, 4)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
            local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
            Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
        end
	end
end

function s.ngfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_OJAMA) and c:IsMonster()
end
function s.ngcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.ngfilter, tp, LOCATION_MZONE, 0, 1, nil) and rp ~= tp and
               not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.ngtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end
function s.ngop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(SET_OJAMA) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local ft=math.min(3,Duel.GetLocationCount(tp,LOCATION_MZONE))
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if #g==0 then return end
	for tc in g:Iter() do
	    Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
end