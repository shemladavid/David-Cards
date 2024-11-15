--Venom Swamp Max
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Add counter at end phase
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetCountLimit(1)
    e2:SetRange(LOCATION_FZONE)
    e2:SetOperation(s.acop)
    c:RegisterEffect(e2)
    --Destroy monster with 0 ATK when it has a Venom Counter
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.descon)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
    --ATK down for non-Venom monsters
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e4:SetTarget(function(e,c) return not c:IsSetCard(0x50) end)
    e4:SetValue(s.atkval)
    c:RegisterEffect(e4)
    --Increase ATK per Venom counter for Venom monsters
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_UPDATE_ATTACK)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e5:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x50))
    e5:SetValue(s.value)
    c:RegisterEffect(e5)
    --Increase DEF per Venom counter for Venom monsters
    local e6=e5:Clone()
    e6:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e6)
    --Add to hand
    local e7=Effect.CreateEffect(c)
    e7:SetCategory(CATEGORY_TOHAND)
    e7:SetType(EFFECT_TYPE_IGNITION)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCountLimit(1)
    e7:SetTarget(s.thtg)
    e7:SetOperation(s.thop)
    c:RegisterEffect(e7)
    -- Place venom counters
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e8:SetCode(EVENT_SPSUMMON_SUCCESS)
    e8:SetRange(LOCATION_FZONE)
    e8:SetOperation(s.placeCounters)
    c:RegisterEffect(e8)
    local e9=e8:Clone()
	e9:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e9)
	local e10=e9:Clone()
	e10:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e10)
end
s.listed_series={0x50}
s.counter_place_list={0x1009}
function s.atkval(e,c)
    return c:GetCounter(0x1009)*-500
end
function s.acop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local tg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
    for tc in aux.Next(tg) do
        if tc:IsCanAddCounter(0x1009,1) then
            tc:AddCounter(0x1009,1)
        end
    end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(function(c) return c:GetAttack()==0 and c:GetCounter(0x1009)>0 end, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(function(c) return c:GetAttack()==0 and c:GetCounter(0x1009)>0 end, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    Duel.Destroy(g,REASON_EFFECT)
end
function s.value(e,c)
    return Duel.GetCounter(0,1,1,0x1009)*200
end
function s.thfilter(c)
    return c:IsSetCard(0x50) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.placeCounters(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        if tc:IsType(TYPE_MONSTER) then
            local count=tc:GetLevel()+tc:GetRank()+tc:GetLink()
            tc:AddCounter(0x1009,count) -- Use the venom counter ID
        end
        tc = eg:GetNext()
    end
end