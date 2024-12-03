-- Maiden In Love Protector
local s, id = GetID()
function s.initial_effect(c)
    -- Add 1 Equip Spell from your Deck to your hand
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

    -- While in GY, monsters your opponent controls with Maiden Counter must attack "Maiden In Love"
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.attackcon)
    e2:SetOperation(s.attackop)
    c:RegisterEffect(e2)

    -- While in GY, monsters your opponent controls with Maiden Counter cannot activate their effects
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTargetRange(0, LOCATION_MZONE) -- Applies to opponent's monsters
    e3:SetCondition(s.gycon) -- Only active while in GY
    e3:SetValue(s.aclimit)
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

function s.attackcon(e, tp, eg, ep, ev, re, r, rp)
    local tc = eg:GetFirst()
    -- Ensure tc is the attacking monster and it has the Maiden Counter
    return tc:IsControler(1 - tp) and tc:GetFlagEffect(100000139) > 0
end

function s.attackop(e, tp, eg, ep, ev, re, r, rp)
    local tc = eg:GetFirst()
    if tc and tc:IsControler(1 - tp) then
        -- Force the monster to attack Maiden In Love
        local g = Duel.GetMatchingGroup(Card.IsCode, tp, LOCATION_ONFIELD, 0, nil, 100000139)
        if #g > 0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACK)
            local tg = g:Select(tp, 1, 1, nil)
            Duel.ChangeAttackTarget(tg:GetFirst())
        end
    end
end

function s.gycon(e)
    return e:GetHandler():IsLocation(LOCATION_GRAVE)
end

function s.aclimit(e, re, tp)
    -- Check if the card activating the effect has Maiden Counter
    local rc = re:GetHandler()
    return rc:GetFlagEffect(100000139) > 0
end
