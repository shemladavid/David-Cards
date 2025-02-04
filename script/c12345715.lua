--Mirror Knight Calling
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Place in Spell/Trap Zone and Special Summon Tokens
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Place Shield Counters
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.cttg)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)
    --Equalize ATK during battle
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_SET_POSITION)
    e5:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    e5:SetRange(LOCATION_SZONE)
    e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e5:SetValue(POS_FACEUP_ATTACK+NO_FLIP_EFFECT)
    c:RegisterEffect(e5)
    --Opponent must attack
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_MUST_ATTACK)
    e6:SetRange(LOCATION_SZONE)
    e6:SetTargetRange(0,LOCATION_MZONE)
    c:RegisterEffect(e6)
    --Choose attack targets
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
    e7:SetRange(LOCATION_SZONE)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e7:SetTargetRange(0,1)
    c:RegisterEffect(e7)
end
s.listed_names={170000175}

-- Special Summon Tokens and Place Card in S/T Zone
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>3 and
        Duel.IsPlayerCanSpecialSummonMonster(tp,170000175,0x530,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,5,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,5,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<4 or
        Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
    local c=e:GetHandler()
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,170000175,0x530,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_DARK) then return end
    if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
        local g=Group.CreateGroup()
        for i=1,5 do
            local token=Duel.CreateToken(tp,170000175)
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
            g:AddCard(token)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
            e1:SetCode(EFFECT_DESTROY_REPLACE)
            e1:SetTarget(s.reptg)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            token:RegisterEffect(e1)
        end
        Duel.SpecialSummonComplete()
        g:ForEach(function(tc)
            tc:AddCounter(0x1106,1)
        end)
    end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE) and e:GetHandler():GetCounter(0x1106)>0 end
	e:GetHandler():RemoveCounter(tp,0x1106,1,REASON_EFFECT)
	return true
end

-- Place Shield Counters
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_MZONE,0,nil)
    g:ForEach(function(tc)
        tc:AddCounter(0x1106,1)
    end)
end
function s.ctfilter(c)
    return c:IsFaceup() and c:IsCode(170000175) and c:GetCounter(0x1106)==0
end

-- Equalize ATK During Battle
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if not d then return false end
	local g=Group.FromCards(a,d)
	return g:IsExists(s.atkfilter,1,nil,1)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if not d then return end
    local g=Group.FromCards(a,d):Filter(s.atkfilter,nil)
    g:ForEach(function(tc)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(tc==a and d:GetAttack() or a:GetAttack())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
        tc:RegisterEffect(e1)
    end)
end
function s.atkfilter(c)
    return c:IsFaceup() and c:IsCode(170000175)
end