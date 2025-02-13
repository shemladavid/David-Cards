-- Drudomancer Respite
local s,id=GetID()
function s.initial_effect(c)
    -- Negate activation and destroy Spell/Trap (if Illusion monster controlled)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negate_condition)
    e1:SetTarget(s.negate_target)
    e1:SetOperation(s.negate_operation)
    c:RegisterEffect(e1)

    -- Activate from hand if Drudomancer monster revealed
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetCondition(s.hand_condition)
	c:RegisterEffect(e2)

    -- Set this card from GY and Normal Summon Illusion monster
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DISABLE+CATEGORY_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.settg)
    e3:SetOperation(s.setop)
    c:RegisterEffect(e3)
end

-- Condition to activate counter trap if Level 5 or higher Illusion monster controlled
function s.negate_condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.illusionfilter,tp,LOCATION_MZONE,0,1,nil) and re:IsActiveType(TYPE_TRAP+TYPE_SPELL) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end

-- Target the Spell/Trap to negate
function s.negate_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

-- Negate and destroy the Spell/Trap
function s.negate_operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        Duel.Destroy(eg,REASON_EFFECT)
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

-- Filter for Illusion monsters
function s.illusionfilter(c)
    return c:IsSetCard(0x317d) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(5)
end

-- Set this card from GY and Normal Summon Illusion monster
function s.illusionfilter1(c)
    return c:IsSetCard(0x317d) and c:IsType(TYPE_MONSTER) and c:IsSummonable(true,nil)
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.illusionfilter1,tp,LOCATION_HAND,0,1,nil) and e:GetHandler():IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsSSetable() then
        Duel.SSet(tp,c)
        local e1=Effect.CreateEffect(c)
		e1:SetDescription(3300)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
        local g=Duel.SelectMatchingCard(tp,s.illusionfilter1,tp,LOCATION_HAND,0,1,1,nil)
        if #g>0 then
            Duel.Summon(tp,g:GetFirst(),true,nil)
        end
    end
end