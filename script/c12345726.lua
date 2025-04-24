-- Gunkan Suship Unagi
local s, id = GetID()
function s.initial_effect(c)
    -- Special Summon both 1 "Gunkan" monster from your Deck and this card from your hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    -- Change targeted "Gunkan" monster's level to 4 or 5
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_LVCHANGE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)
end
s.listed_series = {0x168}
function s.spcostfilter(c, e, tp)
    return c:IsSetCard(0x168) and c:IsType(TYPE_XYZ) and not c:IsPublic() and
               Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp, c:GetRank())
end
function s.spfilter(c, e, tp, rank)
    return c:IsSetCard(0x168) and c:IsLevel(rank) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function s.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0 and
                   Duel.IsExistingMatchingCard(s.spcostfilter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local rc = Duel.SelectMatchingCard(tp, s.spcostfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    e:SetLabel(rc:GetRank())
    Duel.ConfirmCards(1 - tp, rc)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return
            not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp, LOCATION_MZONE) >=
                2 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 2, tp, LOCATION_HAND | LOCATION_DECK)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 then
        return
    end
    local c = e:GetHandler()
    if not (c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)) then
        return
    end
    local rank = e:GetLabel()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp, rank)
    if #g > 0 then
        Duel.SpecialSummon(g + c, 0, tp, tp, false, false, POS_FACEUP)
    end
end

-- Check for a "Gunkan" monster with a level
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_GUNKAN) and c:HasLevel()
end
	--Activation legality
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
	--Check for "Gunkan Suship Shari" to add
function s.thfilter(c)
	return c:IsSetCard(0x168) and c:IsAbleToHand()
end
	--Change targeted "Gunkan" monster's level to 4 or 5
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local lv=Duel.AnnounceLevel(tp,4,5,tc:GetLevel())
		--Change Level
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end