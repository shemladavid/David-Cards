-- Power Recovery Field
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)

    -- Initialize tracking table
    if not s.global_check then
        s.global_check=true
        s.atk_map={}
        local ge1=Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_ADJUST)
        ge1:SetOperation(s.track_atk)
        Duel.RegisterEffect(ge1,0)
    end

    -- ATK loss recovery for your monsters only
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(511001265)
    e2:SetRange(LOCATION_SZONE)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end

-- Track current ATK continuously (store all, but we care only about your monsters)
function s.track_atk(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,0,nil)
    for tc in g:Iter() do
        local fid=tc:GetFieldID()
        local atk=tc:GetAttack()
        if s.atk_map[fid]==nil then
            s.atk_map[fid]=atk
        elseif s.atk_map[fid]~=atk then
            s.atk_map[fid]=atk
            -- Trigger only if it is your monster and it lost ATK
            if tc:IsControler(tp) and atk < s.atk_map[fid] then
                Duel.RaiseEvent(tc,511001265,e,REASON_EFFECT,tp,tp,0)
            end
        end
    end
end

-- Recover lost ATK + 1000, only for your monsters
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    for tc in eg:Iter() do
        if tc:IsFaceup() and tc:IsControler(tp) then
            local fid=tc:GetFieldID()
            local prev=s.atk_map[fid]
            if prev and tc:GetAttack()<prev then
                local diff=prev - tc:GetAttack()
                Duel.Hint(HINT_CARD,0,id)
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(diff + 1000)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
                tc:RegisterEffect(e1)
                s.atk_map[fid]=tc:GetAttack() -- update after boost
            end
        end
    end
end
