-- Adamancipator Risen - Holynite
local s,id=GetID()
function s.initial_effect(c)
    -- Synchro Summon
    c:EnableReviveLimit()
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)

    -- Excavation effect (Ignition Effect)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.excavate_cost)
    e1:SetTarget(s.excavate_target)
    e1:SetOperation(s.excavate_operation)
    c:RegisterEffect(e1)

    -- Negate Summon effect
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_SPSUMMON)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.negate_summon_condition)
    e2:SetCost(s.negate_summon_cost)
    e2:SetTarget(s.negate_summon_target)
    e2:SetOperation(s.negate_summon_operation)
    c:RegisterEffect(e2)

    -- Negate Effect
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.negate_effect_condition)
    e3:SetCost(s.negate_effect_cost)
    e3:SetTarget(s.negate_effect_target)
    e3:SetOperation(s.negate_effect_operation)
    c:RegisterEffect(e3)
end

-- Excavation effect functions
function s.excavate_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    -- No specific cost for this effect
end

function s.excavate_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    e:SetLabel(0)
end

function s.excavate_operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<5 then return end
    Duel.ConfirmDecktop(tp,5)
    local g=Duel.GetDecktopGroup(tp,5)
    local rg=g:Filter(Card.IsSetCard, nil, 0x140)
    local count=rg:GetCount()
    if count>0 then
        e:GetHandler():AddCounter(0x1036,count) -- Change the counter type if necessary
    end
    Duel.MoveToDeckBottom(5,tp)
    Duel.SortDeckbottom(tp,tp,5)
end

-- Negate Summon effect functions
function s.negate_summon_condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(0x1036)>0 and tp~=ep and Duel.GetCurrentChain()==0
end

function s.negate_summon_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1036,1,REASON_COST) end
    Duel.RemoveCounter(tp,1,1,0x1036,1,REASON_COST)
end

function s.negate_summon_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
end

function s.negate_summon_operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateSummon(eg)
    Duel.Destroy(eg,REASON_EFFECT)
end

-- Negate Effect functions
function s.negate_effect_condition(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetCounter(0x1036)>0 and rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

function s.negate_effect_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,0x1036,1,REASON_COST) end
    Duel.RemoveCounter(tp,1,1,0x1036,1,REASON_COST)
end

function s.negate_effect_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,nil,1,0,0) -- Change 'nil' to re:GetHandler() if necessary.
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,re:GetHandler(),1,0,0)
    end
end

function s.negate_effect_operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(re:GetHandler(),REASON_EFFECT)
    end
end