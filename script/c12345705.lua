-- Maiden In Love Protector
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

    -- While in GY, cards you control cannot be targeted by your opponent's card effects
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetCondition(s.gycon)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- While in GY, monsters your opponent controls with Maiden Counter have their effects negated
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DISABLE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCondition(s.gycon)
    e3:SetTarget(s.disableTarget)
    c:RegisterEffect(e3)

    -- While in GY, cards in your GY cannot be banished
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
    e4:SetCondition(s.gycon)
	c:RegisterEffect(e4)
end
s.listed_names = {100443001}
function s.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():IsDiscardable()
    end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST + REASON_DISCARD)
end

function s.thfilter(c)
    return (c:IsCode(100443001) or c:ListsCode(100443001)) and c:IsAbleToHand()
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

function s.gycon(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 100443001), e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
end

function s.disableTarget(e,c)
    return c:IsType(TYPE_MONSTER) and c:IsFaceup() and (c:GetCounter(0X1090)>0 or c:GetCounter(0x90)>0)
end