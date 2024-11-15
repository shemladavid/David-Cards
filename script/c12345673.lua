--Balloon Party Machine
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetDescription(aux.Stringid(id,0)) -- Description for activation
    c:RegisterEffect(e1)
    --summon tokens
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.target)
    e2:SetOperation(s.activate)
    e2:SetDescription(aux.Stringid(id,1)) -- Description for token summoning
    c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
        and Duel.IsPlayerCanSpecialSummonMonster(tp,511001670,0,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_WIND) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local max_tokens = math.min(3, Duel.GetLocationCount(tp,LOCATION_MZONE))
    if max_tokens <= 0 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
    for i=1,max_tokens do
        if Duel.IsPlayerCanSpecialSummonMonster(tp,511001670,0,TYPES_TOKEN,0,0,1,RACE_MACHINE,ATTRIBUTE_WIND) then
            local token=Duel.CreateToken(tp,511001670)
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
            if i < max_tokens and not Duel.SelectYesNo(tp, aux.Stringid(id,2)) then -- Description for "Summon another token?"
                break
            end
        end
    end
    Duel.SpecialSummonComplete()
end
