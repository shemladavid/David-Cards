--Constellar tellarknight Hall
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    --Normal summon without tribute
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_SUMMON_PROC)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_HAND,0)
    e2:SetCondition(s.ntcon)
    c:RegisterEffect(e2)

    -- Infinite Normal Summon
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(1,0)
    e3:SetValue(s.countlimit)
    c:RegisterEffect(e3)

    --Send 2 Constellar or tellarknight cards from deck to GY
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.gytg)
    e4:SetOperation(s.gyop)
    c:RegisterEffect(e4)

    --Negate effect
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.negcon)
    e5:SetTarget(s.negtg)
    e5:SetOperation(s.negop)
    c:RegisterEffect(e5)

    -- Change Xyz Level
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e6:SetCode(EVENT_SUMMON_SUCCESS)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCondition(s.xyzlvcon)
    e6:SetOperation(s.xyzlvop)
    c:RegisterEffect(e6)

    -- Optional detach replacement effect
    local e7 = Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e7:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
    e7:SetRange(LOCATION_FZONE)
    e7:SetTarget(s.xyzremove)
    e7:SetValue(s.xyzremovevalue)
    c:RegisterEffect(e7)
end

s.listed_series={0x53,0x9c}

function s.ntcon(e,c,minc)
    if c==nil then return true end
    return minc==0 and c:GetLevel()>=5
end

function s.countlimit(e)
    return 99
end

function s.gyfilter(c)
    return (c:IsSetCard(0x53) or c:IsSetCard(0x9c)) and c:IsAbleToGrave()
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,2,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,2,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,2,2,nil)
        Duel.SendtoGrave(g,REASON_EFFECT)
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

-- Optional detach replacement effect
function s.xyzremove(e,tp,eg,ep,ev,re,r,rp)
    -- Check if the effect is being activated and if it involves an Xyz monster
    if re and (re:GetHandler():IsSetCard(0x53) or re:GetHandler():IsSetCard(0x9c)) and re:GetHandler():IsType(TYPE_XYZ) then
        return true -- Allow the detachment to be replaced
    end
    return false
end

function s.xyzremovevalue(e,re,rp)
    local tp=e:GetOwnerPlayer()
    local rc=re:GetHandler()  -- Get the card that activated the effect

    -- Check if the card is a face-up "Constellar or tellarknight" Xyz monster
    if rc:IsFaceup() and (rc:IsSetCard(0x53) or rc:IsSetCard(0x9c)) and rc:IsType(TYPE_XYZ) then
        -- Prompt the player with a Yes/No option
        if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            return true -- Player opts not to detach
        end
    end
    return false -- Player chooses to detach as normal
end