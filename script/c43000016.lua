-- Elemental HERO Thrashing Wildedge
local s,id=GetID()

-- Define the Fusion Monster
function s.initial_effect(c)
    -- Fusion material
    Fusion.AddProcMixN(c,true,true,s.filter_fusion_material,2) 
    
    -- Can attack every monster once
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_ATTACK_ALL)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    
    -- Remove
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,0xff)
    e2:SetValue(LOCATION_REMOVED)
    e2:SetTarget(s.target_remove)
    c:RegisterEffect(e2)
    
    -- Special summon
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.condition_special_summon)
    e3:SetTarget(s.target_special_summon)
    e3:SetOperation(s.operation_special_summon)
    c:RegisterEffect(e3)
    
    -- Inflict damage when destroying an opponent's monster by battle
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_BATTLE_DESTROYING)
    e4:SetCondition(s.condition_inflict_damage)
    e4:SetOperation(s.operation_inflict_damage)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    c:RegisterEffect(e4)
end

-- Fusion material filter
function s.filter_fusion_material(c,fc,sumtype,tp,sub,mg,sg)
    return c:IsSetCard(0x3008,fc,sumtype,tp) and c:GetAttribute(fc,sumtype,tp)~=0 and (not sg or not sg:IsExists(s.fusion_filter,1,c,c:GetAttribute(fc,sumtype,tp),fc,sumtype,tp))
end

-- Fusion filter
function s.fusion_filter(c,attr,fc,sumtype,tp)
    return c:IsAttribute(attr,fc,sumtype,tp)
end

-- Target for removal
function s.target_remove(e,c)
    return c:GetOwner()~=e:GetHandlerPlayer() and Duel.IsPlayerCanRemove(e:GetHandlerPlayer(),c)
end

-- Condition for special summon (only during your Battle Phase)
function s.condition_special_summon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer() ~= tp then
        return false
    end
    -- Get the opponent's banished monsters
    local opponent = 1 - tp
    local opponent_banished = Duel.GetMatchingGroup(Card.IsType, tp, LOCATION_REMOVED, LOCATION_REMOVED, nil, TYPE_MONSTER)
    local has_opponent_monsters = false

    -- Check if there are any banished monsters owned by the opponent
    for tc in aux.Next(opponent_banished) do
        if tc:GetOwner() == opponent then
            has_opponent_monsters = true
            break
        end
    end

    return has_opponent_monsters
end

-- Filter for special summon
function s.filter_special_summon(c,e,tp)
    return c:IsMonster() and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

-- Target for special summon
function s.target_special_summon(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(1-tp) and s.filter_special_summon(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.filter_special_summon,tp,0,LOCATION_REMOVED,1,nil,e,tp) end
    local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
    if ft>5 then ft=5 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.filter_special_summon,tp,0,LOCATION_REMOVED,1,ft,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end

-- Operation for special summon
function s.operation_special_summon(e,tp,eg,ep,ev,re,r,rp)
    local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local sg=g:Filter(Card.IsRelateToEffect,nil,e)
    if #sg>ft then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        sg=sg:Select(tp,ft,ft,nil)
    end
    local tc=sg:GetFirst()
    while tc do
        Duel.SpecialSummonStep(tc,0,tp,1-tp,true,false,POS_FACEUP_ATTACK)

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

        -- 3. Set ATK to 0
        local e4=Effect.CreateEffect(e:GetHandler())
        e4:SetType(EFFECT_TYPE_SINGLE)
        e4:SetCode(EFFECT_SET_ATTACK)
        e4:SetValue(0)
        e4:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e4,true)

        -- 4. Cannot Attack
        local e5=Effect.CreateEffect(e:GetHandler())
        e5:SetType(EFFECT_TYPE_SINGLE)
        e5:SetCode(EFFECT_CANNOT_ATTACK)
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
        e7:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e7,true)

        -- 7. Cannot be Used as Fusion, Synchro, Xyz, or Link Material
        local e8=Effect.CreateEffect(e:GetHandler())
        e8:SetType(EFFECT_TYPE_SINGLE)
        e8:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
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

        tc=sg:GetNext()
    end
    Duel.SpecialSummonComplete()
end

-- Condition for inflicting damage when destroying an opponent's monster by battle
function s.condition_inflict_damage(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsRelateToBattle() and c:GetBattleTarget() and c:GetBattleTarget():IsControler(1-tp) and c:IsSetCard(0x3008)
end

-- Operation for inflicting damage
function s.operation_inflict_damage(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetBattleTarget() and c:GetBattleTarget():IsControler(1-tp) then
        Duel.Damage(1-tp,1000,REASON_EFFECT) -- Inflict 1000 damage to your opponent
    end
end
