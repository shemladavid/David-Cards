--Void Collapse
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
local EXCLUDED_CODE = 95453143
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
    local g2=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
    local g=Group.CreateGroup()
    g:Merge(g1)
    g:Merge(g2)
    local sg=g:Filter(function(c) return c:GetCode()~=EXCLUDED_CODE end,nil)
    if #sg==0 then return end
    Duel.SendtoGrave(sg,REASON_EFFECT)
end