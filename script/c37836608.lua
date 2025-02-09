-- Drudomancer Spirit Journey
local s,id=GetID()
function s.initial_effect(c)
    -- Activate effect: Add "Drudomancer" monster from Deck to hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- Tribute Summon by tributing 1 monster from each field, for a revealed "Drudomancer" monster
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCondition(s.otcon)
	e2:SetTarget(aux.FieldSummonProcTg(s.ottg,s.sumtg))
	e2:SetOperation(s.otop)
	e2:SetValue(SUMMON_TYPE_TRIBUTE)
	c:RegisterEffect(e2)

    -- Return monsters to hand after battle (Illusion monster)
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_BATTLE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.battlecon)
    e3:SetTarget(s.battletg)
    e3:SetOperation(s.battleop)
    c:RegisterEffect(e3)
end

-- Add "Drudomancer" monster from Deck to hand
function s.thfilter(c)
    return c:IsSetCard(0x317d) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- Tribute Summon by tributing 1 monster from each field, for a revealed "Drudomancer" monster
function s.revealfilter(c)
    return c:IsSetCard(0x317d) and c:IsMonster() and c:IsPublic()
end
function s.tgfilter(c,e)
	return c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		and Duel.IsExistingMatchingCard(s.revealfilter,tp,LOCATION_HAND,0,1,c)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,e)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,0,LOCATION_ONFIELD,1,nil,e)
end
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2 and c:IsSetCard(0x317d) and c:IsPublic()
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,c)
	local mg1=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,0,nil,e)
	local mg2=Duel.GetMatchingGroup(s.tgfilter,tp,0,LOCATION_ONFIELD,nil,e)
	::restart::
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=mg1:Select(tp,1,1,true,nil)
	if not g1 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=mg2:SelectUnselect(g1,tp,false,false,2,2)
	if mg2:IsContains(tc) then
		g1:AddCard(tc)
		g1:KeepAlive()
		e:SetLabelObject(g1)
		return true
	end
	goto restart
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.SendtoGrave(sg,REASON_EFFECT)
	sg:DeleteGroup()
end

-- Return Illusion monsters to hand after battle
function s.battlecon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsSetCard(0x317d) and Duel.GetAttackTarget()
end
function s.battletg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local g=Duel.GetMatchingGroup(Card.IsControler,tp,LOCATION_MZONE,0,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
function s.battleop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsControler,tp,LOCATION_MZONE,0,nil)
    Duel.SendtoHand(g,nil,REASON_EFFECT)
end