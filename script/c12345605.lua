--Majespecter Realm
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    --All Majespecter monsters gain 500 ATK
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.atktg)
    e2:SetValue(500)
    c:RegisterEffect(e2)

    --All monsters become WIND Spellcaster-Type
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetValue(ATTRIBUTE_WIND)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_CHANGE_RACE)
    e4:SetValue(RACE_SPELLCASTER)
    c:RegisterEffect(e4)
    
    --Tribute opponent's WIND Spellcaster instead
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_EXTRA_RELEASE)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e5:SetTarget(s.reltg)
    e5:SetValue(POS_FACEUP)
    c:RegisterEffect(e5)
    
    --Return WIND Spellcaster to hand, Special Summon 1 Majespecter
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,0))
    e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_FZONE)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e6:SetCountLimit(1,id)
    e6:SetTarget(s.sptg)
    e6:SetOperation(s.spop)
    c:RegisterEffect(e6)
    
    -- Set Majespecter Spell/Trap from GY or Banished during opponent's End Phase
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,1))
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_PHASE+PHASE_END)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCountLimit(1,id+1)
    e7:SetCondition(s.setcon)
    e7:SetTarget(s.settg)
    e7:SetOperation(s.setop)
    c:RegisterEffect(e7)
end

function s.atktg(e,c)
    return c:IsSetCard(0xd0)
end

function s.reltg(e,c)
    return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_SPELLCASTER)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Ensure there is a WIND monster to return and a Majespecter to summon
        return Duel.IsExistingMatchingCard(Auxiliary.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WIND),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,Auxiliary.FaceupFilter(Card.IsAttribute,ATTRIBUTE_WIND),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
        if #sg>0 then
            Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

function s.spfilter(c,e,tp)
    -- Filter to ensure that it is a valid Majespecter for Special Summon
    return c:IsSetCard(0xd0) and (c:IsLocation(LOCATION_DECK) or c:IsFaceup()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=tp -- Check if it's the opponent's turn
end

-- Target: Up to the number of available spaces in the Spell/Trap Zone
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,ct,nil)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetTargetCards(e)
    if #tg>0 then
        Duel.SSet(tp,tg)
    end
end

function s.setfilter(c)
    return c:IsSetCard(0xd0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and (c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) or c:IsFaceup())
end
