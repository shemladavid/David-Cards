-- Call of the Old Gods
local s, id = GetID()
local SET_OLD_GOD = 0x653
function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetHintTiming(0, TIMING_BATTLE_START | TIMING_BATTLE_END)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.counterfilter)
end
s.listed_series = {SET_OLD_GOD}

function s.counterfilter(c)
    return c:IsLevel(12) or c:IsRank(12)
end
function s.cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0
    end
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetReset(RESET_PHASE | PHASE_END)
    e1:SetTargetRange(1, 0)
    e1:SetTarget(s.splimit)
    Duel.RegisterEffect(e1, tp)
    local e2 = Effect.CreateEffect(e:GetHandler())
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    e2:SetDescription(aux.Stringid(id, 2))
    e2:SetReset(RESET_PHASE | PHASE_END)
    e2:SetTargetRange(1, 0)
    Duel.RegisterEffect(e2, tp)
end
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
    return not (c:IsLevel(12) or c:IsRank(12))
end

function s.thfilter(c)
    return c:IsSetCard(SET_OLD_GOD) and c:IsAbleToHand()
end

function s.fusfilter(c, e, tp)
    return c:IsSetCard(SET_OLD_GOD) and c:IsType(TYPE_FUSION) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false)
end

function s.target(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.operation(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)

        -- Check for Fusion Summon possibility
        local mg1 = Duel.GetFusionMaterial(tp)
        local sg = Duel.GetMatchingGroup(s.fusfilter, tp, LOCATION_EXTRA, 0, nil, e, tp)
        local can_fusion = false

        for tc in aux.Next(sg) do
            if tc:IsType(TYPE_FUSION) and tc:IsSetCard(SET_OLD_GOD) and
                tc:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, false, false) then
                local res = tc:CheckFusionMaterial(mg1, nil, tp)
                if res then
                    can_fusion = true
                    break
                end
            end
        end

        if can_fusion and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
            local tc = sg:Select(tp, 1, 1, nil):GetFirst()
            if tc then
                local mat = Duel.SelectFusionMaterial(tp, tc, mg1, nil, tp)
                if #mat > 0 then
                    tc:SetMaterial(mat)
                    Duel.SendtoGrave(mat, REASON_EFFECT + REASON_MATERIAL + REASON_FUSION)
                    Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, false, false, POS_FACEUP)
                    tc:CompleteProcedure()
                end
            end
        end
    end
end
