-- Drudomancer Eulogy
local s,id=GetID()
function s.initial_effect(c)
    -- Destroy target Spell/Trap or monster (if Drudomancer revealed)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_EQUIP+TIMING_MAIN_END+TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.destrtg)
    e1:SetOperation(s.destrop)
    c:RegisterEffect(e1)

    -- Set and shuffle Illusion monsters
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

-- Destroy Spell/Trap or target monster (if Drudomancer revealed)
function s.destrfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.monsterfilter(c)
    return c:IsType(TYPE_MONSTER)
end
function s.thfilter(c)
    return c:IsSetCard(0x317d) and c:IsType(TYPE_MONSTER)
end
function s.destrtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        local res=Duel.IsExistingTarget(s.destrfilter,tp,0,LOCATION_SZONE,1,nil)
        if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND,0,1,nil) and
           Duel.IsExistingMatchingCard(Card.isPublic,tp,LOCATION_HAND,0,1,nil) then
            res=Duel.IsExistingTarget(s.destrfilter,tp,0,LOCATION_SZONE,1,nil) or
                 Duel.IsExistingTarget(s.monsterfilter,tp,0,LOCATION_MZONE,1,nil)
        end
        return res
    end
    local g=nil
    if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND,0,1,nil) and
       Duel.IsExistingMatchingCard(Card.isPublic,tp,LOCATION_HAND,0,1,nil) then
        g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_SZONE+LOCATION_MZONE,1,1,nil)
    else
        g=Duel.SelectTarget(tp,s.destrfilter,tp,0,LOCATION_SZONE,1,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.destrop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetFirstTarget()
    if tg:IsRelateToEffect(e) then
        Duel.Destroy(tg,REASON_EFFECT)
    end
end

-- Set and shuffle Illusion monsters
function s.illusionfilter(c)
    return c:IsSetCard(0x317d) and c:IsType(TYPE_MONSTER)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.illusionfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.illusionfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end