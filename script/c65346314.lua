--Asherah, the Old Goddess of Nature
local s,id=GetID()
local SET_OLD_GOD=0x653 
function s.initial_effect(c)
	-- Fusion Material
	c:EnableReviveLimit()
    Synchro.AddProcedure(c,s.tunerfilter,1,1,s.nontunerfilter,1,99,s.lcheck)
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
    -- Gain LP equal to a target monster's ATK
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.rectg)
    e2:SetOperation(s.recop)
    c:RegisterEffect(e2)
    --Tribute 1 "Old God"; shuffle up to 3 cards from GYs into the Deck (once per turn)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,{id,1})
    e3:SetCost(s.tdcost)
    e3:SetTarget(s.tdtg)
    e3:SetOperation(s.tdop)
    c:RegisterEffect(e3)
end
s.listed_series={SET_OLD_GOD}
function s.tunerfilter(c,sc,sumtype,tp)
    return c:IsSetCard(SET_OLD_GOD,sc,sumtype,tp) and c:IsType(TYPE_TUNER,sc,sumtype,tp)
end
function s.nontunerfilter(c,sc,sumtype,tp)
    return c:IsSetCard(SET_OLD_GOD,sc,sumtype,tp) and not c:IsType(TYPE_TUNER,sc,sumtype,tp)
end
function s.lcheck(g,tp,sc)
    return true -- no additional material check
end
function s.splimit(e,se,sp,st)
	return (st&SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
            or (se:IsHasType(EFFECT_TYPE_ACTIONS) and se:GetHandler():IsSetCard(SET_OLD_GOD))
end

function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
    end
end

function s.costfilter(c)
    return c:IsSetCard(SET_OLD_GOD) and c:IsReleasable()
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil) end
    local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil)
    Duel.Release(g,REASON_COST)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end