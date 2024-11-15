--Dark Scorpion Heist
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --Banish
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.rmcon)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--Apply effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.applytg)
	e3:SetOperation(s.applyop)
	c:RegisterEffect(e3)
    --to hand
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
s.listed_names={76922029}
s.listed_series={0x1a}
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=eg:GetFirst()
	return ep~=tp and rc:IsControler(tp) and rc:IsCode(76922029) or rc:IsSetCard(0x1a)
end
function s.filter(c)
    return c:IsFaceup() and c:IsCode(76922029) or (c:IsSetCard(0x1a) and c:IsType(TYPE_MONSTER))
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=ct*2
		and Duel.GetDecktopGroup(1-tp,ct*2):FilterCount(Card.IsAbleToRemove,nil)==ct*2 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct*2,1-tp,LOCATION_DECK)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	local g=Duel.GetDecktopGroup(1-tp,ct*2)
	if #g==ct*2 then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end

function s.applyfilter(c)
	return c:GetAttackAnnouncedCount()==0 and c:IsFaceup() and (c:IsCode(76922029) or (c:IsSetCard(0x1a) and c:IsMonster()))
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	if chk==0 then return Duel.IsExistingTarget(s.applyfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.applyfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local op=0
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	--Take no battle damage involving it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3210)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	if tc:IsCode(76922029) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76922029,0))
		if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.IsPlayerCanDiscardDeck(1-tp,2) then
			op=Duel.SelectOption(tp,aux.Stringid(76922029,1),aux.Stringid(76922029,2))
		elseif Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 then
			Duel.SelectOption(tp,aux.Stringid(76922029,1))
			op=0
		else
			Duel.SelectOption(tp,aux.Stringid(76922029,2))
			op=1
		end
		if op==0 then
			local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND,nil)
			local sg=g:RandomSelect(tp,1)
			Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
		else
			Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
		end
	end
	if tc:IsCode(48768179) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48768179,0))
		if Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,nil)
			and Duel.IsPlayerCanDiscardDeck(1-tp,1) then
			op=Duel.SelectOption(tp,aux.Stringid(48768179,1),aux.Stringid(48768179,2))
		elseif Duel.IsPlayerCanDiscardDeck(1-tp,1) then
			Duel.SelectOption(tp,aux.Stringid(48768179,2))
			op=1
		else
			Duel.SelectOption(tp,aux.Stringid(48768179,1))
			op=0
		end
		if op==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_MZONE,1,1,nil)
			Duel.HintSelection(g)
			Duel.SendtoDeck(g,nil,0,REASON_EFFECT)
		else
			Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
		end
	end
	if tc:IsCode(74153887) then
		if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0x1a) and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0x1a) then
		    op=Duel.SelectOption(tp,aux.Stringid(74153887,1),aux.Stringid(74153887,2))
	    elseif Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0x1a) then
		    Duel.SelectOption(tp,aux.Stringid(74153887,1))
		    op=0
		elseif Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,nil,0x1a) then
		    Duel.SelectOption(tp,aux.Stringid(74153887,2))
		    op=1
	    end
	    if op==0 then
		    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		    local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0x1a)
		    if #g>0 then
			    Duel.SendtoHand(g,nil,REASON_EFFECT)
			    Duel.ConfirmCards(1-tp,g)
		    end
	    else
		    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		    local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_GRAVE,0,1,1,nil,0x1a)
		    Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
	if tc:IsCode(6967870) then
		if Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.IsPlayerCanDiscardDeck(1-tp,2) then
		    op=Duel.SelectOption(tp,aux.Stringid(6967870,1),aux.Stringid(6967870,2))
	    elseif Duel.IsPlayerCanDiscardDeck(1-tp,2) then
		    Duel.SelectOption(tp,aux.Stringid(6967870,2))
		    op=1
	    else
		    Duel.SelectOption(tp,aux.Stringid(6967870,1))
		    op=0
	    end
	    if op==0 then
		    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		    local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		    Duel.HintSelection(g)
		    Duel.Destroy(g,REASON_EFFECT)
	    else
		    Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
	    end
	end
	if tc:IsCode(61587183) then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(61587183,0))
		if Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 then
			op=Duel.SelectOption(tp,aux.Stringid(61587183,1),aux.Stringid(61587183,2))
		elseif Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 then
			Duel.SelectOption(tp,aux.Stringid(61587183,2))
			op=1
		else
			Duel.SelectOption(tp,aux.Stringid(61587183,1))
			op=0
		end
		if op==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
			Duel.HintSelection(g)
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		else
			local g=Duel.GetDecktopGroup(1-tp,1)
			if #g>0 then
				Duel.ConfirmCards(tp,g)
				Duel.Hint(HINT_SELECTMSG,tp,0)
				local ac=Duel.SelectOption(tp,aux.Stringid(61587183,3),aux.Stringid(61587183,4))
				if ac==1 then Duel.MoveSequence(g:GetFirst(),1) end
			end
		end
	end
	if tc:IsCode(40933924) then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(1-tp,Card.IsSpell,1-tp,LOCATION_DECK,0,1,1,nil)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	if tc:IsCode(210490001) then
		local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_MZONE,0,nil)
		local ct=g:GetClassCount(Card.GetCode)
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function s.setfilter(c)
	return c:IsSetCard(0x1a) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SSet(tp,tc) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		if tc:IsQuickPlaySpell() then
			e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
		elseif tc:IsTrap() then
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		end
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end