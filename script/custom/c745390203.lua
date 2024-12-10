-- Suffocating Fumes
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetOperation(s.actop)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Summon Daemons
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	-- immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)

	-- Banish Itself
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_ONFIELD+LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
end

-- e0 functions

function s.actop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id,3))
end


-- e2 functions

function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

-- e3 functions
function s.spconfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsCode(73167098)
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_ONFIELD) then
		Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id,0))
	else
		Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id,1))
	end

	Duel.Remove(e:GetHandler(), POS_FACEDOWN, REASON_EFFECT)
	Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id,2))
end