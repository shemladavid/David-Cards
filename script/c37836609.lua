-- Envy of Drudomancer
local s,id=GetID()
function s.initial_effect(c)
    -- Negate effects and take control of monster
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.negctg)
    e1:SetOperation(s.negcop)
    c:RegisterEffect(e1)

    -- Set and return Illusion monster to hand
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,{id,1})
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

-- Negate effect and take control if Drudomancer revealed
function s.thfilter(c)
    return c:IsSetCard(0x317d) and c:IsType(TYPE_MONSTER)
end
function s.negctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsControler(1-tp) and chkc:IsSummonType(SUMMON_TYPE_SPECIAL) end
    if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSummonType,SUMMON_TYPE_SPECIAL),tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
    local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSummonType,SUMMON_TYPE_SPECIAL),tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,g,1,0,0)
    if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND,0,1,nil) and
       Duel.IsExistingMatchingCard(Card.isPublic,tp,LOCATION_HAND,0,1,nil) then
        Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
    end
end

function s.negcop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsSummonType(SUMMON_TYPE_SPECIAL) then
        -- Negate its effects
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)

        -- Take control if Drudomancer monster is revealed
        if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND,0,1,nil) and
           Duel.IsExistingMatchingCard(Card.isPublic,tp,LOCATION_HAND,0,1,nil) then
            Duel.GetControl(tc,tp,PHASE_END,1)
        end
    end
end


-- Set card from GY and return Illusion monster
function s.illusionfilter(c)
    return c:IsRace(RACE_ILLUSION) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.illusionfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSSetable() then
        Duel.SSet(tp,c)
        local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)

        -- Select and return a monster from the GY to the hand
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,1,nil)
        if #tg>0 then
            Duel.SendtoHand(tg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tg)
        end
    end
end