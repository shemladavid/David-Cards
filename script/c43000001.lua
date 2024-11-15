-- Elemental HERO Blazing Burstinatrix
local s,id=GetID()
function s.initial_effect(c)
    -- Special Summon itself and the destroyed monster
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Add "Polymerization", "Fusion", or "Elemental HERO" from GY to hand
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

function s.cfilter(c,tp)
    return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp)
        and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSetCard(0x3008)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,tp)
end

-- First part: Special summon the card itself
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- Main effect operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        -- After special summoning the card itself, call the function to handle targeting and special summoning from the graveyard
        s.selectAndSummon(e,tp,eg)
    end
end

-- Second part: Allow player to target and special summon from the graveyard
function s.selectAndSummon(e,tp,eg)
    local destroyed_cards = eg:Filter(Card.IsType, nil, TYPE_MONSTER)
    local player_cards = destroyed_cards:Filter(Card.IsControler, nil, tp)
    
    -- Allow the player to select 1 or more of their destroyed monsters
    local g = Duel.SelectMatchingCard(tp, function(c) return c:IsControler(tp) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end, tp, LOCATION_GRAVE, 0, 1, #player_cards, nil)
    
    if #g > 0 then
        Duel.SetTargetCard(g)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
        
        -- Special summon the selected cards
        for tc in aux.Next(g) do
            if tc:IsRelateToEffect(e) then
                Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end

function s.thfilter(c)
    return c:IsAbleToHand() and (c:IsCode(24094653) or c:IsSetCard(0x3008))
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
    end
end
