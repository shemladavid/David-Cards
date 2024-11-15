--Altergeist Realm
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    --Cannot be targeted
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_ONFIELD,0)
    e2:SetTarget(s.tgtg)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    --Add Altergeist card from Deck or GY to hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    --Activate Trap the turn it is set
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_SZONE,0)
    e4:SetTarget(s.acttg)
    c:RegisterEffect(e4)

    --Special Summon from GY if sent there
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetCountLimit(1,id+1)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_TO_GRAVE)
    e5:SetRange(LOCATION_FZONE)
    e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
    e5:SetCondition(s.spcon)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
end

-- "Altergeist" cards cannot be targeted by opponent's effects
function s.tgtg(e,c)
    return c:IsSetCard(0x103) -- "Altergeist" cards
end

-- Add "Altergeist" card from Deck or GY to hand
function s.thfilter(c)
    return c:IsSetCard(0x103) and c:IsAbleToHand()
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

-- Allow "Altergeist" Trap activation the turn it is set
function s.acttg(e,c)
    return c:IsSetCard(0x103) and c:IsType(TYPE_TRAP)
end

-- Special Summon an "Altergeist" monster from GY when it is sent there
function s.cfilter(c,tp)
    return c:IsSetCard(0x103) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end

    local g=eg:Filter(s.cfilter,nil,tp)
    if #g==0 then return false end

    -- If there are 2 or more monsters, we need to target one of them
    if #g > 1 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
    end

    return true
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x103) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    local g=eg:Filter(s.cfilter,nil,tp)
    if #g > 1 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        g=g:Select(tp,1,1,nil)
    elseif #g == 1 then
        -- If there's only one, we can directly select that one
        g=g:Select(tp,1,1,nil)
    else
        return
    end
    
    if #g > 0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end