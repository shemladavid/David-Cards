--Abysskite Prevent Wall
local s,id=GetID()
local SET_ABYSSKITE=0x156B
function s.initial_effect(c)
	--spirit monsters cannot be destroyed by battle and you take no battle damage from battles involving them
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START|TIMING_CHECK_MONSTER_E)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
    --Can be activated from the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(function(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_ABYSSKITE),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ABYSSKITE}

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPIRIT))
    e1:SetReset(RESET_PHASE|PHASE_END)
    e1:SetValue(aux.tgoval)
    Duel.RegisterEffect(e1,tp)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetTargetRange(1,0)
    e2:SetReset(RESET_PHASE|PHASE_END)
    Duel.RegisterEffect(e2,tp)
end