--Sacred Beasts Ultimate Control
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_names={6007213,32491822,69890967}

-- Check if the conditions for activation are met
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Check if the opponent is activating a card or effect
    if ep~=tp then
        -- Check if you control "Uria, Lord of Searing Flames", "Hamon, Lord of Striking Thunder", or "Raviel, Lord of Phantasms"
        local tc1 = Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 6007213), tp, LOCATION_ONFIELD, 0, 1, nil) -- Uria
        local tc2 = Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 32491822), tp, LOCATION_ONFIELD, 0, 1, nil) -- Hamon
        local tc3 = Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 69890967), tp, LOCATION_ONFIELD, 0, 1, nil) -- Raviel
        return (tc1 or tc2 or tc3) and Duel.IsChainNegatable(ev)
    end
    return false
end

-- Target the card and set the operations
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsChainNegatable(ev) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-- Execute the operations based on the number of different Lords controlled
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not Duel.NegateActivation(ev) then return end

    local tc1= Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 6007213), tp, LOCATION_ONFIELD, 0, 1, nil) -- Uria
    local tc2= Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 32491822), tp, LOCATION_ONFIELD, 0, 1, nil) -- Hamon
    local tc3= Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 69890967), tp, LOCATION_ONFIELD, 0, 1, nil) -- Raviel

    local count=0
    if tc1 then count = count + 1 end
    if tc2 then count = count + 1 end
    if tc3 then count = count + 1 end

    local c=e:GetHandler()

    -- Destroy the card if there are 2 or more different Lords
    if count >= 2 then
        Duel.Destroy(eg, REASON_EFFECT)
    end

    -- Handle this card if there are 3 different Lords
    if count >= 3 then
        if c:IsRelateToEffect(e) then
            c:CancelToGrave()
            Duel.ChangePosition(c, POS_FACEDOWN)
            Duel.RaiseEvent(c, EVENT_SSET, e, REASON_EFFECT, tp, tp, 0)
        end
    end
end