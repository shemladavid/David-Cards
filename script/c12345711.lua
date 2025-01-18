-- Floowandereeze and the Tranquil Sky
local s,id=GetID()
function s.initial_effect(c)
	-- Activate (negate activation and banish)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)

	-- GY effect (Normal Summon 1 Winged Beast)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and Duel.IsChainNegatable(ev) and re:IsActiveType(TYPE_MONSTER+TYPE_SPELL+TYPE_TRAP) 
		and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)~=LOCATION_DECK
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToRemove() then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,re:GetHandler(),1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_HAND+LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local sg=g:Select(tp,1,1,nil)
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end

function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Auxiliary.FaceupFilter(Card.IsRace,RACE_WINDBEAST),tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end

function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.SelectMatchingCard(tp,Auxiliary.FaceupFilter(Card.IsRace,RACE_WINDBEAST),tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
