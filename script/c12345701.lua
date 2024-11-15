--Ultimate Cracking Dragon
local s,id=GetID()
function s.initial_effect(c)
    -- ATK Gain on Opponent Taking Battle Damage
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_BATTLE_DAMAGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.atkcon)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
    
    -- Inflict Damage on Opponent's Summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.dmgcon)
    e2:SetOperation(s.dmgop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
    
    -- Create copies in monster zones
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetTarget(s.copytg)
    e4:SetOperation(s.copyop)
    c:RegisterEffect(e4)
end

-- Condition for ATK Gain
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp -- Opponent took battle damage
end

-- Operation for ATK Gain
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        -- Gain 1000 ATK
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end

-- Condition for Damage on Summon
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler,1,nil,1-tp)
end

-- Operation for Damage on Summon
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
    local sum=0
    for tc in aux.Next(eg) do
        if tc:IsControler(1-tp) then
            local rate=tc:GetLevel()
            if tc:IsType(TYPE_XYZ) then rate=tc:GetRank() end
            if tc:IsType(TYPE_LINK) then rate=tc:GetLink() end
            sum=sum+(rate*200)
        end
    end
    if sum>0 then
        Duel.Damage(1-tp,sum,REASON_EFFECT)
    end
end

-- Target for Copy Effect
function s.copytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        -- Check available monster zones for token placement
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_TOKEN,e:GetHandler():GetAttack(),e:GetHandler():GetDefense(),e:GetHandler():GetLevel(),e:GetHandler():GetRace(),e:GetHandler():GetAttribute())
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_MZONE)
end

-- Operation for Copy Effect
function s.copyop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 or not c:IsRelateToEffect(e) then return end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
    for i=1,ft do
        -- Special Summon a token as a copy of this card
        local token=Duel.CreateToken(tp,id)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
    end
    Duel.SpecialSummonComplete()
end