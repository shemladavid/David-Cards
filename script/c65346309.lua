--Twilight of the Old Gods
local s,id=GetID()
local SET_OLD_GOD=0x653 
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_BATTLE_START|TIMING_BATTLE_END)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.listed_series={SET_OLD_GOD}

function s.counterfilter(c)
	return c:IsLevel(12) or c:IsRank(12)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetReset(RESET_PHASE|PHASE_END)
	e2:SetTargetRange(1,0)
	Duel.RegisterEffect(e2,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsLevel(12) or c:IsRank(12))
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_OLD_GOD) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.xyzfilter(c)
	return c:IsSetCard(SET_OLD_GOD) and c:IsType(TYPE_XYZ)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		Duel.BreakEffect()
		local xyzs=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
		local can_summon_xyz=false
		local valid_xyz=nil

		-- Check each XYZ monster for summon possibility
		for xyz in aux.Next(xyzs) do
			local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
			local minct=xyz.minxyzct or 2
			local maxct=xyz.maxxyzct or minct
			local xyz_filter=xyz.xyz_filter or aux.TRUE
			local valid_materials=mg:Filter(Card.IsCanBeXyzMaterial,nil,xyz,tp):Filter(xyz_filter,nil,xyz)
			if #valid_materials>=minct then
				can_summon_xyz=true
				break
			end
		end

		-- Ask the player only if it's possible
		if can_summon_xyz and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local xyz=xyzs:Select(tp,1,1,nil):GetFirst()
			if not xyz then return end

			local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
			local minct=xyz.minxyzct or 2
			local maxct=xyz.maxxyzct or minct
			local xyz_filter=xyz.xyz_filter or aux.TRUE
			local valid_materials=mg:Filter(Card.IsCanBeXyzMaterial,nil,xyz,tp):Filter(xyz_filter,nil,xyz)

			if #valid_materials>=minct then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
				local mat=valid_materials:Select(tp,minct,minct,nil)
				if #mat>0 then
					xyz:SetMaterial(mat)
					Duel.Overlay(xyz,mat)
					Duel.SpecialSummon(xyz,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
					xyz:CompleteProcedure()
				end
			end
		end
	end
end
