--Declare 1 card name; banish this card and let that card appear in your hand. If you activate that card's effect, after it resolves: Add this banished card to your hand.
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Declare a card name
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
    local code=Duel.AnnounceCard(tp)

    -- Banish this card
    if Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)~=0 then
        -- Create the declared card in the player's hand
        local token=Duel.CreateToken(tp,code)
        Duel.SendtoHand(token,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,token)

        -- Apply a flag to the declared card with a hint
        token:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
        token:RegisterFlagEffect(id,0,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0)) -- Add hint for the card

        -- Add the banished card to your hand after the declared card's effect resolves
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_CHAIN_SOLVED)
        e1:SetCondition(s.thcon)
        e1:SetOperation(s.thop)
        e1:SetLabelObject(token)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    -- Check if the activated card has the flag
    return re:GetHandler():GetFlagEffect(id) > 0
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    
    -- Return the banished card to the hand if it's still banished
    if c:IsLocation(LOCATION_REMOVED) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
    end
end