--Constellar tellarknight Hall
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    --Send 2 Constellar or tellarknight cards from deck to GY and add 2 to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id) -- Hard once per turn
    e2:SetTarget(s.gytg)
    e2:SetOperation(s.gyop)
    c:RegisterEffect(e2)

    --Negate effect
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,id+1) -- Hard once per turn
    e3:SetCondition(s.negcon)
    e3:SetTarget(s.negtg)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)

    -- Change Xyz Level
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.xyzlvcon)
    e4:SetOperation(s.xyzlvop)
    c:RegisterEffect(e4)
end

s.listed_series={0x53,0x9c}

function s.gyfilter(c)
    return (c:IsSetCard(0x53) or c:IsSetCard(0x9c)) and c:IsAbleToGrave()
end

function s.handfilter(c)
    return (c:IsSetCard(0x53) or c:IsSetCard(0x9c)) and c:IsAbleToHand()
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,2,nil)
            and Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_DECK,0,2,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,2,nil) and
       Duel.IsExistingMatchingCard(s.handfilter,tp,LOCATION_DECK,0,2,nil) then
        -- Send 2 to GY
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,2,2,nil)
        Duel.SendtoGrave(g,REASON_EFFECT)
        
        -- Add 2 to hand
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local h=Duel.SelectMatchingCard(tp,s.handfilter,tp,LOCATION_DECK,0,2,2,nil)
        Duel.SendtoHand(h,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,h)
    end
end

function s.negfilter(c)
    return c:IsFaceup() and (c:IsSetCard(0x53) or c:IsSetCard(0x9c))
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_MZONE,0,1,nil) and rp~=tp 
    and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

function s.xyzlvcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    return tc:IsFaceup() and (tc:IsSetCard(0x53) or tc:IsSetCard(0x9c))
end

function s.xyzlvop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    if not tc then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_XYZ_LEVEL)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetValue(2)
    tc:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetValue(3)
    tc:RegisterEffect(e3)
    local e4=e1:Clone()
    e4:SetValue(4)
    tc:RegisterEffect(e4)
    local e5=e1:Clone()
    e5:SetValue(5)
    tc:RegisterEffect(e5)
    local e6=e1:Clone()
    e6:SetValue(6)
    tc:RegisterEffect(e6)
    local e7=e1:Clone()
    e7:SetValue(7)
    tc:RegisterEffect(e7)
end 