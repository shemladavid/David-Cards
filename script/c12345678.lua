--armatos gloria
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Unnafected by other cards' effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--Immune all cards
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_HAND+LOCATION_REMOVED,0)
	e3:SetValue(s.eefilter)
	c:RegisterEffect(e3)
	--indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--avoid battle damage
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--avoid effect damage
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_CHANGE_DAMAGE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e6:SetRange(LOCATION_SZONE)
	e6:SetTargetRange(1,0)
	e6:SetValue(s.damval)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e7)
	--avoid direct damage
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e8:SetRange(LOCATION_SZONE)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetTargetRange(1,0)
	e8:SetCondition(s.condition)
	c:RegisterEffect(e8)
	--unlimited hand
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_HAND_LIMIT)
	e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e9:SetRange(LOCATION_SZONE)
	e9:SetTargetRange(1,0)
	e9:SetValue(100)
	c:RegisterEffect(e9)
	--Cost Change
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetCode(EFFECT_LPCOST_CHANGE)
	e10:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e10:SetRange(LOCATION_SZONE)
	e10:SetTargetRange(1,0)
	e10:SetValue(s.costchange)
	c:RegisterEffect(e10)
	--choose attack
    local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetRange(LOCATION_SZONE)
	e11:SetCode(EFFECT_PATRICIAN_OF_DARKNESS)
	e11:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e11:SetTargetRange(0,1)
	c:RegisterEffect(e11)
	--forced atk pos
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_FIELD)
	e12:SetCode(EFFECT_SET_POSITION)
	e12:SetRange(LOCATION_SZONE)
	e12:SetTargetRange(0,LOCATION_MZONE)
	e12:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e12)
	local e13=e12:Clone()
	e13:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e13)
	--cannot set monster
	local e14=Effect.CreateEffect(c)
	e14:SetType(EFFECT_TYPE_FIELD)
	e14:SetRange(LOCATION_SZONE)
	e14:SetCode(EFFECT_CANNOT_MSET)
	e14:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e14:SetTargetRange(0,1)
	c:RegisterEffect(e14)
	--effect Light of Intervention
	local e15=Effect.CreateEffect(c)
	e15:SetType(EFFECT_TYPE_FIELD)
	e15:SetRange(LOCATION_SZONE)
	e15:SetCode(EFFECT_LIGHT_OF_INTERVENTION)
	e15:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e15:SetTargetRange(0,1)
	c:RegisterEffect(e15)
	--cannot turn set
	local e16=Effect.CreateEffect(c)
	e16:SetType(EFFECT_TYPE_FIELD)
	e16:SetCode(EFFECT_CANNOT_TURN_SET)
	e16:SetRange(LOCATION_SZONE)
	e16:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e16)
	-- Continuous effect to switch face-down monsters to face-up Defense Position
    local e16a=Effect.CreateEffect(c)
	e16a:SetType(EFFECT_TYPE_FIELD)
	e16a:SetCode(EFFECT_SET_POSITION)
	e16a:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e16a:SetRange(LOCATION_SZONE)
	e16a:SetTargetRange(0,LOCATION_MZONE)
	e16a:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e16a)
	--special summon from hand or GY
	local e17=Effect.CreateEffect(c)
	e17:SetDescription(aux.Stringid(id,0))
	e17:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e17:SetType(EFFECT_TYPE_IGNITION)
	e17:SetRange(LOCATION_SZONE)
	e17:SetTarget(s.target)
	e17:SetOperation(s.operation)
	c:RegisterEffect(e17)
	--Trap activate in set turn
	local e18=Effect.CreateEffect(c)
	e18:SetType(EFFECT_TYPE_FIELD)
	e18:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e18:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e18:SetRange(LOCATION_SZONE)
	e18:SetTargetRange(LOCATION_SZONE,0)
	c:RegisterEffect(e18)
	-- effect cannot be negated
	local e19=Effect.CreateEffect(c)
    e19:SetType(EFFECT_TYPE_FIELD)
    e19:SetCode(EFFECT_CANNOT_DISABLE)
    e19:SetRange(LOCATION_SZONE)
    e19:SetTargetRange(0xff,0)
    c:RegisterEffect(e19)
    --Summons cannot be negated
    local e20=Effect.CreateEffect(c)
    e20:SetType(EFFECT_TYPE_FIELD)
    e20:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e20:SetRange(LOCATION_SZONE)
    e20:SetTargetRange(LOCATION_MZONE,0)
    c:RegisterEffect(e20)
    local e21=e20:Clone()
    e21:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(e21)
    --Prevent activation of cards/effects that negate Summon
    local e22=Effect.CreateEffect(c)
    e22:SetType(EFFECT_TYPE_FIELD)
    e22:SetCode(EFFECT_CANNOT_ACTIVATE)
    e22:SetRange(LOCATION_SZONE)
    e22:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e22:SetTargetRange(0,1)
    e22:SetValue(s.aclimit)
    c:RegisterEffect(e22)
	--keep hand reveled
	local e23=Effect.CreateEffect(c)
	e23:SetType(EFFECT_TYPE_FIELD)
	e23:SetCode(EFFECT_PUBLIC)
	e23:SetRange(LOCATION_SZONE)
	e23:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e23)
	--extra deck spsummon
	local e24=Effect.CreateEffect(c)
	e24:SetDescription(aux.Stringid(id,1))
	e24:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e24:SetType(EFFECT_TYPE_IGNITION)
	e24:SetRange(LOCATION_SZONE)
	e24:SetTarget(s.extarget)
	e24:SetOperation(s.exoperation)
	c:RegisterEffect(e24)
	-- Prevent Tributing
    local e25=Effect.CreateEffect(c)
    e25:SetType(EFFECT_TYPE_FIELD)
    e25:SetCode(EFFECT_CANNOT_RELEASE)
    e25:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e25:SetRange(LOCATION_SZONE)
    e25:SetTargetRange(0,1)
    e25:SetTarget(s.releaseTarget)
    c:RegisterEffect(e25)
	-- Prevent using your monsters for Link Summon
	local e26=Effect.CreateEffect(c)
	e26:SetType(EFFECT_TYPE_FIELD)
	e26:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e26:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e26:SetRange(LOCATION_SZONE)
	e26:SetTargetRange(LOCATION_MZONE,0)
	e26:SetValue(s.linklimit)
	c:RegisterEffect(e26)
	--Pay LP instead of detaching for Xyz Monsters
	local e27=Effect.CreateEffect(c)
	e27:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e27:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e27:SetRange(LOCATION_SZONE)
	e27:SetCondition(s.rcon)
	e27:SetOperation(s.repop)
	c:RegisterEffect(e27)
	-- Infinite Normal Summon
    local e28=Effect.CreateEffect(c)
    e28:SetType(EFFECT_TYPE_FIELD)
    e28:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
    e28:SetRange(LOCATION_SZONE)
    e28:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e28:SetTargetRange(1,0)
    e28:SetValue(s.countlimit)
    c:RegisterEffect(e28)
    --activation cannot be negated
	local e29=Effect.CreateEffect(c)
	e29:SetType(EFFECT_TYPE_FIELD)
	e29:SetCode(EFFECT_CANNOT_INACTIVATE)
	e29:SetRange(LOCATION_SZONE)
	e29:SetValue(s.effectfilter)
	c:RegisterEffect(e29)
	local e30=Effect.CreateEffect(c)
	e30:SetType(EFFECT_TYPE_FIELD)
	e30:SetCode(EFFECT_CANNOT_DISEFFECT)
	e30:SetRange(LOCATION_SZONE)
	e30:SetValue(s.effectfilter)
	c:RegisterEffect(e30)
end

function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

function s.eefilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT~=0 then return 0 end
	return val
end

function s.condition(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>=0
end

function s.costchange(e,re,rp,val)
	if re and not mustpay then
		return 0
	else
		return val
	end
end

function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_MZONE,nil)
    local tc=g:GetFirst()
    while tc do
        if tc:IsDefensePos() then
            Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
        end
        tc=g:GetNext()
    end
end

function s.filter(c,e,sp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,sp,true,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		local tc=g:GetFirst()
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure() -- Mark the summoned monster as properly summoned
	end
end

function s.exfilter(c, e, tp)
    return c:IsMonster() and c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0)
end

function s.extarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.exoperation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local tc = Duel.SelectMatchingCard(tp, s.exfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if tc then
        if tc:IsType(TYPE_FUSION) then
            Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, true, false, POS_FACEUP)
        elseif tc:IsType(TYPE_SYNCHRO) then
            Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, true, false, POS_FACEUP)
        elseif tc:IsType(TYPE_XYZ) then
            Duel.SpecialSummon(tc, SUMMON_TYPE_XYZ, tp, tp, true, false, POS_FACEUP)
        elseif tc:IsType(TYPE_LINK) then
            Duel.SpecialSummon(tc, SUMMON_TYPE_LINK, tp, tp, true, false, POS_FACEUP)
        else
            Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
        end
        tc:CompleteProcedure()
    end
end

function s.releaseTarget(e,c)
    return c:IsControler(e:GetHandlerPlayer())
end

function s.aclimit(e,re,tp)
    return re:IsHasCategory(CATEGORY_NEGATE)
end

function s.linklimit(e,c)
    if not c then return false end
    return c:IsControler(1-e:GetHandlerPlayer())
end

function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id+ep)==0
		and (r&REASON_COST)~=0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.PayLPCost(tp, 500)
end

function s.countlimit(e)
    return 99
end

function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and loc&LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_DECK+LOCATION_REMOVED+LOCATION_OVERLAY~=0
end