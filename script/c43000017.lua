--Elemental HERO Storming Thunder Giant
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
    
	-- Fusion material
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)

	-- Effect 1: Discard to destroy a target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.descost)
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)

	-- Effect 2: Negate effects of face-up opponent's cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(s.nop)
	c:RegisterEffect(e2)
end

s.listed_series={0x3008}

-- Fusion materials
function s.ffilter(c,fc,sumtype,tp,sub,mg,sg)
	return c:IsSetCard(0x3008,fc,sumtype,tp) and c:GetAttribute(fc,sumtype,tp)~=0 and (not sg or not sg:IsExists(s.fusfilter,1,c,c:GetAttribute(fc,sumtype,tp),fc,sumtype,tp))
end

function s.fusfilter(c,attr,fc,sumtype,tp)
	return c:IsAttribute(attr,fc,sumtype,tp)
end

-- Effect 1: Discard 1 card; banish 1 card your opponent controls. If the discarded card was an “Elemental HERO” monster, add up to 2 cards from your GY to your hand.
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
		e:SetLabelObject(g:GetFirst())
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,0) -- Update to ensure no invalid state
	end
end

function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if g and #g>0 then
		local tc=g:GetFirst()
		if tc:IsRelateToEffect(e) then
			if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
				local discarded=e:GetLabelObject()
				if discarded and discarded:IsSetCard(0x3008) then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
					local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_GRAVE,0,1,2,nil)
					if g and #g>0 then
						Duel.SendtoHand(g,nil,REASON_EFFECT)
						Duel.ConfirmCards(1-tp,g)
					else
						Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,0,0) -- Update to ensure no invalid state
					end
				end
			end
		end
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,0,0) -- Update to ensure no invalid state
	end
end

-- Effect 2: Negate effects of face-up opponent's cards
function s.nop(e,tp,eg,ep,ev,re,r,rp)
	local ng=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	if #ng>0 then
		for tcn in aux.Next(ng) do
			-- Negate opponent's face-up cards
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
			tcn:RegisterEffect(e1)
		end
	end
end
