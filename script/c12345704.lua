-- Maiden In Love Guardian
local s, id = GetID()
function s.initial_effect(c)
    -- Add 1 "Maiden In Love" and 1 card that mentions it
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SEARCH + CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Take no effect damage
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CHANGE_DAMAGE)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetTargetRange(1, 0)
    e2:SetCondition(s.dmgcon)
    e2:SetValue(s.damval)
    c:RegisterEffect(e2)
    local e2a = e2:Clone()
    e2a:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e2a)

    -- Negate activation
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
end
s.listed_names = {100000139}
function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():IsDiscardable()
    end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST + REASON_DISCARD)
end
function s.thfilter(c)
    return (c:IsType(TYPE_EQUIP) or c:IsCode(100000139) or c:ListsCode(100000139)) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.dmgcon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 100000139), e:GetHandlerPlayer(), LOCATION_ONFIELD,
        0, 1, nil)
end

function s.damval(e, re, val, r, rp, rc)
    if r & REASON_EFFECT ~= 0 then
        return 0
    end
    return val
end

function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    return rp ~= tp and
               Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 100000139), tp, LOCATION_ONFIELD, 0, 1, nil) and
               Duel.IsChainNegatable(ev)
end
function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
end