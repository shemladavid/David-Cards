--聖天樹の開花
--Sunavalon Bloom
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Gains ATK equal to the total ATK of the monster the link monster points to
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
    --negate monster effects your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCondition(s.disablecon)
	c:RegisterEffect(e3)
end

function s.atkfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_LINK) and c:GetLinkedGroup():Filter(Card.IsFaceup,nil):GetSum(Card.GetAttack)>0
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttackTarget()
	local tc=Duel.GetAttacker()
	if not tc:IsControler(tp) then tc,bc=bc,tc end
	if not tc then return end
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and s.atkfilter(tc) and (not bc or bc:IsControler(1-tp))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e)
		and tc:IsControler(tp) and s.atkfilter(tc) then
		local lg=tc:GetLinkedGroup():Filter(Card.IsFaceup,nil)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lg:GetSum(Card.GetAttack))
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end

function s.disablecon(e)
	return Duel.IsExistingMatchingCard(
		function(c) return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsRace(RACE_PLANT) and c:IsLinkAbove(4) end,
		e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil
	)
end