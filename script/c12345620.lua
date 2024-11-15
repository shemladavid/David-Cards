-- XYZ Master Field
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    
    -- Attach materials to XYZ monster
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
    
    -- ATK/DEF Boost based on materials
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.xyztg)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e4)
    
    -- Unaffected by opponent's effects (XYZ monsters)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetTarget(s.xyztg)
    e5:SetValue(s.efilter)
    c:RegisterEffect(e5)
    
    -- Unaffected by opponent's effects (Field Spell)
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_IMMUNE_EFFECT)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetRange(LOCATION_FZONE)
    e6:SetValue(s.eefilter)
    c:RegisterEffect(e6)
    
    -- Negate opponent's effects
    local e7=Effect.CreateEffect(c)
    e7:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_CHAINING)
    e7:SetRange(LOCATION_FZONE)
    e7:SetCountLimit(1)
    e7:SetCondition(s.negcon)
    e7:SetTarget(s.negtg)
    e7:SetOperation(s.negop)
    c:RegisterEffect(e7)
    
    -- Cost Change
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD)
    e8:SetCode(EFFECT_LPCOST_CHANGE)
    e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e8:SetRange(LOCATION_FZONE)
    e8:SetTargetRange(1,0)
    e8:SetValue(s.costchange)
    c:RegisterEffect(e8)
end

function s.filter(c)
    return c:IsFaceup() and c:IsType(TYPE_XYZ)
end

function s.opponent_extra_deck_check(tp)
    local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,LOCATION_EXTRA)
    if #g>0 then
        Duel.ConfirmCards(1-tp,g)
        Duel.ShuffleDeck(tp)
    end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) and Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,LOCATION_EXTRA)>0 end
    -- Look at the opponent's Extra Deck before selecting a target
    s.opponent_extra_deck_check(tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsFacedown() or not tc:IsType(TYPE_XYZ) then return end
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,8)) -- "Select cards from your Extra Deck to attach as material"
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_EXTRA,LOCATION_EXTRA,1,99,nil)
    if #g>0 then
        Duel.Overlay(tc,g)
    end
end

function s.xyztg(e,c)
    return c:IsType(TYPE_XYZ)
end

function s.atkval(e,c)
    return c:GetOverlayCount()*500
end

function s.efilter(e,re)
    return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end

function s.eefilter(e,te)
    return te:GetOwner()~=e:GetOwner()
end

function s.negfilter(c,tp)
    return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsControler(tp)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return ep~=tp and Duel.IsExistingMatchingCard(s.negfilter,tp,LOCATION_MZONE,0,1,nil,tp) and Duel.IsChainNegatable(ev)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

function s.costchange(e,re,rp,val)
    if re and not mustpay then
        return 0
    else
        return val
    end
end
