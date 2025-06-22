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
        extrafil = s.extrafilter
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
    -- Fusion Summon using materials from GY or banishment
    local params = {
        fusfilter = aux.FilterBoolFunction(Card.IsSetCard, SET_DUAL_AVATAR),
        matfilter = aux.FALSE,
        extrafil = s.fextra,
        extraop = Fusion.ShuffleMaterial,
        extratg = s.extratarget
    }
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetTarget(Fusion.SummonEffTG(params))
    e3:SetOperation(Fusion.SummonEffOP(params))
    c:RegisterEffect(e3)
    -- Add "Dual Avatar" monster to hand
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1, {id, 2})
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
    -- negate
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetCountLimit(1, {id, 3})
    e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCondition(s.ngcon)
    e5:SetTarget(s.ngtg)
    e5:SetOperation(s.ngop)
    c:RegisterEffect(e5)
    -- Special Summon from GY
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 4))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e6:SetRange(LOCATION_SZONE)
    e6:SetCountLimit(1, {id, 4})
    e6:SetTarget(s.sptg)
    e6:SetOperation(s.spop)
    c:RegisterEffect(e6)
end
s.listed_series = {SET_DUAL_AVATAR}

-- Fusion filter: only “Ojama” Fusion Monsters
function s.fusfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_DUAL_AVATAR)
end
-- Extra materials from Hand/Deck/Extra/Field only (no GY)
function s.extrafilter(e, tp, mg1)
	return Duel.GetMatchingGroup(
		Fusion.IsMonsterFilter(Card.IsAbleToGrave),
		tp,
		LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_MZONE,
		0,
		nil
	)
end

function s.fextra(e, tp, mg)
    return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.NecroValleyFilter(Card.IsFaceup, Card.IsAbleToDeck)), tp,
        LOCATION_GRAVE | LOCATION_REMOVED, 0, nil)
end
function s.extratarget(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 0, tp, LOCATION_GRAVE | LOCATION_REMOVED)
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
