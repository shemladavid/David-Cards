--Ｎｏ．４ 猛毒刺胞ステルス・クラーゲン
--Number 4: Stealth Kragen
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),4,2)
	c:EnableReviveLimit()
	--destroy
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.sumcon)
	e2:SetTarget(s.sumtg)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetOperation(s.op)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--battle indestructable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,0x48)))
	c:RegisterEffect(e4)
end
s.listed_series={0x48}
s.xyz_number=4
function s.desfilter(c)
	return c:IsFaceup()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		if Duel.Destroy(tc,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetOverlayGroup()
	g:KeepAlive()
	e:GetLabelObject():SetLabelObject(g)
end
function s.spfilter(c,e,tp)
	return c:IsCode(511001336,511001337,67557908) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.rescon(ect)
	return function(sg,e,tp,mg)
		return Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_XYZ)>=sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA) 
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>=sg:FilterCount(aux.NOT(Card.IsLocation),nil,LOCATION_EXTRA)
			and Duel.GetUsableMZoneCount(tp)>=#sg
			and (not ect or sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)<=ect)
	end
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g = e:GetLabelObject()  -- overlay group stored by e3
    local count = #g
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then count = 1 end
    local sg = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_EXTRA+LOCATION_GRAVE, 0, e:GetHandler(), e, tp)
    if chk==0 then 
        return count > 0 and aux.SelectUnselectGroup(sg, e, tp, 1, count, s.rescon(aux.CheckSummonGate(tp)), 0)
    end
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, count, tp, 0)
end

function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    local mg = Duel.GetTargetCards(e)
    local ct = #mg
    if ct <= 0 or (Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and ct > 1) then return end
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter), tp, LOCATION_EXTRA+LOCATION_GRAVE, 0, e:GetHandler(), e, tp)
    local maxct = ct
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then maxct = 1 end
    local sg = aux.SelectUnselectGroup(g, e, tp, 1, maxct, s.rescon(aux.CheckSummonGate(tp)), 1, tp, HINTMSG_SPSUMMON)
    if #sg <= 0 then return end
    
    -- Special Summon with proper summon procedure
    Duel.SpecialSummon(sg, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
    
    -- Mark each summoned monster as properly summoned
    local tc = sg:GetFirst()
    while tc do
        tc:CompleteProcedure()
        tc = sg:GetNext()
    end

    if sg:GetCount() == 1 then
        -- If only one monster was summoned, attach all overlays to it.
        local tc = sg:GetFirst()
        Duel.Overlay(tc, mg)
    else
        -- More than one monster was summoned:
        -- Calculate even share and remainder.
        local overlaysCount = mg:GetCount()
        local monstersCount = sg:GetCount()
        local evenCount = math.floor(overlaysCount / monstersCount)
        local remainder = overlaysCount % monstersCount

        -- Even distribution: each monster gets "evenCount" overlays.
        for tc in aux.Next(sg) do
            local groupForThis = Group.CreateGroup()
            for i = 1, evenCount do
                local oc = mg:GetFirst()
                if not oc then break end
                groupForThis:AddCard(oc)
                mg:RemoveCard(oc)
            end
            if groupForThis:GetCount() > 0 then
                Duel.Overlay(tc, groupForThis)
            end
        end

        -- Distribute leftover overlays randomly, each monster can receive at most one extra.
        if remainder > 0 then
            local monstersForExtra = sg:Clone()
            for i = 1, remainder do
                if monstersForExtra:GetCount() <= 0 then break end
                local selectedMonster = monstersForExtra:RandomSelect(tp, 1):GetFirst()
                local oc = mg:GetFirst()
                if oc then
                    Duel.Overlay(selectedMonster, oc)
                    mg:RemoveCard(oc)
                end
                monstersForExtra:RemoveCard(selectedMonster)
            end
        end
    end
end