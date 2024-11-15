-- Elemental HERO Crashing Clayman
local s,id=GetID()
function s.initial_effect(c)
    c:SetUniqueOnField(1,0,84327329)
    -- Limit attacks
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)

    -- Special summon "Elemental HERO Crashing Clayman" if an "Elemental HERO" monster is special summoned
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)

    -- Prevent targeting and destruction by opponent's card effects
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_ONFIELD,0)
    e3:SetTarget(s.tgtg)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e4:SetValue(s.tgvalue)
    c:RegisterEffect(e4)
end

-- Effect 1: Restrict attacks
function s.atlimit(e,c)
	return c~=e:GetHandler()
end


-- Effect 2: Special summon "Elemental HERO Crashing Clayman" if an "Elemental HERO" monster is special summoned
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsFaceup() and c:IsSetCard(0x3008) end, 1, nil)
        and Duel.GetLocationCount(tp,LOCATION_MZONE) > 0
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        -- Additional operations if needed
    end
end

-- Condition for "Elemental HERO" restriction
function s.tgtg(e,c)
    return c:IsFaceup() and c:IsSetCard(0x3008)
end

-- Effect target function for preventing targeting and destruction
function s.tgvalue(e,re,rp)
    return rp~=e:GetHandlerPlayer()
end

-- Limit the presence of "Elemental HERO Crashing Clayman"
function s.limitcon(e)
    return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil,e:GetHandler())
end

function s.filter(c,ec)
    return c:IsCode(ec:GetCode()) and c:IsFaceup()
end

function s.limitval(e,c)
    return c:IsCode(id)
end
