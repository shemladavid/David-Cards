--Super Fusion God
local s,id=GetID()
function s.initial_effect(c)
  -- Fusion material requirement
  c:EnableReviveLimit()
  -- Adjust Fusion procedure to better handle specific Fusion requirements
  Fusion.AddProcMix(c,true,true,CARD_NEOS,78371393)

  -- Cannot be Special Summon negated
  local e0 = Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
  e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
  c:RegisterEffect(e0)

  -- Banish all other cards
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetProperty(EFFECT_FLAG_DELAY)
  e1:SetCondition(s.banishcon)
  e1:SetTarget(s.banishtg)
  e1:SetOperation(s.banishop)
  c:RegisterEffect(e1)

  -- Unaffected by other card effects
  local e2 = Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE)
  e2:SetCode(EFFECT_IMMUNE_EFFECT)
  e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e2:SetRange(LOCATION_MZONE)
  e2:SetValue(s.efilter)
  c:RegisterEffect(e2)

  -- Cannot be tributed or used as material
  local e3 = Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_SINGLE)
  e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
  e3:SetCode(EFFECT_UNRELEASABLE_SUM)
  e3:SetValue(1)
  c:RegisterEffect(e3)
  local e4 = e3:Clone()
  e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
  c:RegisterEffect(e4)
  local e5 = e3:Clone()
  e5:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
  c:RegisterEffect(e5)
  local e6 = e3:Clone()
  e6:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
  c:RegisterEffect(e6)
  local e7 = e3:Clone()
  e7:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
  c:RegisterEffect(e7)
  local e8 = e3:Clone()
  e8:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
  c:RegisterEffect(e8)

  -- Cannot be destroyed by battle or card effects
  local e9=Effect.CreateEffect(c)
  e9:SetType(EFFECT_TYPE_SINGLE)
  e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
  e9:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
  e9:SetRange(LOCATION_MZONE)
  e9:SetValue(1)
  c:RegisterEffect(e9)
  local e10=e9:Clone()
  e10:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
  c:RegisterEffect(e10)

  -- Reflect battle damage and inflict damage
  local e11 = Effect.CreateEffect(c)
  e11:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
  e11:SetCode(EVENT_PRE_BATTLE_DAMAGE)
  e11:SetCondition(s.damcon)
  e11:SetOperation(s.damop)
  c:RegisterEffect(e11)

  -- Banish the monster after damage calculation
  local e12 = Effect.CreateEffect(c)
  e12:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
  e12:SetCode(EVENT_DAMAGE_STEP_END)
  e12:SetCondition(s.banishcon2)
  e12:SetOperation(s.banishop2)
  c:RegisterEffect(e12)

  -- Cannot lose the duel
  local e13 = Effect.CreateEffect(c)
  e13:SetType(EFFECT_TYPE_FIELD)
  e13:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
  e13:SetCode(EFFECT_CANNOT_LOSE_LP)
  e13:SetRange(LOCATION_MZONE)
  e13:SetTargetRange(1, 0)
  e13:SetValue(1)
  c:RegisterEffect(e13)

  local e14 = Effect.CreateEffect(c)
  e14:SetType(EFFECT_TYPE_FIELD)
  e14:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
  e14:SetCode(EFFECT_CANNOT_LOSE_DECK)
  e14:SetRange(LOCATION_MZONE)
  e14:SetTargetRange(1, 0)
  e14:SetValue(1)
  c:RegisterEffect(e14)

  local e15 = Effect.CreateEffect(c)
  e15:SetType(EFFECT_TYPE_FIELD)
  e15:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
  e15:SetCode(EFFECT_CANNOT_LOSE_EFFECT)
  e15:SetRange(LOCATION_MZONE)
  e15:SetTargetRange(1, 0)
  e15:SetValue(1)
  c:RegisterEffect(e15)

  -- Special summon a monster from opponent's banish zone
  local e16 = Effect.CreateEffect(c)
  e16:SetType(EFFECT_TYPE_QUICK_O)
  e16:SetCode(EVENT_FREE_CHAIN)
  e16:SetRange(LOCATION_MZONE)
  e16:SetHintTiming(0,TIMING_MAIN_END)
  e16:SetCountLimit(1)
  e16:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e16:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e16:SetTarget(s.ss_target)
  e16:SetOperation(s.ss_operation)
  c:RegisterEffect(e16)
end
s.material_setcode={0x8}
s.material={CARD_NEOS}
function s.banishcon(e,tp,eg,ep,ev,re,r,rp)
  return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return true end
  Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 0, PLAYER_ALL, LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end

function s.banishop(e,tp,eg,ep,ev,re,r,rp)
  local c = e:GetHandler()
  if not c:IsRelateToEffect(e) then return end
  local g = Duel.GetFieldGroup(tp, LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE, LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
  if g:IsContains(c) then
    g:RemoveCard(c)
  end
  Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
end

function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
  local c = e:GetHandler()
  local tc = Duel.GetAttackTarget()
  return (c == Duel.GetAttacker() or c == Duel.GetAttackTarget()) and c:IsRelateToBattle() and tc
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
  Duel.ChangeBattleDamage(tp, 0)
  Duel.ChangeBattleDamage(1-tp, ev, false)
end

function s.banishcon2(e,tp,eg,ep,ev,re,r,rp)
  local c = e:GetHandler()
  local atk = Duel.GetAttacker()
  local tgt = Duel.GetAttackTarget()
  -- Check if the card is either the attacker or the attack target
  return (c == atk or c == tgt) and c:IsRelateToBattle()
end

function s.banishop2(e,tp,eg,ep,ev,re,r,rp)
  local c = e:GetHandler()
  local atk = Duel.GetAttacker()
  local tgt = Duel.GetAttackTarget()
  local tc = (c == atk) and tgt or atk

  if tc and tc:GetControler() ~= tp then
    -- Inflict damage equal to the attack of the monster to be banished
    local damage = tc:GetAttack()
    Duel.Damage(1-tp, damage, REASON_EFFECT)

    -- Banish the monster
    Duel.Remove(tc, POS_FACEUP, REASON_EFFECT)
  end
end

function s.ss_filter(c)
  return c:IsType(TYPE_MONSTER) and c:IsSummonableCard()
end

function s.ss_target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.ss_filter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
  local g = Duel.GetMatchingGroup(s.ss_filter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,nil)
  local tc = g:Select(tp,1,1,nil):GetFirst()
  Duel.SetTargetCard(tc)
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, tc, 1, 0, 0)
end

function s.ss_operation(e,tp,eg,ep,ev,re,r,rp)
  local tc = Duel.GetFirstTarget()
  if tc and tc:IsRelateToEffect(e) then
    Duel.SpecialSummon(tc, 0, 1-tp, 1-tp, true, false, POS_FACEUP_ATTACK)
    
    -- Apply the following restrictions to the summoned monster:
    -- 1. Effects are Negated
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1,true)

    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e2,true)

    -- 2. Cannot Activate Its Effects
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_TRIGGER)
    e3:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e3,true)

    -- 3. Must Attack
    local e4=Effect.CreateEffect(e:GetHandler())
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_MUST_ATTACK)
    e4:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e4,true)

    -- 4. Double its ATK
    local e5=Effect.CreateEffect(e:GetHandler())
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_SET_ATTACK_FINAL)
    e5:SetValue(tc:GetAttack()*2)
    e5:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e5,true)

    -- 5. Cannot Change Battle Position
    local e6=Effect.CreateEffect(e:GetHandler())
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
    e6:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e6,true)

    -- 6. Cannot be Used as Tribute
    local e7=Effect.CreateEffect(e:GetHandler())
    e7:SetType(EFFECT_TYPE_SINGLE)
    e7:SetCode(EFFECT_UNRELEASABLE_SUM)
    e7:SetValue(1)
    e7:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e7,true)

    -- 7. Cannot be Used as Fusion, Synchro, Xyz, or Link Material
    local e8=Effect.CreateEffect(e:GetHandler())
    e8:SetType(EFFECT_TYPE_SINGLE)
    e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e8:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    e8:SetValue(1)
    e8:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e8,true)

    local e9=e8:Clone()
    e9:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    tc:RegisterEffect(e9,true)

    local e10=e8:Clone()
    e10:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    tc:RegisterEffect(e10,true)

    local e11=e8:Clone()
    e11:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    tc:RegisterEffect(e11,true)

    -- Ensure restrictions persist if the monster leaves the field
    local e12=Effect.CreateEffect(e:GetHandler())
    e12:SetType(EFFECT_TYPE_SINGLE)
    e12:SetCode(EFFECT_CANNOT_TRIGGER)
    e12:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_TURN_SET)
    tc:RegisterEffect(e12,true)
  end
end