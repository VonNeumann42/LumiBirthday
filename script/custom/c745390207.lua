-- Soul Fusion
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--Summon this
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_DECK+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- Copy monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(s.cotg)
	e2:SetOperation(s.coop)
	c:RegisterEffect(e2)
end

-- e1 functions
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and Duel.GetDrawCount(tp)>0
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk== 0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		e:SetLabel(1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	else e:SetLabel(0) end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabel() == 1 then return end
	local c=e:GetHandler()
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

-- e2 functions

function s.cofilter(c)
	return c:HasLevel() and c:IsPosition(POS_FACEUP)
end

function s.cotg(e, tp, eg, ep, ev, re, r, rp, chk, chck)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cofilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.cofilter, tp, LOCATION_MZONE, 0, 1, c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.cofilter,tp,LOCATION_MZONE,0,1,1,c)
end

function s.coop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and not c:IsFacedown() and tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		c:RegisterEffect(e1)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_RACE)
		e3:SetValue(tc:GetRace())
		c:RegisterEffect(e3)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e4:SetValue(tc:GetAttribute())
		c:RegisterEffect(e4)
	end
end