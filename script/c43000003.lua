-- Elemental HERO Hydraulic Bubbleman
local s,id=GetID()
function s.initial_effect(c)
    -- Special summon from hand if you control a face-up "Elemental HERO" monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Continuous Effect: Protect all "Elemental HERO" monsters you control during opponent's turn
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x3008))
    e2:SetCondition(s.protcon)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    
    local e3=e2:Clone()
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)

    -- Draw and Special Summon if used as material
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e4:SetCondition(s.drcon)
    e4:SetTarget(s.drtg)
    e4:SetOperation(s.drop)
    c:RegisterEffect(e4)
end

-- Effect 1: Special summon from hand
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_MZONE,0,1,nil,0x3008)
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    -- Cost for Special Summon (if any, e.g., discarding a card or paying LP)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end

-- Effect 2: Continuous Protection during opponent's turn
function s.protcon(e)
    return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end

function s.efilter(e,re)
    return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end

-- Effect 3: Draw and Special Summon if used as material
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
    return r&REASON_FUSION~=0
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.Draw(tp,1,REASON_EFFECT)>0 then
        local dc=Duel.GetOperatedGroup():GetFirst()
        if dc:IsSetCard(0x3008) and dc:IsType(TYPE_MONSTER) then
            if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
                Duel.SpecialSummon(dc,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end
