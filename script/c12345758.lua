--Chaos Phantasmal Summoning Beast
local s,id=GetID()
local SET_PHANTASMAL=0x145
function s.initial_effect(c)
	c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,1,1)
    --cannot link material
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
    --Increase ATK of all "Phantasmal" Fusion Monsters you control by 10000 during your opponent's turn if this card is in the Extra Monster Zone
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetValue(10000)
	c:RegisterEffect(e2)
    --Limit battle target
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCondition(s.limcon)
    e3:SetValue(s.limvalue)
    c:RegisterEffect(e3)
    --Limit effect target
    local e4=e3:Clone()
    e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
    e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e4:SetTarget(s.limtg)
    e4:SetValue(aux.tgoval)
    c:RegisterEffect(e4)
    --Special Summon 1 "Phantasmal" monster from your Extra Deck
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id)
    e5:SetCondition(s.spcon)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
end
s.listed_series={SET_PHANTASMAL}
s.listed_names={69890967,6007213,32491822,id}
function s.matfilter(c,lc,sumtype,tp)
	return c:ListsCode(69890967,6007213,32491822) and c:IsMonster()
end

function s.atkcon(e)
	return e:GetHandler():GetSequence()>4  and Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function s.atktg(e,c)
    return c:IsSetCard(SET_PHANTASMAL) and c:IsType(TYPE_FUSION)
end

function s.limfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_PHANTASMAL) and c:IsType(TYPE_FUSION)
end
function s.limcon(e)
    local tp=e:GetHandlerPlayer()
    local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.limfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.limvalue(e,c)
    return c:GetAttack() < 10000
end

function s.limtg(e,c)
    return c:IsFaceup() and c:GetAttack()<10000
end

function s.spfilter1(c)
    return c:ListsCode(69890967,6007213,32491822)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
function s.spfilter(c,e,tp)
    return c:IsMonster() and c:IsSetCard(SET_PHANTASMAL) and c:IsType(TYPE_FUSION) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCountFromEx(tp)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
    end
end