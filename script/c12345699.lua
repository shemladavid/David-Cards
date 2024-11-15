--Cubic Plana Dimension
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --To Grave
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(s.tgcon)
    e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--To hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	--Place Cubic Counter on opponent's monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetCategory(CATEGORY_COUNTER)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(s.ctcon)
	e5:SetOperation(s.ctop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e7)
	--Check special summoned monsters' names
	aux.GlobalCheck(s,function()
		s.name_list={}
		s.name_list[0]={}
		s.name_list[1]={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s.name_list[0]={}
			s.name_list[1]={}
		end)
	end)
end
s.listed_series={0xe3}
s.counter_place_list={0x1038} --Cubic Counter ID
--Check special summoned monsters' names
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		local p=tc:GetSummonPlayer()
		table.insert(s.name_list[p],tc:GetCode())
	end
end
--Attacker filter
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe3)
end
--A cubic card to send to GY
function s.tgfilter(c)
	return c:IsSetCard(0xe3) and c:IsAbleToGrave()
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=a:GetBattleTarget()
	if not d and not a then return false end
	return (a:IsControler(tp) and a:IsSetCard(0xe3) and d and d:IsFaceup() and not d:IsControler(tp))
        or (d:IsControler(tp) and d:IsSetCard(0xe3) and a and a:IsFaceup() and not a:IsControler(tp))
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if a:IsControler(1-tp) then
        d = a  -- If the opponent is the attacker, set 'd' to 'a'
    end
    -- Set the opponent's monster's attack to 0
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
    e1:SetValue(0)
    d:RegisterEffect(e1)
	-- Ask if the player wants to send a "Cubic" card to the Graveyard
    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local sg=g:Select(tp,1,1,nil)
        if #sg>0 then
            Duel.SendtoGrave(sg,REASON_EFFECT)
        end
    end
end
--A cubic monster that cannot be normal summoned/set which can be summoned via its own procedure
function s.spfilter(c,tp)
	local code=c:GetCode()
	return c:IsControler(tp) and c:IsSetCard(0xe3) and not c:IsSummonableCard() and not table.includes(s.name_list[tp],code)
	    and c:IsProcedureSummonable(nil,0,nil,nil,nil,nil)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT>0 and re:GetHandler():IsSetCard(0xe3) and eg:IsExists(s.spfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=eg:Filter(s.spfilter,nil,tp)
		return #g>0
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local sg=eg:FilterSelect(tp,s.spfilter,1,1,nil,tp)
	Duel.SpecialSummonRule(tp,sg:GetFirst())
end
--A cubic monster that was sent to GY
function s.thfilter(c,e,tp)
	return c:IsSetCard(0xe3) and c:IsMonster() and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsAbleToHand() and c:IsPreviousSetCard(0xe3)
		and c:IsCanBeEffectTarget(e) and c:IsPreviousPosition(POS_FACEUP)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thfilter,1,nil,e,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return s.thfilter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(s.thfilter,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=eg:Filter(s.thfilter,nil,e,tp)
	local c=nil
	if #g>1 then
		c=g:Select(tp,1,1,nil):GetFirst()
	else
		c=g:GetFirst()
	end
	Duel.SetTargetCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	end
end


if not table.includes then
	--binary search
	function table.includes(t,val)
		if #t<1 then return false end
		if #t==1 then return t[1]==val end --saves sorting for efficiency
		table.sort(t)
		local left=1
		local right=#t
		while left<=right do
			local middle=(left+right)//2
			if t[middle]==val then return true
			elseif t[middle]<val then left=middle+1
			else right=middle-1 end
		end
		return false
	end
end

--Condition for placing a Cubic Counter
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	for tc in aux.Next(eg) do
		if tc:IsControler(1-tp) and tc:IsCanAddCounter(0x1038,1) then
			tc:AddCounter(0x1038,1)
			--Negate effects and prevent attack
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end