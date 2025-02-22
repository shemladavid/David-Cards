-- Continuous Spell: "Universal Race & Attribute" Spell
local s,id=GetID()
function s.initial_effect(c)
    -- Activate the continuous spell normally.
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
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

-- Filter to check for a face-up copy of this card in the Spell & Trap Zone.
function s.filter(c)
    return c:IsFaceup() and c:IsCode(id)
end
