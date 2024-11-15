-- Crystal Amethyst Nail
local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)

    -- Double ATK
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)

    -- Negate opponent's monster effect permanently
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetOperation(s.negateEffect)
    c:RegisterEffect(e3)

    -- Destroy and Search
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_BATTLE_DAMAGE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.thcon)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)
end
s.listed_series = {0x34, 0x1034}

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    local tc = Duel.GetAttacker()
    if tc:IsControler(1 - tp) then tc = Duel.GetAttackTarget() end
    e:SetLabelObject(tc)
    return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsSetCard(0x1034)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    if tc:IsRelateToBattle() and tc:IsFaceup() then
        local atk = tc:GetAttack()
        local def = tc:GetDefense()

        -- Double ATK and DEF
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(atk * 2)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_DAMAGE_CAL)
        tc:RegisterEffect(e1)
        
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
        e2:SetValue(def * 2)
        tc:RegisterEffect(e2)
    end
end

function s.negateEffect(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetAttacker()
    if tc:IsControler(1 - tp) then tc = Duel.GetAttackTarget() end
    if tc and tc:IsRelateToBattle() then
        local bc = tc:GetBattleTarget()
        if bc and bc:IsControler(1 - tp) then
            -- Negate the opponent's monster effect permanently
            local e1 = Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT + RESETS_STANDARD)
            bc:RegisterEffect(e1, true)
            local e2 = Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT + RESETS_STANDARD)
            bc:RegisterEffect(e2, true)
            local e3 = Effect.CreateEffect(e:GetHandler())
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_DISABLE)
            e3:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
            bc:RegisterEffect(e3, true)
            local e4 = Effect.CreateEffect(e:GetHandler())
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetCode(EFFECT_DISABLE_EFFECT)
            e4:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
            bc:RegisterEffect(e4, true)
        end
    end
end

function s.thcon(e, tp, eg, ep, ev, re, r, rp)
    local tc = eg:GetFirst()
    return ep ~= tp and tc:IsControler(tp) and tc:IsSetCard(0x1034) and Duel.IsExistingMatchingCard(s.amethystfilter, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.thfilter(c)
    return c:IsSetCard(0x34) and c:IsAbleToHand()
end

function s.amethystfilter(c)
    return c:IsFaceup() and (c:IsCode(32933942) or c:IsCode(19963185))
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, 0)
    Duel.SetChainLimit(aux.FALSE)
end

function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    if #g > 0 then
        Duel.HintSelection(g)
        Duel.Destroy(g, REASON_EFFECT)
        local bSearch = Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, nil)
        if bSearch and Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
            local sg = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK+LOCATION_GRAVE, 0, 1, 1, nil)
            if #sg > 0 then
                Duel.SendtoHand(sg, nil, REASON_EFFECT)
                Duel.ConfirmCards(1 - tp, sg)
            end
        end
    end
end
