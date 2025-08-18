--Ultimate Contract with Exodia
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

s.listed_names={12600382,8124921,44519536,70903634,7902349,33396948}

function s.tgfilter(c)
	return c:IsAbleToGrave()
		and (c:IsCode(33396948) or c:IsCode(70903634) or c:IsCode(7902349) 
		or c:IsCode(8124921) or c:IsCode(44519536))
end

function s.spfilter(c,e,tp)
	return c:IsCode(12600382) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
	if chk==0 then
		return g1:IsExists(Card.IsCode,1,nil,33396948)
			and g1:IsExists(Card.IsCode,1,nil,70903634)
			and g1:IsExists(Card.IsCode,1,nil,7902349)
			and g1:IsExists(Card.IsCode,1,nil,8124921)
			and g1:IsExists(Card.IsCode,1,nil,44519536)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,5,tp,LOCATION_DECK+LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local g1=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,nil,33396948)
	local g2=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,nil,70903634)
	local g3=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,nil,7902349)
	local g4=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,nil,8124921)
	local g5=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,nil,44519536)
	if #g1>0 and #g2>0 and #g3>0 and #g4>0 and #g5>0 then
		g:AddCard(g1:GetFirst())
		g:AddCard(g2:GetFirst())
		g:AddCard(g3:GetFirst())
		g:AddCard(g4:GetFirst())
		g:AddCard(g5:GetFirst())
		if #g==5 then
			if Duel.SendtoGrave(g,REASON_EFFECT)==5 then
				if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
				if #sg>0 then
					Duel.SpecialSummon(sg,0,tp,tp,true,true,POS_FACEUP)
					sg:GetFirst():CompleteProcedure()
				end
			end
		end
	end
end