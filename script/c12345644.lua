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

    -- Attach top card of opponent's deck as material
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.matcon)
    e3:SetOperation(s.matop)
    c:RegisterEffect(e3)

end

function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+ep)==0
		and (r&REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,500,REASON_EFFECT)
end

function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc:IsControler(tp) and rc:IsType(TYPE_XYZ) and re:IsActivated()
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if rc:IsRelateToEffect(re) then
        local g=Duel.GetDecktopGroup(1-tp,1)
        if #g>0 then
            Duel.DisableShuffleCheck()
            Duel.Overlay(rc,g)
        end
    end
end