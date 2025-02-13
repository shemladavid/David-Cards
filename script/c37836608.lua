-- Drudomancer Spirit Journey
local s,id=GetID()
function s.initial_effect(c)
    -- Activate effect: Add "Drudomancer" monster from Deck to hand
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- Tribute Summon by tributing 1 monster from each field, for a revealed "Drudomancer" monster
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(EFFECT_EXTRA_RELEASE_SUM)
    e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetValue(s.trival)
    c:RegisterEffect(e2)

    -- Return monsters to hand after battle (Illusion monster)
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.battlecon)
    e3:SetTarget(s.battletg)
    e3:SetOperation(s.battleop)
    c:RegisterEffect(e3)
end

-- Add "Drudomancer" monster from Deck to hand
function s.thfilter(c)
    return c:IsSetCard(0x317d) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

-- Tribute Summon by tributing 1 monster from each field, for a revealed "Drudomancer" monster
function s.trival(e,c)
    local tp=e:GetHandlerPlayer()
    return Duel.IsExistingMatchingCard(Card.IsPublic,tp,LOCATION_HAND,0,1,nil) and
    Duel.IsExistingMatchingCard(s.trifilter,tp,LOCATION_HAND,0,1,nil)
end
function s.trifilter(c)
    return c:IsSetCard(0x317d) and c:IsType(TYPE_MONSTER)
end

-- Return both battling monsters to the hand after battle (Illusion monster)
function s.battlecon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if not d then return false end
    return (a:IsRace(RACE_ILLUSION) and a:IsFaceup() and a:IsRelateToBattle() and a:IsLocation(LOCATION_ONFIELD))
        or (d:IsRace(RACE_ILLUSION) and d:IsFaceup() and d:IsRelateToBattle() and d:IsLocation(LOCATION_ONFIELD))
end

function s.battletg(e,tp,eg,ep,ev,re,r,rp,chk)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    if chk==0 then return a:IsRelateToBattle() and d:IsRelateToBattle() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,Group.FromCards(a,d),2,0,0)
end

function s.battleop(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    local g=Group.CreateGroup()
    if a and a:IsRelateToBattle() then g:AddCard(a) end
    if d and d:IsRelateToBattle() then g:AddCard(d) end
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
    end
end
