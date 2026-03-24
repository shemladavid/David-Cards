--覇王門零
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--avoid damage
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CHANGE_DAMAGE)
	e0:SetRange(LOCATION_PZONE)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetLabel(0)
	e0:SetValue(s.damval)
	c:RegisterEffect(e0)
	--copy	
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ADJUST)
	e1:SetRange(LOCATION_PZONE)
	e1:SetLabelObject(e0)
	e1:SetOperation(s.trig)
	c:RegisterEffect(e1)
	-- reveal itself in hand and search 1 "Supreme King" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.SelfReveal)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xf8}
function s.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	if val~=0 then
		e:SetLabel(val)
		return 0
	else return val end
end
function s.trig(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabelObject():GetLabel()
	if val~=0 then
		Duel.RaiseEvent(e:GetHandler(),96227613,e,REASON_EFFECT,tp,tp,val)
		e:GetLabelObject():SetLabel(0)
	end
end

function s.thfilter(c)
	return c:IsSetCard(0xf8) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,tp,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end