--Elemental HERO Fusion Machine
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    --Always treated as "Polymerization"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetRange(LOCATION_SZONE+LOCATION_GRAVE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(CARD_POLYMERIZATION)
    c:RegisterEffect(e1)
    
    --Fusion Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.fustg)
    e2:SetOperation(s.fusop)
    c:RegisterEffect(e2)
    
    --Shuffle and Draw
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetTarget(s.tdtg)
    e3:SetOperation(s.tdop)
    c:RegisterEffect(e3)
end

--Fusion Summon
function s.fusfilter1(c,e)
    return not c:IsImmuneToEffect(e)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetFusionMaterial(tp)
        return Duel.IsExistingMatchingCard(aux.FConditionFilterFusionF,tp,LOCATION_EXTRA,0,1,nil,aux.FConditionFilterF,nil,e,tp,mg,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetFusionMaterial(tp):Filter(s.fusfilter1,nil,e)
    local sg1=Duel.GetMatchingGroup(aux.FilterBoolFunction(Card.IsCanBeFusionMaterial),tp,LOCATION_EXTRA,0,nil,mg)
    if #sg1>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg1:Select(tp,1,1,nil)
        local tc=tg:GetFirst()
        if tc then
            local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp)
            tc:SetMaterial(mat)
            Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
end

--Shuffle and Draw
function s.tdfilter(c)
    return c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg=g:Select(tp,1,#g,nil)
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
        local ct=#sg:Filter(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
        if ct>0 then
            local draw=Duel.Draw(tp,math.floor(ct/3),REASON_EFFECT)
            if draw>0 then
                Duel.BreakEffect()
            end
        end
    end
end
