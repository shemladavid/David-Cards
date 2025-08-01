--The Seal Of Orichalcos
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PREDRAW)
		e1:SetCondition(s.flipcon)
		e1:SetOperation(s.flipop)
		Duel.RegisterEffect(e1,tp)
	end
	e:SetLabel(1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return Duel.GetCurrentChain()==0 and Duel.GetTurnCount()==1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	local c=e:GetHandler()
	-- ATK boost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(500)
	Duel.RegisterEffect(e1,tp)
	-- ATK boost for 4280258
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetTargetRange(LOCATION_MZONE,0)
	e1a:SetTarget(aux.TargetBoolFunction(Card.IsCode,4280258))
	e1a:SetValue(500)
	Duel.RegisterEffect(e1a,tp)
	-- Spell/Trap cannot be Targeted
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetValue(aux.tgoval)
	Duel.RegisterEffect(e2,tp)
	-- Indestructible count for Spell/Traps
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetValue(s.indct)
	Duel.RegisterEffect(e3,tp)
	-- Destruction replacement effect for monsters
	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SEND_REPLACE)
	e4:SetTargetRange(LOCATION_MZONE, 0)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	Duel.RegisterEffect(e4, tp)
	-- Draw a card when losing LP or paying LP
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_DAMAGE)
	e5:SetCondition(s.drcon)
	e5:SetOperation(s.drop)
	Duel.RegisterEffect(e5,tp)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PAY_LPCOST)
	e6:SetCondition(s.drcon)
	e6:SetOperation(s.drop)
	Duel.RegisterEffect(e6,tp)
	-- Gain LP during Standby Phase
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e7:SetCountLimit(1)
	e7:SetCondition(s.lpcon)
	e7:SetOperation(s.lpop)
	Duel.RegisterEffect(e7,tp)
	-- Summon without tribute
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id, 0))
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_SUMMON_PROC)
	e8:SetTargetRange(LOCATION_HAND,0)
	e8:SetCondition(s.ntcon)
	e8:SetTarget(aux.FieldSummonProcTg(function(e,c) return c:IsLevelAbove(5) end))
	e8:SetValue(SUMMON_TYPE_TRIBUTE)
	Duel.RegisterEffect(e8,tp)
	local e9=e8:Clone()
	e9:SetCode(EFFECT_SET_PROC)
	Duel.RegisterEffect(e9,tp)
	-- No limit on Normal Summons
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD)
	e10:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e10:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e10:SetTargetRange(1,0)
	e10:SetValue(99)
	Duel.RegisterEffect(e10,tp)
	-- Draw until you have 4 cards
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e11:SetCode(EVENT_PREDRAW)
	e11:SetCondition(s.drcon2)
	e11:SetOperation(s.drop2)
	Duel.RegisterEffect(e11,tp)
	-- No limit to hand size
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_FIELD)
	e12:SetCode(EFFECT_HAND_LIMIT)
	e12:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e12:SetTargetRange(1,0)
	e12:SetValue(99)
	Duel.RegisterEffect(e12,tp)
	-- Shuffle and draw during Standby Phase
	local e13=Effect.CreateEffect(c)
	e13:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e13:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e13:SetCountLimit(1)
	e13:SetCondition(s.stbcon)
	e13:SetOperation(s.stbop)
	Duel.RegisterEffect(e13,tp)
	-- Reveal opponent's hand
	local e14=Effect.CreateEffect(c)
	e14:SetType(EFFECT_TYPE_FIELD)
	e14:SetCode(EFFECT_PUBLIC)
	e14:SetTargetRange(0,LOCATION_HAND)
	Duel.RegisterEffect(e14,tp)
	-- Once per turn, you can look at your deck and add 1 card to the hand
	local e15=Effect.CreateEffect(c)
	e15:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e15:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e15:SetCountLimit(1)
	e15:SetCondition(s.lookcon)
	e15:SetOperation(s.lookop)
	Duel.RegisterEffect(e15,tp)
	-- Make effects activated by this card inactivatable and non-diseffectable
	local e16=Effect.CreateEffect(c)
	e16:SetType(EFFECT_TYPE_FIELD)
	e16:SetCode(EFFECT_CANNOT_INACTIVATE)
	e16:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e16:SetTargetRange(1,0)
	e16:SetValue(s.effectfilter)
	Duel.RegisterEffect(e16,tp)
	local e17=Effect.CreateEffect(c)
	e17:SetType(EFFECT_TYPE_FIELD)
	e17:SetCode(EFFECT_CANNOT_DISEFFECT)
	e17:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e17:SetTargetRange(1,0)
	e17:SetValue(s.effectfilter)
	Duel.RegisterEffect(e17,tp)
	-- Prevent Tributing
	local e18=Effect.CreateEffect(c)
	e18:SetType(EFFECT_TYPE_FIELD)
	e18:SetCode(EFFECT_CANNOT_RELEASE)
	e18:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e18:SetTargetRange(0,1)
    e18:SetTarget(s.releaseTarget)
	Duel.RegisterEffect(e18,tp)
	-- Prevent using your monsters for Link Summon
	local e19=Effect.CreateEffect(c)
	e19:SetType(EFFECT_TYPE_FIELD)
	e19:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e19:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e19:SetTargetRange(LOCATION_MZONE,0)
	e19:SetValue(s.linklimit)
	Duel.RegisterEffect(e19,tp)
	-- -- Flip Decks face-up
	-- local e20=Effect.CreateEffect(c)
	-- e20:SetType(EFFECT_TYPE_FIELD)
	-- e20:SetCode(EFFECT_REVERSE_DECK)
	-- e20:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	-- e20:SetValue(1)
	-- Duel.RegisterEffect(e20,tp)
	--Spirit monster do not have to return to the hand
	local e21=Effect.CreateEffect(c)
	e21:SetType(EFFECT_TYPE_FIELD)
	e21:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
	e21:SetTargetRange(LOCATION_MZONE,0)
	Duel.RegisterEffect(e21,tp)

	if not s.global_check then
		s.global_check=true
		s.atk_map={}
		s.def_map={}
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.track_atk)
		Duel.RegisterEffect(ge1,0)
	end
	local e22=Effect.CreateEffect(c)
	e22:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e22:SetCode(511001265)
	e22:SetOperation(s.atklossop)
	Duel.RegisterEffect(e22,tp)
end

function s.atkcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttackPos),e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil)
end

function s.indct(e,re,r,rp)
	if (r&REASON_EFFECT~=0 or r&REASON_BATTLE~=0) and rp~=e:GetHandlerPlayer() then
		return 1
	else 
		return 0 
	end
end

function s.repfilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
    and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) and c:GetReasonPlayer()~=tp
end

-- Target function: Check if any monsters match the filter to apply the replacement effect
function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return eg:IsExists(s.repfilter, 1, nil, tp) end
	return true
end
	
-- Replacement effect: Increase ATK and DEF by 20% instead of being sent to the GY
function s.repval(e, c)
	if c:GetControler() ~= e:GetHandlerPlayer() then return false end
    local atk = c:GetAttack()
    local def = c:GetDefense()
    local atk_increase = atk * 1.2
	local def_increase = def * 1.2
	atk_increase = math.ceil(atk_increase / 100) * 100
	def_increase = math.ceil(def_increase / 100) * 100
    new_atk = atk_increase - atk
	new_def = def_increase - def

    -- Increase ATK
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(new_atk)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(e1)
    
    -- Increase DEF
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetValue(new_def)
    e2:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(e2)
    
    return true
end

function s.sunvinefilter(c)
    return c:IsSetCard(0x574) or c:IsSetCard(0x575) or c:IsSetCard(0x4157) or c:IsSetCard(0x1157) or c:IsSetCard(0x2157) or c:IsSetCard(0xc9) or c:IsCode(511009675)
end

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>0 and not Duel.IsExistingMatchingCard(s.sunvinefilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end

function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)>0
end

function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(s.sunvinefilter,tp,LOCATION_MZONE,0,1,nil) then	
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
		local current_lp = Duel.GetLP(tp)
		Duel.SetLP(tp, current_lp + ct*500)
	else
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
		if ct>0 then
			Duel.Recover(tp,ct*500,REASON_EFFECT)
		end
	end
end

function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return minc==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)<4
end

function s.drop2(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local ct=4-hg:GetCount()-1
	if ct>0 then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end

function s.stbcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.stbop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,99,nil)
		if g:GetCount()>0 then
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			Duel.ShuffleDeck(tp)
			Duel.Draw(tp,g:GetCount(),REASON_EFFECT)
		end
	end
end

function s.lookcon(e,tp,eg,ep,ev,re,r,rp)
	-- Check if it's the player's turn and ensure it's not already activated this turn
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(id)==0
end

function s.lookop(e,tp,eg,ep,ev,re,r,rp)
	-- Prevent multiple activations per turn
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	
	-- Declare 1 card name and create that card in hand
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		local ac=Duel.AnnounceCard(tp)
		local token=Duel.CreateToken(tp,ac)
		Duel.SendtoHand(token,nil,REASON_EFFECT)
	end
end

function s.effectfilter(e,ct)
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return tp==e:GetHandlerPlayer() and (loc&LOCATION_ONFIELD~=0 or loc&LOCATION_HAND~=0 or loc&LOCATION_GRAVE~=0)
end

function s.releaseTarget(e,c)
    return c:IsControler(e:GetHandlerPlayer())
end

function s.linklimit(e,c)
    if not c then return false end
    return c:IsControler(1-e:GetHandlerPlayer())
end

function s.track_atk(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,0,nil)
    for tc in g:Iter() do
        local fid=tc:GetFieldID()
        local atk=tc:GetAttack()
        local def=tc:GetDefense()

        local prev_atk = s.atk_map[fid]
        if prev_atk == nil then
            s.atk_map[fid] = atk
        elseif atk ~= prev_atk then
            if tc:IsControler(tp) and atk < prev_atk then
                Duel.RaiseEvent(tc,511001265,e,REASON_EFFECT,tp,tp,0)
            end
            s.atk_map[fid] = atk
        end

        local prev_def = s.def_map[fid]
        if prev_def == nil then
            s.def_map[fid] = def
        elseif def ~= prev_def then
            if tc:IsControler(tp) and def < prev_def then
                Duel.RaiseEvent(tc,511001265,e,REASON_EFFECT,tp,tp,0)
            end
            s.def_map[fid] = def
        end
    end
end

function s.atklossop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    for tc in eg:Iter() do
        if tc:IsFaceup() and tc:IsControler(tp) then
            local fid=tc:GetFieldID()

            -- ATK loss compensation
            local prev_atk=s.atk_map[fid]
            if prev_atk and tc:GetAttack()<prev_atk then
                local diff=prev_atk - tc:GetAttack()
                Duel.Hint(HINT_CARD,0,id)
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(diff + 1000)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
                tc:RegisterEffect(e1)
                s.atk_map[fid]=tc:GetAttack()
            end

            -- DEF loss compensation
            local prev_def=s.def_map[fid]
            if prev_def and tc:GetDefense()<prev_def then
                local diff=prev_def - tc:GetDefense()
                Duel.Hint(HINT_CARD,0,id)
                local e2=Effect.CreateEffect(c)
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_UPDATE_DEFENSE)
                e2:SetValue(diff + 1000)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
                tc:RegisterEffect(e2)
                s.def_map[fid]=tc:GetDefense()
            end
        end
    end
end
