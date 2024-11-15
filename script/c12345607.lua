--トリックスター・ディーヴァリディス
--Trickstar Divaridis
--Credit to Larry126 and Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Link summon
	Link.AddProcedure(c,s.matfilter,2,2)
	--Must be properly summoned in order to be revived
	c:EnableReviveLimit()
	--Effect damage, optional trigger
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	--Continuous effect damage on opponent's normal summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.damcon)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--Continuous effect damage on opponent's special summon
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0xfb,lc,sumtype,tp)
end

--Activation legality
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(200)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
end

--Performing the effect damage
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

--If opponent was the one to perform the summon
function s.filter(c,p)
	return c:GetSummonPlayer()==p
end

--Condition to check opponent's summon
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,1-tp)
end

--Continuous effect to deal damage upon summon
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.filter,nil,1-tp)
	if ct>0 then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.Damage(1-tp,ct*200,REASON_EFFECT)
	end
end
