-- Chimera Hydradrive Draghead - AI
local s,id=GetID()

function s.initial_effect(c)
    -- Link Summon
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_LINK),5,5,s.lcheck)
    c:EnableReviveLimit()

    -- Special Summon effect
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
end
s.listed_series={0x577}
s.listed_names={49372007}

function s.lcheck(g,lc,sumtype,tp)
    return g:CheckDifferentPropertyBinary(Card.GetAttribute,lc,sumtype,tp)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Shuffle opponent's GY and banish zone into the Deck
    local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE+LOCATION_REMOVED)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(1-tp)
    end

    -- Immediately return to Extra Deck and Special Summon from Extra Deck
    if c:IsLocation(LOCATION_MZONE) then
        Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.ShuffleDeck(tp)
        local sc=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_EXTRA,0,nil,49372007)
        if sc then
            Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end