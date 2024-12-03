-- Maiden In Love Garden of Eternal Love
local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Battle damage reduction
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(s.condition)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)

    -- Place Maiden Counter when opponent summons, flips, or special summons a monster
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.maiden_counter_condition)
    e3:SetOperation(s.maiden_counter_operation)
    c:RegisterEffect(e3)

    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.maiden_counter_condition)
    e4:SetOperation(s.maiden_counter_operation)
    c:RegisterEffect(e4)

    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCondition(s.maiden_counter_condition)
    e5:SetOperation(s.maiden_counter_operation)
    c:RegisterEffect(e5)

    -- Take control of monsters with Maiden Counter (once per turn, quick effect)
    local e6 = Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_CONTROL)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_FZONE)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e6:SetCountLimit(1)
    e6:SetTarget(s.control_target)
    e6:SetOperation(s.control_operation)
    c:RegisterEffect(e6)

    local e7 = Effect.CreateEffect(c)
    e7:SetCategory(CATEGORY_TOGRAVE + CATEGORY_RECOVER + CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_IGNITION)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCountLimit(1)
    e7:SetCondition(s.lp_gain_condition)
    e7:SetTarget(s.lp_gain_target)
    e7:SetOperation(s.lp_gain_operation)
    c:RegisterEffect(e7)
end
s.listed_names = {100000139}
s.counter_place_list = {0x1090}
-- Condition for Battle damage reduction
function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetBattleDamage(tp) > 0
end

-- Operation for Battle damage reduction
function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    e1:SetOperation(s.damop)
    e1:SetReset(RESET_PHASE + PHASE_DAMAGE)
    Duel.RegisterEffect(e1, tp)
end

-- Damage reduction operation (reduce damage to 10%)
function s.damop(e, tp, eg, ep, ev, re, r, rp)
    Duel.ChangeBattleDamage(tp, ev / 10)
end

-- Condition for Maiden Counter (when an opponent's monster is summoned, flipped, or special summoned)
function s.maiden_counter_condition(e, tp, eg, ep, ev, re, r, rp)
    local c = eg:GetFirst()
    return c:IsControler(1 - tp) and c:IsFaceup()
end

-- Operation to place Maiden Counter
function s.maiden_counter_operation(e, tp, eg, ep, ev, re, r, rp)
    local c = eg:GetFirst()
    if c:IsControler(1 - tp) then
        c:AddCounter(0x1090, 1) -- 0x1090 represents Maiden Counter
    end
end

-- Condition to control monsters with Maiden Counter
function s.control_condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.maiden_counter_filter, tp, LOCATION_MZONE, 0, 1, nil) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

-- Filter to identify monsters with Maiden Counter
function s.maiden_counter_filter(c)
    return c:IsFaceup() and c:GetCounter(0x1090) > 0
end

-- Target for taking control of monsters with Maiden Counter
function s.control_target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.control_filter, 1 - tp, LOCATION_MZONE, 0, 1, nil)
    end
    local g = Duel.SelectMatchingCard(tp, s.control_filter, 1 - tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetTargetCard(g)
end

-- Filter to identify monsters with Maiden Counter
function s.control_filter(c)
    return c:IsFaceup() and c:GetCounter(0x1090) > 0
end

-- Operation to take control of the selected monster (once per turn, quick effect)
function s.control_operation(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_CONTROL)
        e1:SetValue(tp)
        tc:RegisterEffect(e1)
    end
end
-- Condition to send a monster that was originally owned by your opponent
function s.lp_gain_condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.lp_gain_filter, tp, LOCATION_MZONE, 0, 1, nil)
end

-- Filter for a monster that was originally owned by your opponent
function s.lp_gain_filter(c, tp)
    return c:IsMonster() and c:GetControler() ~= c:GetOwner()
end

-- Target for sending opponent's monster to GY and gain LP
function s.lp_gain_target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.lp_gain_filter, tp, LOCATION_MZONE, 0, 1, nil)
    end
    local g = Duel.SelectMatchingCard(tp, s.lp_gain_filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    if g:GetCount() == 0 then
        return
    end
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, 1, 0, 0)

    local atk_or_def = math.max(g:GetFirst():GetAttack(), g:GetFirst():GetDefense())
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, tp, atk_or_def, 0, 0)
end

-- Operation to send monster to GY, gain LP, and summon a monster from opponent's GY or banishment
function s.lp_gain_operation(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local atk_or_def = math.max(tc:GetAttack(), tc:GetDefense())
        Duel.SendtoGrave(tc, REASON_EFFECT)
        Duel.Recover(tp, atk_or_def, REASON_EFFECT)

        -- Summon 1 monster from opponent's GY or banished zone
        local g = Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_GRAVE + LOCATION_REMOVED, nil, e,
            SUMMON_TYPE_SPECIAL, 1 - tp, false, false)

        if #g > 0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local sg = g:Select(tp, 1, 1, nil)
            Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end
