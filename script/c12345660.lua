--Ultimate Cheat
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --spsummon from the extra deck
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTarget(s.extarget)
    e2:SetOperation(s.exoperation)
    c:RegisterEffect(e2)
    -- spsummon from the hand or deck
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTarget(s.sptarget)
    e3:SetOperation(s.spoperation)
    c:RegisterEffect(e3)
end

function s.exfilter(c,e,tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
end

function s.extarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.exoperation(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCountFromEx(tp, tp, nil, nil)+ Duel.GetLocationCount(tp, LOCATION_MZONE)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.exfilter,tp,LOCATION_EXTRA,0,1,math.min(ft,6),nil,e,tp)
    if #g>0 then
        for tc in aux.Next(g) do
            if tc:IsType(TYPE_FUSION) then
                Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,true,false,POS_FACEUP)
            elseif tc:IsType(TYPE_SYNCHRO) then
                Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,true,false,POS_FACEUP)
            elseif tc:IsType(TYPE_XYZ) then
                Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,true,false,POS_FACEUP)
            elseif tc:IsType(TYPE_LINK) then
                Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,true,false,POS_FACEUP)
            else
                Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
            end
            tc:CompleteProcedure()
        end
        Duel.SpecialSummonComplete()
    end
end



function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and not c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if chk==0 then return ft>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND+LOCATION_DECK)
end

function s.spoperation(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<1 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,math.min(ft,6),nil,e,tp)
    if #g>0 then
        for tc in aux.Next(g) do
            if tc:IsType(TYPE_RITUAL) then
                Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
            else
                Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
            end
            tc:CompleteProcedure()
        end
        Duel.SpecialSummonComplete()
    end
end