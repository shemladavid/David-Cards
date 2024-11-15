-- Chimera Hydradrive Dragrid
local s,id=GetID()
function s.initial_effect(c)
    c:EnableCounterPermit(0x577)
    -- link summon
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_LINK),5,5,s.lcheck)
    c:EnableReviveLimit()

    -- Effect 1: Place 1 Hydradrive Counter when Special Summoned from Extra Deck
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_COUNTER)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.ctcon)
    e1:SetOperation(s.ctop)
    c:RegisterEffect(e1)

    -- Effect 2: Quick Effect during Main Phase
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(TIMING_MAIN_END)
    e2:SetCountLimit(1)
    e2:SetCondition(s.spcon)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

-- Listed Series
s.listed_series = {0x577}

function s.lcheck(g,lc,sumtype,tp)
    return g:CheckDifferentPropertyBinary(Card.GetAttribute,lc,sumtype,tp)
end

-- Function: Counter Placement Condition (Summoned from Extra Deck)
function s.ctcon(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end

-- Function: Counter Placement Operation
function s.ctop(e, tp, eg, ep, ev, re, r, rp)
    e:GetHandler():AddCounter(0x577, 1)
end

-- Function: Quick Effect Activation Condition (Main Phase)
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsMainPhase()
end

-- Function: Special Summon Cost (Remove 1 Hydradrive Counter)
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsCanRemoveCounter(tp, 0x577, 1, REASON_COST) end
    e:GetHandler():RemoveCounter(tp, 0x577, 1, REASON_COST)
end

-- Function: Special Summon Target (Search for a specific monster in Extra Deck)
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

-- Function: Special Summon Filter (Specify the conditions for the targeted monster)
function s.spfilter(c, e, tp)
    return c:IsSetCard(0x577)
    	and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) 
        and c:IsType(TYPE_LINK) 
        and c:GetLink() == 5
end

-- Function: Special Summon Operation (Perform the Special Summon)
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    if tc then
        Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
        Duel.BreakEffect()
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
end