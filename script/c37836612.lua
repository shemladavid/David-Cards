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
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCondition(s.summon_condition)
    e2:SetTarget(s.summon_target)
    e2:SetOperation(s.summon_operation)
    c:RegisterEffect(e2)

    -- "Drudomancer" monsters pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ILLUSION))
	c:RegisterEffect(e3)

    -- Return Illusion monster to hand or destroy the card during End Phase
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e4:SetCode(EVENT_PHASE+PHASE_END)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1)
    e4:SetOperation(s.end_phase_operation)
    c:RegisterEffect(e4)

    -- Activate from hand if "Drudomancer" monster is revealed
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e5:SetCondition(s.hand_condition)
	c:RegisterEffect(e5)
end

-- Condition to Normal Summon 1 Illusion monster during Main Phase
function s.summon_condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

-- Target 1 Illusion monster to Normal Summon
function s.summon_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.summonfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- Summon 1 Illusion monster immediately after effect resolves
function s.summon_operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
    local g=Duel.SelectMatchingCard(tp,s.summonfilter,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.Summon(tp,g:GetFirst(),true,nil)
    end
end

-- Filter for Illusion monster
function s.summonfilter(c)
    return c:IsRace(RACE_ILLUSION) and c:IsType(TYPE_MONSTER) and c:IsSummonable(true,nil)
end

-- Return Level 5 or higher Illusion monster or destroy card during End Phase
function s.end_phase_filter(c)
    return c:IsSetCard(0x317d) and c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER)
end

function s.end_phase_operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsExistingMatchingCard(s.end_phase_filter,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local g=Duel.SelectMatchingCard(tp,s.end_phase_filter,tp,LOCATION_MZONE,0,1,1,nil)
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    else
        Duel.Destroy(e:GetHandler(),REASON_EFFECT)
    end
end

-- Condition to activate from hand if "Drudomancer" monster is revealed
function s.hand_condition(e)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) and
           Duel.IsExistingMatchingCard(s.hand_filter,tp,LOCATION_HAND,0,1,nil)
end

-- Filter for "Drudomancer" monsters
function s.hand_filter(c)
    return c:IsSetCard(0x317d) and c:IsType(TYPE_MONSTER)
end