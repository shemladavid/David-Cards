--Abysskite Mapping
local s,id=GetID()
local SET_ABYSSKITE=0x156B
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --battle damage effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.bdcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.bdtg)
	e2:SetOperation(s.bdop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={SET_ABYSSKITE}
function s.filter(c)
	return c:IsSetCard(SET_ABYSSKITE) and c:IsMonster() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.bdconfilter(c,tp)
	return c:IsSpiritMonster() and c:IsControler(tp)
end
function s.bdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and eg:IsExists(s.bdconfilter,1,nil,tp)
end
function s.bdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and Card.IsNegatable(chkc) end
	if chk==0 then return true end
	local b1=Duel.IsExistingTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local b2=Duel.IsExistingTarget(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b3=Duel.IsExistingTarget(tp,aux.TRUE,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)},
		{b3,aux.Stringid(id,4)})
	e:SetLabel(op)
	if op==1 then
        e:SetCategory(CATEGORY_TOGRAVE)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectTarget(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_DISABLE)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
        local g=Duel.SelectTarget(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_TODECK)
        e:SetProperty(EFFECT_FLAG_CARD_TARGET)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
        Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	end
end

function s.bdop(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
	if op==1 then
		--Send 1 card on the field to the GY
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) then
            Duel.SendtoGrave(tc,REASON_EFFECT)
        end
	elseif op==2 then
		--Destroy 1 Set card on the field
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) then
            -- negate the effects / disable the card on the field
            -- try to negate any existing chains related to the card first
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)

            -- apply disabling effects (works for monsters/spells/traps on the field)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)

            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
        end
	elseif op==3 then
		--Special Summon 1 "Multi Token"
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToEffect(e) then
            Duel.ShuffleIntoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
	end
end