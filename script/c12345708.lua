--Better Skill Drain
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.disable)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	--Send to GY and Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.rmsptg)
	e3:SetOperation(s.rmspop)
	c:RegisterEffect(e3)
end
function s.disable(e,c)
	return c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT
end
function s.rmsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_GRAVE)
end
function s.spfilter(c,e,tp)
	local owner=c:GetOwner()
	return c:IsLocation(LOCATION_GRAVE) and not c:IsReason(REASON_REDIRECT)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,owner)
end
function s.rmspop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		local sg=og:Filter(s.spfilter,nil,e,tp)
		if #sg==0 then return end
		local your_sg,opp_sg=sg:Split(Card.IsOwner,nil,tp)
		local your_ft,opp_ft=Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.GetLocationCount(1-tp,LOCATION_MZONE)
		if #your_sg>your_ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			your_sg=your_sg:Select(tp,your_ft,your_ft,nil)
		end
		if #opp_sg>opp_ft then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			opp_sg=opp_sg:Select(tp,opp_ft,opp_ft,nil)
		end
		sg=your_sg+opp_sg
		for sc in sg:Iter() do
			Duel.SpecialSummonStep(sc,0,tp,sc:GetOwner(),false,false,POS_FACEUP_ATTACK)
		end
		Duel.SpecialSummonComplete()
	end
end
