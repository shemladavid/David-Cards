--Infernal Realm
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    --Effect damage becomes 2000
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_DAMAGE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(0,1) -- Opponent only
    e2:SetValue(s.damval)
    c:RegisterEffect(e2)
    
    --Cannot be destroyed by card effects
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    --Unaffected by other card effects
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetValue(s.immval)
    c:RegisterEffect(e4)

    --Special Summon 3 Level 1 monsters and then destroy all monsters on the field
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
    
    --Cards in your Graveyard are unaffected by your opponent's card effects
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_IMMUNE_EFFECT)
    e6:SetRange(LOCATION_FZONE)
    e6:SetTargetRange(LOCATION_GRAVE,0)
    e6:SetTarget(s.immtg)
    e6:SetValue(s.immval_grave)
    c:RegisterEffect(e6)
end

function s.damval(e,re,val,r,rp,rc)
    if bit.band(r,REASON_EFFECT)~=0 then
        return 2000
    else
        return val
    end
end

function s.immval(e,te)
    return te:GetOwner()~=e:GetOwner()
end

function s.spfilter(c,e,tp)
    return c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>2
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,3,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_MZONE+LOCATION_SZONE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
    if #g>=3 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,3,3,nil)
        Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        Duel.BreakEffect()
        Duel.Destroy(Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE+LOCATION_SZONE,LOCATION_MZONE+LOCATION_SZONE,nil),REASON_EFFECT)
    end
end

function s.effectfilter(e,ct)
    local te=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
    local tc=te:GetHandler()
    return tc and tc:IsLocation(LOCATION_GRAVE) and tc:IsControler(e:GetHandlerPlayer())
end

function s.immtg(e,c)
    return c:IsLocation(LOCATION_GRAVE) and c:IsControler(e:GetHandlerPlayer())
end

function s.immval_grave(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end