--Ultimate Counter
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and Duel.IsChainNegatable(i) then
			return true
		end
	end
	return false
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ng=Group.CreateGroup()
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and Duel.IsChainNegatable(i) then
			local tc=te:GetHandler()
			ng:AddCard(tc)
			if tc:IsRelateToEffect(te) then
				dg:AddCard(tc)
			end
		end
	end
	Duel.SetTargetCard(dg)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,ng,#ng,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,dg,#dg,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dg=Group.CreateGroup()
	for i=1,ev do
		local te,tgp=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
		if tgp~=tp and Duel.NegateActivation(i) then
			local tc=te:GetHandler()
			if tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then
				tc:CancelToGrave()
				dg:AddCard(tc)
			end
		end
	end
	Duel.SendtoDeck(dg,nil,2,REASON_EFFECT)
	Duel.BreakEffect()
    if not c:IsRelateToEffect(e) then return end
    if c:IsSSetable(true) and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
        Duel.BreakEffect()
        c:CancelToGrave()
        Duel.ChangePosition(c,POS_FACEDOWN)
        Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
    end
end