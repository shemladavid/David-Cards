--Luck Manipulator
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    local e10=Effect.CreateEffect(c)
	e10:SetOperation(s.actb)
	e10:SetCost(s.descost)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e10:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e10:SetRange(LOCATION_DECK)
	e10:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	c:RegisterEffect(e10)
	--acthand
	local e20=Effect.CreateEffect(c)
	e20:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e20:SetRange(LOCATION_HAND)
	e20:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e20:SetOperation(s.actb)
	e20:SetCost(s.descost)
	e20:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	c:RegisterEffect(e20)
	--actgrave
	local e30=Effect.CreateEffect(c)
	e30:SetOperation(s.actb)
	e30:SetCost(s.descost)
	e30:SetRange(LOCATION_GRAVE)
	e30:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e30:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e30:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	c:RegisterEffect(e30)
	--actremoved
	local e40=Effect.CreateEffect(c)
	e40:SetOperation(s.actb)
	e40:SetCost(s.descost)
	e40:SetRange(LOCATION_REMOVED)
	e40:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e40:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e40:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	c:RegisterEffect(e40)
    
    -- Change dice result
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_TOSS_DICE_NEGATE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetOperation(s.diceop)
    c:RegisterEffect(e2)
    
    -- Change coin result
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_TOSS_COIN_NEGATE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetOperation(s.coinop)
    c:RegisterEffect(e3)

    --Cost Change
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_LPCOST_CHANGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1,0)
	e4:SetValue(s.costchange)
	c:RegisterEffect(e4)
end

function s.actb(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetActivateEffect():IsActivatable(tp) end
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_FZONE,POS_FACEUP,REASON_EFFECT,true)
end

function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end

function s.diceop(e,tp,eg,ep,ev,re,r,rp)
    local diceNum = {}
    for i=1, ev do
        local num = Duel.AnnounceNumber(tp,1,2,3,4,5,6)
        diceNum[i] = num
    end
    Duel.SetDiceResult(table.unpack(diceNum))
end

function s.coinop(e,tp,eg,ep,ev,re,r,rp)
    local coinResults = {}
    for i=1, ev do
        local res = Duel.SelectOption(tp, 60, 61) -- 60 is HEADS, 61 is TAILS
        coinResults[i] = res == 0 and 1 or 0 -- Switch between 1 (HEADS) and 0 (TAILS)
    end
    Duel.SetCoinResult(table.unpack(coinResults))
end

function s.costchange(e,re,rp,val)
	if re and not mustpay then
		return 0
	else
		return val
	end
end