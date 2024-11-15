-- Sacred Beasts Calling
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon up to 5 copies of the specified monsters
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end
s.listed_names={6007213,32491822,69890967}

function s.spfilter(c,e,tp)
    return c:IsCode(6007213,32491822,69890967) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) 
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        local max_targets=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),5)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,max_targets,nil,e,tp)
        if #g>0 then
            for tc in aux.Next(g) do
                Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP_ATTACK)
                tc:CompleteProcedure()
            end
            Duel.SpecialSummonComplete()
        end
    end
end
