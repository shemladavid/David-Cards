-- Elemental HERO Cutting Bladedge
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon by tributing 1 "Elemental HERO" monster
    local e1=Effect.CreateEffect(c)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    -- Inflict damage if "Elemental HERO" monster destroys a monster by battle or card effect
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.damcon)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)

    -- Gain ATK and piercing battle damage
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BE_BATTLE_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.piercing_condition)
    e3:SetOperation(s.piercing_operation)
    c:RegisterEffect(e3)
end

-- Special Summon condition
function s.spcon(e,c)
    if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),Card.IsSetCard,1,false,1,true,c,c:GetControler(),nil,false,nil,0x3008)
end

-- Special Summon target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,false,true,true,c,nil,nil,false,nil,0x3008)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end

-- Special Summon operation
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end

-- Effect 2 functions
-- Damage condition
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    -- Check if it was destroyed by battle
    if tc:IsReason(REASON_BATTLE) then
        local rc=tc:GetBattleTarget()
        return rc and rc:IsSetCard(0x3008)
    end
    -- Check if it was destroyed by a card effect (including negation effects)
    if tc:IsReason(REASON_EFFECT) then
        local rc=tc:GetReasonCard()
        return (rc and rc:IsSetCard(0x3008)) or (re and re:GetHandler():IsSetCard(0x3008))
    end
    return false
end

-- Damage operation
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:GetFirst()
    local dam=math.max(tc:GetAttack(), tc:GetDefense())
    if dam<0 then dam=0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(dam)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end

-- Effect 3 functions
function s.piercing_condition(e,tp,eg,ep,ev,re,r,rp)
    local c=Duel.GetAttacker()
    local tc=Duel.GetAttackTarget()
    return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x3008) and c:IsControler(tp) and tc and tc:IsDefensePos()
end

function s.piercing_operation(e,tp,eg,ep,ev,re,r,rp)
    local c=Duel.GetAttacker()
    if c:IsRelateToBattle() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_SET_ATTACK_FINAL)
        e1:SetValue(c:GetAttack()+500)
        e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
        c:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_PIERCE)
        e2:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
        c:RegisterEffect(e2)
    end
end