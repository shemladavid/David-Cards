--ふわんだりぃず×えんぺん
--Floowandereeze x Bluebird
--scripted by XyLeN
local s,id=GetID()
function s.initial_effect(c)
	--Search 1 Winged Beast and Summon 1 monster from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.trsumcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Limit opponent's Extra Deck summons
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.trsumcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Banish opponent's card face-down
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(s.banishcon)
	e3:SetCost(s.banishcost)
	e3:SetTarget(s.banishtg)
	e3:SetOperation(s.banishop)
	c:RegisterEffect(e3)
end
s.listed_series={0x16f}
function s.trsumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TRIBUTE)
end
function s.thfilter(c)
	return c:IsRace(RACE_WINGEDBEAST) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sumfilter(c)
	return c:IsSummonable(true,nil)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if not g:GetFirst():IsLocation(LOCATION_HAND) then return end
		local sg=Duel.GetMatchingGroup(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			Duel.Summon(tp,sc,true,nil) 
		end
	end
end
function s.banishcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.banishcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local canBanishHand=Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil)
	local canRetrieveBanished=Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return canBanishHand or canRetrieveBanished end
	local opt=0
	if canBanishHand and canRetrieveBanished then
		opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4)) -- Option: Banish from hand or retrieve from banishment
	elseif canBanishHand then
		opt=0 -- Automatically banish from hand if retrieve is unavailable
	elseif canRetrieveBanished then
		opt=1 -- Automatically retrieve from banishment if banish is unavailable
	end
	if opt==0 then
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	else
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_REMOVED,0,1,1,nil)
		Duel.SendtoHand(g,nil,REASON_COST)
	end
end
function s.banishtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end