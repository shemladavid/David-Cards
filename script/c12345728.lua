--Gunkan Suship Buffet
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Place "Gunkan" card on top of deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(s.dtcon)
	e1:SetTarget(s.dttg)
	e1:SetOperation(s.dtop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
    -- Revael and add 2 "Gunkan" mention cards from your deck to your hand
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
    c:RegisterEffect(e3)
    --negate
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCountLimit(1,{id,1})
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCondition(s.ngcon)
	e4:SetTarget(s.ngtg)
	e4:SetOperation(s.ngop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_GUNKAN}
s.listed_names={CARD_SUSHIP_SHARI}
function s.cfilter(c,tp)
	return c:IsMonster() and c:IsSetCard(SET_GUNKAN) and c:IsSummonPlayer(tp)
end
function s.dtcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.dttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,SET_GUNKAN) end
end
function s.dtop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,SET_GUNKAN):GetFirst()
	if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,0)
		Duel.ConfirmDecktop(tp,1)
	end
end

function s.costfilter(c)
	return c:IsCode(CARD_SUSHIP_SHARI) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.shipfilter(c)
	return c:IsSetCard(SET_GUNKAN) and c:IsType(TYPE_XYZ) and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.shipfilter,tp,LOCATION_EXTRA,0,1,nil) end
	local c=e:GetHandler()
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
function s.spfilter(c, sc)
    local codes = sc.material or sc.listed_names
    if not codes then return false end
    return c:IsSetCard(SET_GUNKAN) and c:IsMonster() and c:IsAbleToHand() and c:IsCode(table.unpack(codes))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local xc = Duel.SelectMatchingCard(tp, s.shipfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil):GetFirst()
    if not xc then return end
    Duel.ConfirmCards(1-tp, xc)

    -- get all valid deck targets
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_DECK, 0, nil, xc)
    if #g < 2 then return end

    -- first pick
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local sg = Group.CreateGroup()
    local first = g:Select(tp, 1, 1, nil)
    sg:Merge(first)

    -- remove that code, then pick a different one
    local firstCode = first:GetFirst():GetCode()
    local g2 = g:Filter(
        function(c) return c:GetCode()~=firstCode end,
        nil
    )
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local second = g2:Select(tp, 1, 1, nil)
    sg:Merge(second)

    -- add both to hand
    Duel.SendtoHand(sg, nil, REASON_EFFECT)
    Duel.ConfirmCards(1-tp, sg)
end

function s.ngfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GUNKAN) and c:IsType(TYPE_XYZ)
end
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.ngfilter,tp,LOCATION_MZONE,0,1,nil) and rp~=tp 
	and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end