-- Drudomancer Respite
local s,id=GetID()
function s.initial_effect(c)
    -- Negate activation and destroy Spell/Trap (if Illusion monster controlled)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCondition(s.negate_condition)
    e1:SetTarget(s.negate_target)
    e1:SetOperation(s.negate_operation)
    c:RegisterEffect(e1)

    -- Activate from hand if Drudomancer monster revealed
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_ACTIVATE_COST)
    e2:SetRange(LOCATION_HAND)
    e2:SetCondition(s.hand_condition)
    e2:SetCost(s.hand_cost)
    c:RegisterEffect(e2)

    -- Set this card from GY and Normal Summon Illusion monster
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SUMMON)
    e3:SetType(EFFECT_TYPE_GRANT)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetTarget(s.settg)
    e3:SetOperation(s.setop)
    c:RegisterEffect(e3)
end

-- Condition to activate counter trap if Level 5 or higher Illusion monster controlled
function s.negate_condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.illusionfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- Target the Spell/Trap to negate
function s.negate_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end

-- Negate and destroy the Spell/Trap
function s.negate_operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

-- Condition to activate from hand if Drudomancer monster is revealed
function s.hand_condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND,0,1,nil)
end

-- Cost to activate from hand
function s.hand_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- Filter for Illusion monsters
function s.illusionfilter(c)
    return c:IsSetCard(0x317d) and c:IsLevelAbove(5) and c:IsType(TYPE_MONSTER)
end

-- Set this card from GY and Normal Summon Illusion monster
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.illusionfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.illusionfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.BreakEffect()
        Duel.NormalSummon(tp,g:GetFirst(),false,nil)
    end
end