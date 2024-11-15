local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Treat all monsters as Xyz monsters
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_ADD_TYPE)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.xyztg)
    e2:SetValue(TYPE_XYZ)
    c:RegisterEffect(e2)

    -- Assign rank to all monsters
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_XYZ_LEVEL)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(s.xyztg)
    e3:SetValue(s.rankval)
    c:RegisterEffect(e3)

    -- Increase rank of your Xyz monsters by 3 during each of your Standby Phases
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetOperation(s.rankupop)
    c:RegisterEffect(e4)
end

function s.xyztg(e,c)
    return c:IsType(TYPE_MONSTER)
end

function s.rankval(e,c,rc)
    if c:IsType(TYPE_LINK) then
        return 0
    else
        return c:GetLevel()
    end
end

function s.rankupop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_XYZ)
    local tc=g:GetFirst()
    while tc do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_RANK)
        e1:SetValue(3)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        tc=g:GetNext()
    end
end