-- United Cheat
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Filter function to include all monsters from the Extra Deck
function s.spfilter(c,e,tp)
    return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

-- Target function
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local ft1=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_EXTRA)
        local ft2=Duel.GetLocationCountFromEx(1-tp,1-tp,nil,TYPE_EXTRA)
        return (ft1>0 or ft2>0) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Activate function
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local ft1=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_EXTRA)
    local ft2=Duel.GetLocationCountFromEx(1-tp,1-tp,nil,TYPE_EXTRA)
    if ft1<=0 and ft2<=0 then return end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft1=1 end
    if Duel.IsPlayerAffectedByEffect(1-tp,CARD_BLUEEYES_SPIRIT) then ft2=1 end
    if ft1+ft2>12 then ft1,ft2=math.min(ft1,12),math.min(ft2,12-ft1) end
    local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
    if #tg==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=tg:Select(tp,1,ft1+ft2,nil)
    for tc in aux.Next(g) do
        local field_tp = tp
        if ft1 > 0 and ft2 > 0 then
            local option = Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
            if option == 1 then
                field_tp = 1-tp
            end
        elseif ft1 <= 0 then
            field_tp = 1-tp
        end

        if tc:IsType(TYPE_FUSION) then
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,field_tp,true,false,POS_FACEUP)
        elseif tc:IsType(TYPE_SYNCHRO) then
            Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,field_tp,true,false,POS_FACEUP)
        elseif tc:IsType(TYPE_XYZ) then
            Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,field_tp,true,false,POS_FACEUP)
        elseif tc:IsType(TYPE_LINK) then
            Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,field_tp,true,false,POS_FACEUP)
        else
            Duel.SpecialSummonStep(tc,0,tp,field_tp,true,false,POS_FACEUP)
        end
        tc:CompleteProcedure()

        if field_tp == tp then
            ft1 = ft1 - 1
        else
            ft2 = ft2 - 1
        end
    end
    Duel.SpecialSummonComplete()
end
