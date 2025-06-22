--おジャマ・キング
--Ojama Master
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,12482652,42941100,79335209)
	--disable field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end
s.material_setcode=SET_OJAMA
function s.disop(e,tp)
	local c=Duel.GetLocationCount(1-tp,LOCATION_MZONE)+Duel.GetLocationCount(1-tp,LOCATION_SZONE)
	if c==0 then return end
	local dis1=Duel.SelectDisableField(tp,1,0,LOCATION_ONFIELD,0)
	if c>1 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local dis2=Duel.SelectDisableField(tp,1,0,LOCATION_ONFIELD,dis1)
		dis1=(dis1|dis2)
		if c>2 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local dis3=Duel.SelectDisableField(tp,1,0,LOCATION_ONFIELD,dis1)
			dis1=(dis1|dis3)
			if c>3 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				local dis4=Duel.SelectDisableField(tp,1,0,LOCATION_ONFIELD,dis1)
				dis1=(dis1|dis4)
				if c>4 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
					local dis5=Duel.SelectDisableField(tp,1,0,LOCATION_ONFIELD,dis1)
					dis1=(dis1|dis5)
				end
			end
		end
	end
	return dis1
end