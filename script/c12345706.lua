-- Maiden In Love Garden of Eternal Love
local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate_maiden_counter)
    c:RegisterEffect(e1)

    -- Battle damage reduction
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Place Maiden Counter when opponent Summons, Flip Summons, or Special Summons a monster
    local events = {EVENT_SPSUMMON_SUCCESS, EVENT_FLIP_SUMMON_SUCCESS, EVENT_SUMMON_SUCCESS}
    for _, event in ipairs(events) do
        local e3 = Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e3:SetCode(event)
        e3:SetRange(LOCATION_FZONE)
        e3:SetCondition(s.maiden_counter_condition)
        e3:SetOperation(s.maiden_counter_operation)
        c:RegisterEffect(e3)
    end

    -- Take control of monsters with Maiden Counter (once per turn, quick effect)
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 0))
    e6:SetCategory(CATEGORY_CONTROL)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_FZONE)
    e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetHintTiming(0,TIMING_MAIN_END|TIMING_END_PHASE)
    e6:SetCountLimit(1)
    e6:SetCondition(s.control_condition)
    e6:SetTarget(s.control_target)
    e6:SetOperation(s.control_operation)
    c:RegisterEffect(e6)

    -- Send opponent's monster to GY and gain LP and summon a monster from opponent's GY or banished zone to your side of the field
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 1))
    e7:SetCategory(CATEGORY_TOGRAVE + CATEGORY_RECOVER + CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_IGNITION)
    e7:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCondition(s.lp_gain_condition)
    e7:SetTarget(s.lp_gain_target)
    e7:SetOperation(s.lp_gain_operation)
    c:RegisterEffect(e7)

    -- Boost ATK of "Maiden In Love" each time you take control of a monster
    local e8 = Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_QUICK_F)
    e8:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e8:SetCode(EVENT_CONTROL_CHANGED)
    e8:SetRange(LOCATION_FZONE)
    e8:SetCondition(s.atk_boost_condition)
    e8:SetOperation(s.atk_boost_operation)
    c:RegisterEffect(e8)
    local e9 = e8:Clone()
    e9:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e9)
end
s.listed_names = {100000139}
s.counter_place_list = {0x1090, 0x90}

-- Operation to place Maiden Counter on opponent's monsters
function s.activate_maiden_counter(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        tc:AddCounter(0x1090, 1)
    end
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

-- Filter to identify monsters with Maiden Counter
function s.control_filter(c)
    return c:IsFaceup() and c:GetCounter(0x1090) > 0
end

-- Condition: Check if there is an open Monster Zone
function s.control_condition(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

-- Target for taking control of monsters with Maiden Counter
function s.control_target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.control_filter, 1 - tp, LOCATION_MZONE, 0, 1, nil)
    end
    local g = Duel.SelectMatchingCard(tp, s.control_filter, 1 - tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetTargetCard(g)
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

function s.opponent_extra_deck_check(tp)
    local g = Duel.GetFieldGroup(tp, 0, LOCATION_EXTRA)
    if #g > 0 then
        Duel.ConfirmCards(1 - tp, g)
    end
end

-- Operation to send monster to GY, gain LP, and summon a monster from opponent's GY or banishment
function s.lp_gain_operation(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local atk_or_def = math.max(tc:GetAttack(), tc:GetDefense())
        Duel.SendtoGrave(tc, REASON_EFFECT)
        Duel.Recover(tp, atk_or_def, REASON_EFFECT)
        
        -- Look at the opponent's Deck and Extra Deck before selecting a target
        s.opponent_extra_deck_check(tp)
        -- Summon 1 monster from opponent's GY or banished zone
        local g = Duel.GetMatchingGroup(Card.IsCanBeSpecialSummoned, tp, 0, LOCATION_GRAVE + LOCATION_REMOVED + LOCATION_EXTRA, nil, e, SUMMON_TYPE_SPECIAL, tp, true, false)
        g = g:Filter(Card.IsMonster, nil)
        if #g > 0 then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local sg = g:Select(tp, 1, 1, nil)
            local summon_type = 0
            if sg:GetFirst():IsType(TYPE_FUSION) then
                summon_type = SUMMON_TYPE_FUSION
            elseif sg:GetFirst():IsType(TYPE_SYNCHRO) then
                summon_type = SUMMON_TYPE_SYNCHRO
            elseif sg:GetFirst():IsType(TYPE_XYZ) then
                summon_type = SUMMON_TYPE_XYZ
            elseif sg:GetFirst():IsType(TYPE_LINK) then
                summon_type = SUMMON_TYPE_LINK
            end
            Duel.SpecialSummon(sg, summon_type, tp, tp, true, false, POS_FACEUP)
            sg:GetFirst():CompleteProcedure()
        end
    end
end

-- Filter for "Maiden In Love"
function s.maiden_in_love_filter(c)
    return c:IsFaceup() and c:IsCode(100000139)
end

-- ATK Boost condition: check if a monster was taken control of by you
function s.atk_boost_condition(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(Card.IsControler, 1, nil, tp)
end

-- ATK Boost operation: boost ATK of "Maiden In Love" by the ATK of the controlled monster
function s.atk_boost_operation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectMatchingCard(tp, s.maiden_in_love_filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    local tc = g:GetFirst()
    if tc then
        local tg = eg:Filter(Card.IsControler, nil, tp):GetFirst()
        if tg then
            local atk = tg:GetAttack()
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end