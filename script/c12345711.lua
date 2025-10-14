-- Predaplant World
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Add 1 "Predaplant" monster or 1 "Preda" card
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- Treat monsters with Predator Counters as DARK
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(s.attg)
    e3:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e3)

    -- Fusion Summon DARK Fusion Monster
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1,{id,1})
    e4:SetTarget(s.fustg)
    e4:SetOperation(s.fusop)
    c:RegisterEffect(e4)

    -- Special Summon "Predaplant" monster
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1,{id,2})
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)

    -- Place Predator Counter on summoned monsters
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_SUMMON_SUCCESS)
    e6:SetRange(LOCATION_FZONE)
    e6:SetOperation(s.ctop)
    c:RegisterEffect(e6)
    local e7=e6:Clone()
    e7:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e7)

    -- Monsters with Predator Counter become Level 1
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD)
    e8:SetCode(EFFECT_CHANGE_LEVEL)
    e8:SetRange(LOCATION_FZONE)
    e8:SetTargetRange(0,LOCATION_MZONE)
    e8:SetTarget(s.lvtg)
    e8:SetValue(1)
    c:RegisterEffect(e8)

    -- Treat monsters with Predator Counters as DARK for Fusion Summon
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e9:SetRange(LOCATION_FZONE)
	e9:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e9:SetTarget(s.attrtg)
	e9:SetValue(s.attrval)
	e9:SetOperation(s.attrcon)
	c:RegisterEffect(e9)
end
s.listed_series={0xf3,0x10f3}
s.counter_place_list={COUNTER_PREDATOR}

-- Add "Predaplant" or "Preda" card
function s.thfilter(c)
    return (c:IsSetCard(0xf3) or c:IsSetCard(0x10f3)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Treat monsters with Predator Counters as DARK
function s.attg(e,c)
    return c:GetCounter(COUNTER_PREDATOR)>0
end

-- Fusion Summon DARK Fusion Monster
function s.fusfilter1(c,e)
    return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function s.fusfilter2(c,e,tp,mg)
    return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) 
        and c:CheckFusionMaterial(mg)
end
function s.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetFusionMaterial(tp):Filter(s.fusfilter1,nil,e)
        -- Include Pendulum Zone as potential Fusion Materials
        local pg=Duel.GetMatchingGroup(s.fusfilter1,tp,LOCATION_PZONE,0,nil,e)
        mg:Merge(pg)
        local sg=Duel.GetMatchingGroup(s.fusfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
        return #sg>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetFusionMaterial(tp):Filter(s.fusfilter1,nil,e)
    -- Include Pendulum Zone as potential Fusion Materials
    local pg=Duel.GetMatchingGroup(s.fusfilter1,tp,LOCATION_PZONE,0,nil,e)
    mg:Merge(pg)
    local sg=Duel.GetMatchingGroup(s.fusfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg)
    if #sg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tc=sg:Select(tp,1,1,nil):GetFirst()
        if tc then
            local mat=Duel.SelectFusionMaterial(tp,tc,mg,tp)
            tc:SetMaterial(mat)
            -- Send selected materials to the GY or Extra Deck (for Pendulum monsters)
            Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
end

-- Special Summon "Predaplant" monster
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xf3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- Place Predator Counter
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    while tc do
        if tc:IsCanAddCounter(COUNTER_PREDATOR,1) then
            tc:AddCounter(COUNTER_PREDATOR,1)
        end
        tc=eg:GetNext()
    end
end

-- Monsters with Predator Counter become Level 1
function s.lvtg(e,c)
    return c:GetCounter(COUNTER_PREDATOR)>0
end

-- Treat monsters with Predator Counters as DARK for Fusion Summon
function s.attrtg(e,c)
	return c:GetCounter(COUNTER_PREDATOR)>0
end
function s.attrval(e,c,rp)
	if rp==e:GetHandlerPlayer() then
		return ATTRIBUTE_DARK
	else return c:GetAttribute() end
end
function s.attrcon(scard,sumtype,tp)
	return (sumtype&MATERIAL_FUSION)~=0
end