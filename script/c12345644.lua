--Xyz Free
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Optional detach replacement effect
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.rcon)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end

function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+ep)==0
		and (r&REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,500,REASON_EFFECT)
end