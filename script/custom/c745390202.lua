-- The Soulstealer
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--Summon Itself
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_OVERLAY+LOCATION_HAND+LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- Double attack and die after battle
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- Search a continuous spell
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_ALL)
	e5:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_DUEL)
	e5:SetOperation(s.lpop)
	c:RegisterEffect(e5)
end


-- e1 functions

function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer()== tp
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then 
		return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SPECIAL, tp, false, false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,c:GetLocation())
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SpecialSummon(c,SUMMON_TYPE_SPECIAL,tp,tp, false,false, POS_FACEUP)
end

-- e2 functions

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_DAMAGE_STEP_END)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetOperation(s.sdop)
		tc:RegisterEffect(e2)
	end
end

function s.sdop(e, tp, eg, ep, ev, re, r, rp)
	local c=e:GetHandler()
	Duel.Destroy(c,REASON_EFFECT)
end

-- e3 functions

function s.contfilter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS
end


function s.thop(e, tp, eg, ep, ev, re, r, rp)
	local g=Duel.GetMatchingGroup(s.contfilter, tp, LOCATION_DECK, 0, nil)
	if #g <= 0 then
		if Duel.IsExistingMatchingCard(s.contfilter, tp, LOCATION_HAND+LOCATION_ONFIELD, 0, 1,nil) then return end
		Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id,2))
		Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id,3))
		
		Duel.SetLP(tp, 1)
		Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id,4))
		return
	end
	
	local sc = g:Select(tp, 1, 1,nil)
	if #sc >= 0 then
		Duel.SendtoHand(sc, tp, REASON_EFFECT)
		Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id,5))
	end
end

-- e5 functions

function s.lpop(e, tp, eg, ep, ev, re, r, rp)
	Duel.SetLP(tp, 400000)
	Duel.ConfirmCards(1-tp,e:GetHandler())
	Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id,0))
	Duel.Hint(HINT_MESSAGE, 1-tp, aux.Stringid(id,1))
end