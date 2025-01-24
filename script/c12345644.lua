--Xyz Free
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Attach cards from opponent's deck when materials are detached
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DETACH_MATERIAL)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.matcon)
    e2:SetTarget(s.mattg)
    e2:SetOperation(s.matop)
    c:RegisterEffect(e2)
end

function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=eg:GetFirst()
    return rc:IsControler(tp) and rc:IsType(TYPE_XYZ) and eg:IsContains(rc)
end

function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local rc=eg:GetFirst()
    local g=Duel.GetDecktopGroup(1-tp,1)
    Duel.SetOperationInfo(0,CATEGORY_ATTACH,g,1,1-tp,LOCATION_DECK)
end

function s.matop(e,tp,eg,ep,ev,re,r,rp)
    local rc=eg:GetFirst()
    if rc:IsRelateToEffect(re) then
        local g=Duel.GetDecktopGroup(1-tp,1)
        local ct=0
        while #g>0 do
            Duel.DisableShuffleCheck()
            Duel.Overlay(rc,g)
            ct=ct+1
            g=Duel.GetDecktopGroup(1-tp,1)
        end
        if ct>0 then
            Duel.Recover(tp,1000*ct,REASON_EFFECT)
        end
    end
end
