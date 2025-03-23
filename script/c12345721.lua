-- Sword of the Scareclaw
local s, id = GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Link Summon Procedure
    Link.AddProcedure(c, nil, 2, 2, s.lcheck)
    -- Search 1 "Scareclaw" card from your Deck to your hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SEARCH + CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    -- Used as material
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.lkcon)
    e2:SetOperation(s.lkop)
    c:RegisterEffect(e2)
    --Special Summon 1 "Scareclaw" monster from your GY
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end
s.listed_names = {CARD_VISAS_STARFROST}
s.listed_series = {SET_SCARECLAW}
function s.lcheck(g, lc, sumtype, tp)
    return g:IsExists(Card.IsSetCard, 1, nil, SET_SCARECLAW, lc, sumtype, tp) or
               g:IsExists(Card.IsCode, 1, nil, CARD_VISAS_STARFROST, lc, sumtype, tp)
end
function s.thcon(e)
    local c = e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_LINK)
end
function s.thfilter(c)
    return c:IsSetCard(SET_SCARECLAW) and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
function s.lkcon(e, tp, eg, ep, ev, re, r, rp)
    local rc = e:GetHandler():GetReasonCard()
    return rc:IsSetCard(SET_SCARECLAW) and r == REASON_LINK
end
function s.lkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    -- Create an effect that negates the effects of all opponent's Defense Position monsters.
    local e1 = Effect.CreateEffect(rc)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetTargetRange(0, LOCATION_MZONE)
	e1:SetTarget(s.distg)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
    Duel.RegisterEffect(e1, tp)
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTargetRange(0, LOCATION_MZONE)
	e2:SetTarget(s.distg)
	e2:SetReset(RESET_EVENT + RESETS_STANDARD)
	rc:RegisterEffect(e2, tp)
end
function s.distg(e,c)
    return c:IsFaceup() and c:IsPosition(POS_FACEUP_DEFENSE)
end
function s.spfilter(c, e, tp)
    return c:IsSetCard(SET_SCARECLAW) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end