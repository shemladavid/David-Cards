-- Xyz Free
local s, id = GetID()
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Attach opponent's deck cards
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_DETACH_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.condition)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)

    -- Destroy opponent's card
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    -- Continuous effect to attach top 3 cards of opponent's deck to an Xyz Monster with no materials
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_ADJUST)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.xyzcondition)
    e4:SetOperation(s.xyzoperation)
    c:RegisterEffect(e4)

    -- Global override: while a face-up copy of this card is on the field, 
    -- all monsters are treated as having every race and every attribute.
    if not s.global_check then
        s.global_check=true
        
        -- RACE overrides
        local oldGetRace=Card.GetRace
        Card.GetRace=function(c)
            if Duel.IsExistingMatchingCard(s.filter,0,LOCATION_SZONE,LOCATION_SZONE,1,nil) and c:IsMonster() then
                return 0xfffffff
            end
            return oldGetRace(c)
        end

        local oldGetOriginalRace=Card.GetOriginalRace
        Card.GetOriginalRace=function(c)
            if Duel.IsExistingMatchingCard(s.filter,0,LOCATION_SZONE,LOCATION_SZONE,1,nil) and c:IsMonster() then
                return 0xfffffff
            end
            return oldGetOriginalRace(c)
        end

        local oldGetPreviousRace=Card.GetPreviousRaceOnField
        Card.GetPreviousRaceOnField=function(c)
            if Duel.IsExistingMatchingCard(s.filter,0,LOCATION_SZONE,LOCATION_SZONE,1,nil)
               and (c:GetPreviousTypeOnField() & TYPE_MONSTER)~=0 then
                return 0xfffffff
            end
            return oldGetPreviousRace(c)
        end

        local oldIsRace=Card.IsRace
        Card.IsRace=function(c,r)
            if Duel.IsExistingMatchingCard(s.filter,0,LOCATION_SZONE,LOCATION_SZONE,1,nil) and c:IsMonster() then
                return true
            end
            return oldIsRace(c,r)
        end

        -- ATTRIBUTE overrides
        local oldGetAttribute=Card.GetAttribute
        Card.GetAttribute=function(c)
            if Duel.IsExistingMatchingCard(s.filter,0,LOCATION_SZONE,LOCATION_SZONE,1,nil) and c:IsMonster() then
                return 0x7f  -- Bitmask for all attributes (Earth, Water, Fire, Wind, Light, Dark, Divine)
            end
            return oldGetAttribute(c)
        end

        local oldGetOriginalAttribute=Card.GetOriginalAttribute
        Card.GetOriginalAttribute=function(c)
            if Duel.IsExistingMatchingCard(s.filter,0,LOCATION_SZONE,LOCATION_SZONE,1,nil) and c:IsMonster() then
                return 0x7f
            end
            return oldGetOriginalAttribute(c)
        end

        local oldGetPreviousAttribute=Card.GetPreviousAttributeOnField
        Card.GetPreviousAttributeOnField=function(c)
            if Duel.IsExistingMatchingCard(s.filter,0,LOCATION_SZONE,LOCATION_SZONE,1,nil)
               and (c:GetPreviousTypeOnField() & TYPE_MONSTER)~=0 then
                return 0x7f
            end
            return oldGetPreviousAttribute(c)
        end

        local oldIsAttribute=Card.IsAttribute
        Card.IsAttribute=function(c,att)
            if Duel.IsExistingMatchingCard(s.filter,0,LOCATION_SZONE,LOCATION_SZONE,1,nil) and c:IsMonster() then
                return true
            end
            return oldIsAttribute(c,att)
        end
    end
end

function s.condition(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(Card.IsType, 1, nil, TYPE_XYZ) and eg:IsExists(Card.IsControler, 1, nil, tp)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetDecktopGroup(1 - tp, Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK)) -- Get the remaining cards in opponent's deck
    if #g > 3 then
        g = Duel.GetDecktopGroup(1 - tp, 3)
    end
    -- Attach 3 new cards for each Xyz monster involved
    local processed = Group.CreateGroup() -- Track monsters that have already received cards
    for tc in aux.Next(eg) do
        if tc:IsControler(tp) and tc:IsType(TYPE_XYZ) and not processed:IsContains(tc) then
            Duel.Overlay(tc, g) -- Attach the cards to the current Xyz monster
            Duel.Recover(tp, #g * 1000, REASON_EFFECT) -- Recover life points
            processed:AddCard(tc) -- Mark this monster as processed

            -- Refresh the top 3 cards for the next monster
            g = Duel.GetDecktopGroup(1 - tp, Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK)) -- Get the remaining cards in opponent's deck
            if #g > 3 then
                g = Duel.GetDecktopGroup(1 - tp, 3)
            end
        end
    end
end

function s.descon(e, tp, eg, ep, ev, re, r, rp)
    local oppHasCard = Duel.IsExistingMatchingCard(nil, tp, 0, LOCATION_ONFIELD, 1, nil)
    local hasXyzWithOverlay = Duel.IsExistingMatchingCard(function(c) 
        return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount() > 0 
    end, tp, LOCATION_MZONE, 0, 1, nil)
    return oppHasCard and hasXyzWithOverlay
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1 - tp) end
    if chk == 0 then return Duel.IsExistingTarget(nil, tp, 0, LOCATION_ONFIELD, 1, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        local xyz = Duel.SelectMatchingCard(tp, aux.FaceupFilter(Card.IsType, TYPE_XYZ), tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
        if xyz and xyz:CheckRemoveOverlayCard(tp, 1, REASON_EFFECT) then
            xyz:RemoveOverlayCard(tp, 1, 1, REASON_EFFECT)
            Duel.Destroy(tc, REASON_EFFECT)
        end
    end
end

-- Condition to check if you control an Xyz Monster with no materials
function s.xyzcondition(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_XYZ) and c:GetOverlayCount() == 0 end, tp, LOCATION_MZONE, 0, nil)
    return #g > 0 and Duel.GetFieldGroupCount(tp, 0, LOCATION_DECK) >= 3
end

-- Operation to attach the top 3 cards of the opponent's deck to the Xyz Monster
function s.xyzoperation(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_XYZ) and c:GetOverlayCount() == 0 end, tp, LOCATION_MZONE, 0, nil)
    if #g > 0 then
        for xyz in aux.Next(g) do
            local deck_g = Duel.GetDecktopGroup(1 - tp, 3) -- Get the top 3 cards of opponent's deck
            if #deck_g > 0 then
                Duel.DisableShuffleCheck()
                Duel.Overlay(xyz, deck_g) -- Attach the cards to the Xyz monster
            end
        end
    end
end

-- Filter to check for a face-up copy of this card in the Spell & Trap Zone.
function s.filter(c)
    return c:IsFaceup() and c:IsCode(id)
end