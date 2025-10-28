--Abysskite Emerald Halo
local s,id=GetID()
local SET_ABYSSKITE=0x156B
function s.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_TOGRAVE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ABYSSKITE}

function s.negfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ABYSSKITE) and c:IsMonster()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsChainNegatable(ev) and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		and Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		local b1=Duel.IsExistingTarget(Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        local b2=Duel.IsExistingTarget(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
        local b3=Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
        local op=Duel.SelectEffect(tp,
            {b1,aux.Stringid(id,1)},
            {b2,aux.Stringid(id,2)},
            {b3,aux.Stringid(id,3)})
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
            Duel.SetOperationInfo(0,CATEGORY_NEGATE,g,1,0,0)
        elseif op==3 then
            e:SetCategory(CATEGORY_TODECK)
            e:SetProperty(EFFECT_FLAG_CARD_TARGET)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
            local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
            Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
        end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
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
end