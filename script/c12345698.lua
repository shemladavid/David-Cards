-- Gate of the Celestial Summoner
local s, id = GetID()
function s.initial_effect(c)
    -- Activate effect
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.filter(c, e, tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)+Duel.GetLocationCountFromEx(tp,tp,nil,nil)
    if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.activate(e, tp, eg, ep, ev, re, r, rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)+Duel.GetLocationCountFromEx(tp,tp,nil,nil)
    if ft<1 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    local tc = g:GetFirst()
    if tc then
        local summon_type = 0
        if tc:IsType(TYPE_FUSION) then
            summon_type = SUMMON_TYPE_FUSION
        elseif tc:IsType(TYPE_SYNCHRO) then
            summon_type = SUMMON_TYPE_SYNCHRO
        elseif tc:IsType(TYPE_XYZ) then
            summon_type = SUMMON_TYPE_XYZ
        elseif tc:IsType(TYPE_LINK) then
            summon_type = SUMMON_TYPE_LINK
        end
        Duel.SpecialSummon(tc, summon_type, tp, tp, true, false, POS_FACEUP)
        tc:CompleteProcedure()
    end
end