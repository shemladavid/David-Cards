--Gunkan Suship Unagi-class Destroyer
local CARD_SUSHIP_UNAGI=12345726
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon.
	Xyz.AddProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	--"Gunkan" monsters cannot be targeted by opponent's effects
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,0)
	e0:SetCondition(s.contcon)
	e0:SetTarget(s.conttg)
	e0:SetValue(aux.tgoval)
	c:RegisterEffect(e0)
	--"Gunkan" monsters gain ATK equal to their original DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.contcon)
	e1:SetTarget(s.conttg)
	e1:SetValue(function(_,c)return c:GetBaseDefense() end)
	c:RegisterEffect(e1)
	--Gains effects based on material.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetLabel(0)
	e2:SetCondition(s.regcon)
	e2:SetTarget(s.regtg)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GUNKAN}
s.listed_names={CARD_SUSHIP_SHARI,CARD_SUSHIP_UNAGI}

function s.contcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.conttg(e,c)
	return c:IsSetCard(SET_GUNKAN) and c:IsSummonLocation(LOCATION_EXTRA)
end

function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()>0
end
function s.regtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local effs=e:GetLabel()
	local rc=e:GetHandler()
	if chk==0 then return ((effs&1)>0 and Duel.IsPlayerCanDraw(tp,1)) or ((effs&2)>0) end
	if (effs&1)>0 then
		--Negate
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetCategory(CATEGORY_DISABLE)
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_CHAINING)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCondition(s.discon)
		e1:SetTarget(s.distg)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local effs=e:GetLabel()
	--"Gunkan Suship Shari": Draw 1 card.
	if (effs&1)>0 then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
	--"CARD_SUSHIP_UNAGI: negate opponent's effect once per turn.
	if (effs&2)>0 then
		local e1=Effect.CreateEffect(c)
	end
end
function s.indtg(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_GUNKAN)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local effs=0
	--Check for "Gunkan Suship Shari".
	if g:IsExists(Card.IsCode,1,nil,CARD_SUSHIP_SHARI) then effs=effs|1 end
	--Check for "Gunkan Suship UNAGI".
	if g:IsExists(Card.IsCode,1,nil,CARD_SUSHIP_UNAGI) then effs=effs|2 end
	e:GetLabelObject():SetLabel(effs)
end