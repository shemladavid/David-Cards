-- Drudomancer Soul Echo
local s,id=GetID()
function s.initial_effect(c)
    -- Activation
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Normal Summon Illusion monster during Main Phase
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e2:SetCode(EVENT_PHASE+PHASE_MAIN1)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.summon_condition)
    e2:SetOperation(s.summon_operation)
    c:RegisterEffect(e2)

    -- "Drudomancer" monsters gain ATK equal to half their original DEF
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.atk_target)
    e3:SetValue(s.atk_value)
    c:RegisterEffect(e3)

    -- Return Illusion monster to hand or destroy the card during End Phase
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.end_phase_condition)
    e4:SetTarget(s.end_phase_target)
    e4:SetOperation(s.end_phase_operation)
    c:RegisterEffect(e4)

    -- Activate from hand if "Drudomancer" monster is revealed
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_ACTIVATE_COST)
    e5:SetRange(LOCATION_HAND)
    e5:SetCondition(s.hand_condition)
    e5:SetCost(s.hand_cost)
    c:RegisterEffect(e5)
end

-- Condition to Normal Summon 1 Illusion monster during Main Phase
function s.summon_condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

-- Summon 1 Illusion monster immediately after effect resolves
function s.summon_operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Normalsummon(tp,Duel.SelectMatchingCard(tp,s.summonfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst())
end

-- Filter for Illusion monster
function s.summonfilter(c)
    return c:IsSetCard(0x317d) and c:IsType(TYPE_MONSTER)
end

-- "Drudomancer" monsters gain ATK equal to half their original DEF
function s.atk_target(e,c)
    return c:IsSetCard(0x317d) and c:IsType(TYPE_MONSTER)
end

function s.atk_value(e,c)
    return c:GetOriginalDefence()//2
end

-- Return Level 5 or higher Illusion monster or destroy card during End Phase
function s.end_phase_condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.end_phase_filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.end_phase_filter(c)
    return c:IsSetCard(0x317d) and c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER)
end

function s.end_phase_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.end_phase_filter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end

function s.end_phase_operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.end_phase_filter,tp,LOCATION_MZONE,0,1,1,nil)
    if #g>0 then
        if Duel.SendtoHand(g,nil,REASON_EFFECT) then
            Duel.BreakEffect()
        end
    else
        Duel.Destroy(e:GetHandler(),REASON_EFFECT)
    end
end

-- Condition to activate from hand if "Drudomancer" monster is revealed
function s.hand_condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.hand_filter,tp,LOCATION_HAND,0,1,nil)
end

-- Cost to activate from hand
function s.hand_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- Filter for Drudomancer monster in hand
function s.hand_filter(c)
    return c:IsSetCard(0x317d) and c:IsType(TYPE_MONSTER)
end