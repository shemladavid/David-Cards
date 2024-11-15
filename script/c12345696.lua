--Ultimate Bamboo Sword
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    --Cannot be targeted
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    --Skip opponent's Main Phase 1
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetCode(EFFECT_SKIP_M1)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(0,1)
    c:RegisterEffect(e3)

    --Direct attack
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCode(EFFECT_DIRECT_ATTACK)
    e4:SetTargetRange(LOCATION_MZONE,0)
    c:RegisterEffect(e4)

    --Skip Draw Phase and destroy opponent's cards
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
    e5:SetCategory(CATEGORY_DESTROY)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCode(EVENT_BATTLE_DAMAGE)
    e5:SetCondition(s.damcon)
    e5:SetTarget(s.damtg)
    e5:SetOperation(s.damop)
    c:RegisterEffect(e5)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==1-tp
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    -- Skip opponent's Draw Phase
    local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
    
    local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD+LOCATION_HAND)
    if #g>0 then   
        if Duel.SelectYesNo(tp,aux.Stringid(id, 0)) then
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end