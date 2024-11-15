-- Chimera Hydradrive Draghead - Lightning
local s,id=GetID()

function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_LINK),5,5,s.lcheck)
	c:EnableReviveLimit()
    -- Special Summon effect
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end

s.listed_series={0x577}
s.listed_names={49372007}

function s.lcheck(g,lc,sumtype,tp)
	return g:CheckDifferentPropertyBinary(Card.GetAttribute,lc,sumtype,tp)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
    local ct=#g
    if ct==0 then return end
    if ct<=2 then
        -- If opponent has 2 or less cards, shuffle all into the Deck
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(1-tp)
    else
        -- If opponent has 3 or more cards, reveal and select 2 to shuffle
        Duel.ConfirmCards(tp,g)
        local sg=g:Select(tp,2,2,nil)
        Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(1-tp)
        Duel.ShuffleHand(1-tp)
    end
    -- Immediately return to Extra Deck and Special Summon from Extra Deck
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_MZONE) then
        Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
        local sc=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_EXTRA,0,nil,49372007)
        if sc then
            Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end