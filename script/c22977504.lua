--Abysskite Miracle Girls
local s,id=GetID()
local SET_ABYSSKITE=0x156B
function s.initial_effect(c)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.checkop)
	Spirit.AddProcedure(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	--Cannot be Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- normal summon itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function() return Duel.GetCustomActivityCount(id,0,ACTIVITY_CHAIN)>0 or Duel.GetCustomActivityCount(id,1,ACTIVITY_CHAIN)>0 end)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
	--Negate, to grave, and to deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP)
	c:RegisterEffect(e4)
end
s.listed_names={id}
s.listed_series={SET_ABYSSKITE}
function s.checkop(re)
	local rc=re:GetHandler()
	return not (rc:IsSetCard(SET_ABYSSKITE))
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonable(true,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,c,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Summon(tp,c,true,nil)
	end
end

function s.negfilter(c)
	return c:IsFaceup() and c:IsNegatable()
	
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.negfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc):GetFirst()

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

    -- optional: send 1 card on the field to the GY
    if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if #sg>0 then
            Duel.SendtoGrave(sg,REASON_EFFECT)
        end
    end

    -- optional: shuffle 1 card in either GY into the Deck
    if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local tg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
        if #tg>0 then
            Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    end
end
