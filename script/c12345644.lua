-- Xyz Free
local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Attach opponent's deck cards
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_DETACH_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.condition)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    local rc = eg:GetFirst()
    return rc:IsControler(tp) and rc:IsType(TYPE_XYZ) and eg:IsContains(rc)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) > 0
    end
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local tc = eg:GetFirst()
    if Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) == 0 then
        return
    end
    local g = Duel.GetDecktopGroup(1 - tp, 2)
    if #g > 0 then
        Duel.Overlay(tc, g)
        Duel.Recover(tp, #g * 1000, REASON_EFFECT)
    end
end