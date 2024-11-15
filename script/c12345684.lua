--Ultimate Counter
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==1-tp and Duel.IsChainNegatable(ev)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
    Duel.BreakEffect()
    if not c:IsRelateToEffect(e) then return end
    if c:IsSSetable(true) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
        Duel.BreakEffect()
        c:CancelToGrave()
        Duel.ChangePosition(c,POS_FACEDOWN)
        Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
    end
end