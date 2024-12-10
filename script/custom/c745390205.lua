-- Unholy Eye
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetOperation(s.actop)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
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

-- e1 functions

function s.descon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer()== 1-tp
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetTargetCards(e)
	Duel.Destroy(g,REASON_EFFECT)
end

-- e2 functions

function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end

-- e3 functions
function s.spconfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsCode(87804747)
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