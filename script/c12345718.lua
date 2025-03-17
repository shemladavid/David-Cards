-- Continuous Spell: "Universal Race & Attribute" Spell
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    -- Reattach detached Xyz materials (e5)
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e5:SetCode(EVENT_DETACH_MATERIAL)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCondition(s.attachback_condition)
    e5:SetOperation(s.attachback_operation)
    c:RegisterEffect(e5)
end
function s.attachback_condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler,1,nil,tp) and eg:IsExists(Card.IsType,1,nil,TYPE_XYZ)
end
function s.attachback_operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        if tc:IsType(TYPE_XYZ) then
            local mg=tc:GetOverlayGroup()
            if #mg>0 then
                Duel.Overlay(e:GetHandler(),mg)
            end
        end
        tc=eg:GetNext()
    end
end