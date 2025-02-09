-- Envy of Drudomancer
local s,id=GetID()
function s.initial_effect(c)
    -- Negate effects and take control of monster
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_CONTROL)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTarget(s.negctg)
    e1:SetOperation(s.negcop)
    c:RegisterEffect(e1)

    -- Set and return Illusion monster to hand
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_GRANT)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

-- Negate effect and take control if Drudomancer revealed
function s.negctg(e,tp,eg,ep,ev,re,r,rp,chk)
    local tg=Duel.GetFirstTarget()
    if chk==0 then return tg and tg:IsFaceup() and tg:IsSpecialSummoned() end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,tg,1,0,0)
    if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND,0,1,nil) then
        Duel.SetOperationInfo(0,CATEGORY_CONTROL,tg,1,0,0)
    end
end
function s.negcop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetFirstTarget()
    if tg:IsFaceup() and tg:IsSpecialSummoned() then
        -- Negate effects
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tg:RegisterEffect(e1)
        -- Take control if Drudomancer monster is revealed
        if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_HAND,0,1,nil) then
            Duel.GetControl(tg,tp)
        end
    end
end

-- Set card from GY and return Illusion monster
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.illusionfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.SelectMatchingCard(tp,s.illusionfilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #tg>0 then
        local g=Duel.GetMatchingGroup(s.illusionfilter,tp,LOCATION_MZONE,0,nil)
        if #g>0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_SET_CONTROL)
            e1:SetTarget(s.target)
            e1:SetOperation(s.operation)
            e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
            g:RegisterEffect(e1)
        end
    end
end