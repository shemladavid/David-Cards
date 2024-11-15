-- Elemental HERO Feral Wildheart
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)

	-- Special Summon effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- Unaffected by opponent's spell/trap
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(s.unatarget)
	e3:SetValue(s.unafilter)
	c:RegisterEffect(e3)

	-- ATK boost
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.atktg)
	e4:SetValue(500)
	c:RegisterEffect(e4)
end

-- Special Summon limit
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsSetCard(0x3008) and sumtype==SUMMON_TYPE_SPECIAL
end

-- Special Summon Quick Effect condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE) > 0
end

-- Special Summon Quick Effect target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Special Summon Quick Effect operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
end

-- Immune to opponent's spells/traps target
function s.unatarget(e,c)
	return c:IsSetCard(0x3008) and c:IsFaceup() and c:IsControler(e:GetHandlerPlayer())
end

-- Immune to opponent's spells/traps filter
function s.unafilter(e,re)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- ATK boost target
function s.atktg(e,c)
	return c:IsSetCard(0x3008)
end
