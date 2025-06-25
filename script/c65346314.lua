--Asherah, the Old Goddess of Nature
local s,id=GetID()
local SET_OLD_GOD=0x653 
function s.initial_effect(c)
	-- Fusion Material
	c:EnableReviveLimit()
    Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_OLD_GOD),1,1,Synchro.NonTunerEx(Card.IsSetCard,SET_OLD_GOD),1,99)
    -- Treat "Old God" monsters you control as Level 6 for this card's Synchro Summon
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e0:SetCode(EFFECT_SYNCHRO_LEVEL)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetTarget(function(e,c) return c:IsSetCard(SET_OLD_GOD) end)
    e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetValue(function(e,sc) return 6 end)
    c:RegisterEffect(e0)
    -- Must be synchro Summoned or Special Summoned by an "Old God" card
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0a:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0a:SetValue(s.splimit)
	c:RegisterEffect(e0a)
    -- monsters you control cannot be destroyed by battle
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    -- discard 1 random card from your opponent's hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_HANDES)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.distg)
    e2:SetOperation(s.disop)
    c:RegisterEffect(e2)
    --Tribute 1 "Old God"; banish 1 card from your opponent's control
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.rmcost)
    e3:SetTarget(s.rmtg)
    e3:SetOperation(s.rmop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_OLD_GOD}
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
            or (se:IsHasType(EFFECT_TYPE_ACTIONS) and se:GetHandler():IsSetCard(SET_OLD_GOD))
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND,nil)
	if #g==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	Duel.SendtoGrave(sg,REASON_DISCARD|REASON_EFFECT)
end

function s.costfilter(c)
    return c:IsSetCard(SET_OLD_GOD) and c:IsReleasable()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil) end
    local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil)
    Duel.Release(g,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end