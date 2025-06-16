-- Dual Avatar Fusion Realm
local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    -- Fusion Summon
    local params = {
        fusfilter = s.fusfilter,
        matfilter = aux.FALSE,
        extrafil = s.extrafil,
        stage2 = s.stage2,
        extratg = s.extratg
    }
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(Fusion.SummonEffTG(params))
    e2:SetOperation(Fusion.SummonEffOP(params))
    c:RegisterEffect(e2)
    -- Add "Dual Avatar" monster to hand
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    -- negate
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetCountLimit(1, {id, 2})
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.ngcon)
    e4:SetTarget(s.ngtg)
    e4:SetOperation(s.ngop)
    c:RegisterEffect(e4)
    -- Special Summon from GY
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCountLimit(1, {id, 3})
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
end
s.listed_series = {SET_DUAL_AVATAR}
-- Fusion filter: only “Dual Avatar” Fusion Monsters
function s.fusfilter(c)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_DUAL_AVATAR)
end

-- Extra‐materials: Hand/Deck/Extra/Field → GY  OR  GY → shuffle (flagged)
function s.extrafil(e, tp, mg1)
    -- (a) monsters from Hand/Deck/Extra/Field that can be sent to GY
    local g1 = Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave), tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_MZONE, 0, nil)
    -- (b) "Dual Avatar" monsters in GY that can be shuffled into the Deck
    local g2 = Duel.GetMatchingGroup(s.shufflefilter, tp, LOCATION_GRAVE, 0, nil)
    for sc in aux.Next(g2) do
        sc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)
    end
    g2:KeepAlive()

    -- allow mixing any combination
    aux.FCheckAdditional = aux.FCheckMix or function()
        return true
    end
    aux.GCheckAdditional = aux.GCheckMix or function()
        return true
    end

    return g1:Merge(g2)
end

-- “Dual Avatar” monsters in GY that can be shuffled
function s.shufflefilter(c)
    return c:IsSetCard(SET_DUAL_AVATAR) and c:IsMonster() and c:IsAbleToDeck()
end

-- After selecting materials: only shuffle those that were flagged (originated in GY)
function s.stage2(e, tc, tp, sg, chk)
    if chk == 1 then
        local todeck = sg:Filter(function(c)
            return c:GetFlagEffect(id) > 0
        end, nil)
        if #todeck > 0 then
            Duel.SendtoDeck(todeck, nil, SEQ_DECKSHUFFLE, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
        end
    end
end

-- Declare zones: will send some to GY and shuffle some from GY → Deck
function s.extratg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 0, tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 0, tp, LOCATION_GRAVE)
end

function s.thfilter(c)
    return (c:IsSetCard(SET_DUAL_AVATAR) or c:ListsArchetype(SET_DUAL_AVATAR)) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_GRAVE + LOCATION_DECK, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE + LOCATION_DECK)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then
        return
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_GRAVE + LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.ngfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_DUAL_AVATAR) and c:IsMonster()
end
function s.ngcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.ngfilter, tp, LOCATION_MZONE, 0, 1, nil) and rp ~= tp and
               not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.ngtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end
function s.ngop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg, REASON_EFFECT)
    end
end

function s.spfilter(c, e, tp)
    return c:IsSetCard(SET_DUAL_AVATAR) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc, e, tp)
    end
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, tp, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
    end
end
