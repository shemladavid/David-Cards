--アダマシア・ラピュタイト
--Adamancipator Realm
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ROCK))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--def up
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--hack top
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.tdtg)
	e4:SetOperation(s.tdop)
	c:RegisterEffect(e4)
	--All monsters in GY treated as all attributes
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_ADD_ATTRIBUTE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_GRAVE,0)
	e5:SetValue(0xff) -- All Attributes
	c:RegisterEffect(e5)
	-- Shuffle 1 Tuner and 1 non-Tuner from GY; Special Summon Adamancipator Synchro
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTarget(s.syntg)
	e6:SetOperation(s.synop)
	c:RegisterEffect(e6)
	--Cannot be targeted
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e7:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e7:SetRange(LOCATION_FZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetTarget(s.tgtg)
	e7:SetValue(aux.tgoval)
	c:RegisterEffect(e7)
	-- Send 1 Tuner and 1 non-Tuner from Deck to GY; Special Summon 1 Adamancipator Synchro
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(id,2))
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_FZONE)
	e8:SetTarget(s.syntg2)
	e8:SetOperation(s.synop2)
	c:RegisterEffect(e8)
	-- All cards in hand and Deck are also treated as "Adamancipator" cards
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_ADD_SETCODE)
	e9:SetRange(LOCATION_FZONE)
	e9:SetTargetRange(LOCATION_DECK,0)
	e9:SetValue(0x140)
	c:RegisterEffect(e9)
end
s.listed_series={0x140}

-- "Rock" monsters cannot be targeted by opponent's effects
function s.tgtg(e,c)
    return c:IsRace(RACE_ROCK)
end

-- Top Deck hack target
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x140)
		return aux.SelectUnselectGroup(g,e,tp,1,5,nil,chk)
	end
end

-- Top Deck hack operation
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,0x140)
	local rg=aux.SelectUnselectGroup(g,e,tp,1,5,nil,1,tp,aux.Stringid(id,1))
	if #rg>0 then
		Duel.ConfirmCards(1-tp,rg)
		Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(rg)
		Duel.SortDecktop(tp,tp,#rg)
	end
end

-- Target for Special Summoning an Adamancipator Synchro Monster (e6)
function s.syntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- Check if you have 1 Tuner and 1 non-Tuner monster in the GY
		local g1=Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TUNER)
		local g2=Duel.IsExistingMatchingCard(s.nonTunerFilter,tp,LOCATION_GRAVE,0,1,nil)
		return g1 and g2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Filter for Adamancipator Synchro Monsters
function s.synfilter(c,e,tp)
	return c:IsSetCard(0x140) and c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end

-- Filter for non-Tuner monsters
function s.nonTunerFilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_TUNER)
end

-- Operation for shuffling the materials and performing the Synchro Summon (e6)
function s.synop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	-- Select 1 Tuner and 1 non-Tuner monster from the GY
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tuner=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_GRAVE,0,1,1,nil,TYPE_TUNER):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local nontuner=Duel.SelectMatchingCard(tp,s.nonTunerFilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not tuner or not nontuner then return end

	-- Shuffle them back to the Deck
	local g=Group.FromCards(tuner,nontuner)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==2 then
		-- Special Summon 1 Adamancipator Synchro monster from the Extra Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if sc then
			Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end

-- Target for sending from Deck and Special Summoning Adamancipator Synchro Monster (e8)
function s.syntg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.tunerFilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.nonTunerFilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.synfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Filter for Tuner monsters
function s.tunerFilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToGrave()
end

-- Operation for sending from Deck and Special Summoning Adamancipator Synchro Monster (e8)
function s.synop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

	-- Select 1 Tuner and 1 non-Tuner monster from the Deck
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tuner=Duel.SelectMatchingCard(tp,s.tunerFilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local nontuner=Duel.SelectMatchingCard(tp,s.nonTunerFilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tuner or not nontuner then return end

	-- Send them to the GY
	local g=Group.FromCards(tuner,nontuner)
	if Duel.SendtoGrave(g,REASON_EFFECT)==2 then
		-- Special Summon 1 Adamancipator Synchro monster from the Extra Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.synfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if sc then
			Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
			sc:CompleteProcedure()
		end
	end
end