-- Primite Realm
local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Normal Monsters and "Primite" monsters you control gain 500 ATK
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetTarget(function(e, c) return c:IsType(TYPE_NORMAL) or c:IsSetCard(SET_PRIMITE) end)
    e2:SetValue(500)
    c:RegisterEffect(e2)
    -- Search Normal Monsters or "Primite" cards
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    -- Fusion Summon
    local params = {
        fusfilter = s.fusfilter,
        matfilter = aux.FALSE,
        extrafil = s.extrafilter
    }
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1, {id, 1})
    e4:SetTarget(Fusion.SummonEffTG(params))
    e4:SetOperation(Fusion.SummonEffOP(params))
    c:RegisterEffect(e4)
    -- negate
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetCountLimit(1, {id, 2})
    e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCondition(s.ngcon)
    e5:SetTarget(s.ngtg)
    e5:SetOperation(s.ngop)
    c:RegisterEffect(e5)
    -- Set "Primite" Spell/Trap sent to GY
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 3))
    e6:SetCategory(CATEGORY_LEAVE_GRAVE)
    e6:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_TO_GRAVE)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCountLimit(1, {id, 3})
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCondition(s.setcon)
    e6:SetTarget(s.settg)
    e6:SetOperation(s.setop)
    c:RegisterEffect(e6)
end
s.listed_series={SET_PRIMITE}

function s.thfilter(c)
    return c:IsSetCard(SET_PRIMITE) and c:IsAbleToHand()
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

-- Fusion filter: only "Primite" Fusion Monsters
function s.fusfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(SET_PRIMITE)
end
-- Extra materials from Hand/Deck/Field only (no GY)
function s.extrafilter(e, tp, mg1)
	return Duel.GetMatchingGroup(
		Fusion.IsMonsterFilter(Card.IsAbleToGrave),
		tp,
		LOCATION_HAND + LOCATION_DECK + LOCATION_ONFIELD,
		0,
		nil
	)
end

function s.ngfilter(c)
    return c:IsFaceup() and c:IsMonster() and (c:IsSetCard(SET_PRIMITE) or c:IsType(TYPE_NORMAL))
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

function s.setcon(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(function(c) return c:IsSetCard(SET_PRIMITE) and c:IsSpellTrap() end, 1, nil)
end
function s.setfilter(c)
    return c:IsSetCard(SET_PRIMITE) and c:IsSpellTrap() and c:IsSSetable()
end
function s.settg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.setfilter), tp, LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, tp, LOCATION_GRAVE)
end
function s.setop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
    local sc=Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.setfilter), tp, LOCATION_GRAVE, 0, 1, 1, nil)
    local tc=sc:GetFirst()
    if tc and Duel.SSet(tp, tc)>0 then
        if tc:IsTrap() then
            -- It can be activated this turn
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,4))
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
            e1:SetReset(RESETS_STANDARD_PHASE_END)
            tc:RegisterEffect(e1)
        elseif tc:IsQuickPlaySpell() then
            -- It can be activated this turn
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetDescription(aux.Stringid(id,4))
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
            e1:SetReset(RESETS_STANDARD_PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
end