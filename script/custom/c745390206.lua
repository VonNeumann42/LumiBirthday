-- Soul Fusion
-- Scripted by VonNeumann42
local s,id=GetID()
function s.initial_effect(c)
	--Add this
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetRange(LOCATION_DECK+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- Fusion or Search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
end

-- e1 functions
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		and e:GetHandler():IsAbleToHand() and Duel.GetDrawCount(tp)>0
end

function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk== 0 then return true end
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetHandler(), tp, REASON_EFFECT)
end

-- e2 functions

function s.cfilter(c)
	return c:IsDiscardable()
end

function s.thfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0x46) and c:GetType()==TYPE_SPELL
end
	
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return 
		Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) 
		and Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_HAND, 0, 1, nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Fusion.SummonEffTG()(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=s.target2(e,tp,eg,ep,ev,re,r,rp,0)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		e:SetOperation(Fusion.SummonEffOP())
		Fusion.SummonEffTG()(e,tp,eg,ep,ev,re,r,rp,1)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetOperation(s.spop2)
		s.target2(e,tp,eg,ep,ev,re,r,rp,1)
	end
end


function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local dg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	if #dg>0 then
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local tc = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end
	
end
