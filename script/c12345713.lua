-- Floowandereeze & Typhoon
local s,id=GetID()
function s.initial_effect(c)
	-- If Tribute Summoned: Banish cards and apply effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.banishcon)
	e1:SetTarget(s.banishtg)
	e1:SetOperation(s.banishop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	-- Opponent cannot activate effects of banished cards
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.banishcon)
	e2:SetValue(s.aclimit)
	c:RegisterEffect(e2)

	-- Switch all monsters to face-up attack position and prevent position change
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetValue(POS_FACEUP_ATTACK+NO_FLIP_EFFECT)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	c:RegisterEffect(e4)
end

-- Check if the card was Tribute Summoned
function s.banishcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end

-- Target cards to banish
function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) 
			or Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,tp,0)
end

-- Banish cards and apply hand banish effect if applicable
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
	local resolved = false

	-- Banish all cards from both players' GYs
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		resolved = true
	end

	-- Banish 1 random card from opponent's hand
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #hg>0 then
		local sg=hg:RandomSelect(tp,1)
		if Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)>0 then
			resolved = true
		end
	end

	-- Allow another Normal Summon of a Winged Beast monster if at least one banish effect resolved
	if resolved then
		local sg=Duel.GetMatchingGroup(s.nsfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			Duel.Summon(tp,sc,true,nil)
		end
	end
end

-- Check for Winged Beast monsters for Normal Summon
function s.nsfilter(c)
	return c:IsRace(RACE_WINGEDBEAST) and c:IsSummonable(true,nil)
end

-- Prevent activation of effects of opponent's banished cards
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP+TYPE_MONSTER) and rc:IsLocation(LOCATION_REMOVED)
end
