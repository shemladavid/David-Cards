--Abysskite Ravine
local s,id=GetID()
local SET_ABYSSKITE=0x156B
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
    --Abysskite monsters you control can attack directly
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DIRECT_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ABYSSKITE))
    c:RegisterEffect(e2)
    -- if a Abysskite normal trap is activated, send to GY
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_FZONE)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
    e3:SetCondition(s.condition)
    e3:SetTarget(s.stgtg)
    e3:SetOperation(s.stgop)
    c:RegisterEffect(e3)
    -- if a Abysskite normal trap is activated, negate
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_DISABLE)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_FZONE)
    e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e4:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
    e4:SetCondition(s.condition)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)
    -- if a Abysskite normal trap is activated, shuffle into deck from GY
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_TODECK)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_FZONE)
    e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e5:SetCountLimit(1,id,EFFECT_COUNT_CODE_CHAIN)
    e5:SetCondition(s.condition)
    e5:SetTarget(s.stdtg)
    e5:SetOperation(s.stdop)
    c:RegisterEffect(e5)
end
s.listed_names={id}
s.listed_series={SET_ABYSSKITE}

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsSetCard(SET_ABYSSKITE) and rc:IsType(TYPE_TRAP) and rc:IsOriginalType(TYPE_NORMAL)
end
function s.stgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and Card.IsAbleToGrave(chkc) end
    if chk==0 then return Duel.GetFlagEffect(tp,22977513)==0 and Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.stgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
    -- mark that this effect has been used this turn
    Duel.RegisterFlagEffect(tp,22977513,RESET_PHASE+PHASE_END,0,1)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and Card.IsNegatable(chkc) end
	if chk==0 then return Duel.GetFlagEffect(tp,22977514)==0 and Duel.IsExistingTarget(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
	local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.NegateRelatedChain(tc,RESET_TURN_SET) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
    -- mark that this effect has been used this turn
    Duel.RegisterFlagEffect(tp,22977514,RESET_PHASE+PHASE_END,0,1)
end

function s.stdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and aux.TRUE(chkc) end
	if chk==0 then return Duel.GetFlagEffect(tp,22977515)==0 and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.stdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.ShuffleIntoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
    -- mark that this effect has been used this turn
    Duel.RegisterFlagEffect(tp,22977515,RESET_PHASE+PHASE_END,0,1)
end