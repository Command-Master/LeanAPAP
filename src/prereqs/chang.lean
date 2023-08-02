import prereqs.dft
import prereqs.energy
import prereqs.misc

/-!
# Chang's lemma
-/

open finset fintype real
open_locale big_operators nnreal

@[simp] lemma real.exp_one_pow (n : ℕ) : exp 1 ^ n = exp n := by rw [←rpow_nat_cast, exp_one_rpow]
open real

variables {G : Type*} [add_comm_group G] [fintype G] {f : G → ℂ} {η : ℝ} {ψ : add_char G ℂ}
  {Δ : finset (add_char G ℂ)} {m : ℕ}

/-- The `η`-large spectrum of a function. -/
noncomputable def large_spec (f : G → ℂ) (η : ℝ) : finset (add_char G ℂ) :=
univ.filter $ λ ψ, η * ‖f‖_[1] ≤ ‖dft f ψ‖

@[simp] lemma mem_large_spec : ψ ∈ large_spec f η ↔ η * ‖f‖_[1] ≤ ‖dft f ψ‖ := by simp [large_spec]

lemma large_spec_anti (f : G → ℂ) : antitone (large_spec f) :=
λ η ν h ψ, by simp_rw mem_large_spec; exact (mul_le_mul_of_nonneg_right h Lpnorm_nonneg).trans

@[simp] lemma large_spec_zero_left (η : ℝ) : large_spec (0 : G → ℂ) η = univ := by simp [large_spec]
@[simp] lemma large_spec_zero_right (f : G → ℂ) : large_spec f 0 = univ := by simp [large_spec]

private noncomputable def α (f : G → ℂ) := ‖f‖_[1] ^ 2 / ‖f‖_[2] ^ 2 / card G

lemma α_nonneg (f : G → ℂ) : 0 ≤ α f := by unfold α; positivity
lemma α_pos (hf : f ≠ 0) : 0 < α f := by unfold α; positivity
lemma α_le_one (f : G → ℂ) : α f ≤ 1 := sorry

lemma general_hoelder (ν : G → ℝ≥0) (hfν : ∀ x, f x ≠ 0 → 1 ≤ ν x) (hΔ : Δ ⊆ large_spec f η)
  (hm : m ≠ 0) :
  ↑Δ.card ^ (2 * m) * (η ^ (2 * m) * (‖f‖_[1] ^ 2 / ‖f‖_[2] ^ 2)) ≤ energy m Δ (dft $ λ a, ν a) :=
begin
  have : η * ‖f‖_[1] * Δ.card ≤ ∑ γ in Δ, ‖dft f γ‖,
  { rw ←nsmul_eq_mul',
    exact card_nsmul_le_sum _ _ _ (λ x hx, mem_large_spec.1 $ hΔ hx) },
  sorry
end

lemma spec_hoelder (hΔ : Δ ⊆ large_spec f η) (hm : m ≠ 0) :
  ↑Δ.card ^ (2 * m) * (η ^ (2 * m) * α f) ≤ boring_energy m Δ :=
begin
  have hG : (0 : ℝ) < card G := by positivity,
  simpa [boring_energy, α, mul_assoc, ←pi.one_def, ←mul_div_right_comm, ←mul_div_assoc,
    div_le_iff hG, energy_nsmul, -nsmul_eq_mul, ←nsmul_eq_mul']
    using general_hoelder 1 (λ (_ : G) _, le_rfl) hΔ hm,
end

/-- **Chang's lemma**. -/
lemma chang (hf : f ≠ 0) (hη : 0 < η) :
  ∃ Δ ⊆ large_spec f η, Δ.card ≤ thomas_const * ⌈exp 1 * ⌈curlog (α f)⌉₊ / η ^ 2⌉₊ ∧
    large_spec f η ⊆ Δ.add_span :=
begin
  refine diss_add_span (λ Δ hΔη hΔ, _),
  obtain hΔ' | hΔ' := @eq_zero_or_pos _ _ Δ.card,
  sorry { simp [hΔ'] },
  have : 0 < α f := α_pos hf,
  set β := ⌈curlog (α f)⌉₊ with hβ,
  refine le_of_pow_le_pow _ zero_le' (nat.ceil_pos.2 $ curlog_pos (α_pos hf) $ α_le_one _)
    (nat.cast_le.1 $ le_of_mul_le_mul_right _
      (by positivity : 0 < ↑Δ.card ^ β * (η ^ (2 * β) * α f))),
  push_cast,
  rw [←hβ, ←mul_assoc, ←pow_add, ←two_mul, mul_pow, mul_mul_mul_comm],
  refine ((spec_hoelder hΔη sorry).trans $ hΔ.boring_energy_le _).trans _,
  rw mul_right_comm,
  refine mul_le_mul_of_nonneg_left _ (by positivity),
  rw ←div_le_iff,
  refine le_trans _ (pow_le_pow_of_le_left _ (nat.le_ceil _) _),
  rw [div_pow, mul_pow, exp_one_pow, ←pow_mul, ←div_div, div_eq_inv_mul, mul_div_assoc],
  exact mul_le_mul_of_nonneg_right (inv_le_exp_curlog.trans $ exp_monotone $ nat.le_ceil _)
    (by positivity),
  all_goals { positivity },
end
