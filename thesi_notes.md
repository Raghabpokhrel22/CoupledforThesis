# CoupledforThesis — Research Notes

## Session 1 — May 4, 2026

### Repository Setup
- Created GitHub repository: CoupledforThesis (public)
- Installed Julia 1.11.5, added to Windows PATH
- Set up Julia project with dependencies:
  - ConceptualClimateModels.jl v1.2.0 (Datseris 2025)
  - DynamicalSystems.jl
  - CairoMakie.jl
  - ModelingToolkit.jl
- Created folder structure: src/, experiments/, figures/
- Added personal_notes.md to .gitignore (private notes stay local)

---

## Experiment 01 — Baseline Fixed D
**File:** `experiments/01_baseline_fixed_D.jl`  
**Status:** ✅ Complete

**Goal:** Reproduce Stevens (2006) boundary layer model with clouds
using fixed subsidence parameter D. This is the reference point
for all coupled experiments.

**Configuration:**
- Entrainment: Stevens2006 (no augmentation)
- Radiation: CTRC = 10 + 40×C (simple ad-hoc)
- ΔF_s = CTRC
- s₊ = 301200/cₚ (fixed FT static energy)
- q₊ = 1.56 g/kg (fixed FT humidity)
- D = 4×10⁻⁶ s⁻¹ (fixed subsidence)
- d_c = 0.0009, U = 6.8 m/s, e_e = 1.0

**Results:**
| Variable | Value | Unit |
|---|---|---|
| z_b | 763.5 | m |
| C | 0.708 | — |
| q_b | 8.79 | g/kg |
| s_b | 287.5 | K |

**Conclusion:** Baseline reproduced successfully. Model is in
stratocumulus regime (C = 0.708). Boundary layer height
reasonable at 763.5 m.

---

## Experiment 02 — Coupled Control
**File:** `experiments/02_coupled_control.jl`  
**Status:** ✅ Complete

**Goal:** Calibrate dynamic subsidence coupling. Replace fixed D
with D computed from free-tropospheric energy balance using
Newtonian cooling framework (Raghab Pokhrel 2025):

**Calibration procedure:**
1. Run baseline to steady state (200 days)
2. Diagnose τ_rad needed to give D = 4×10⁻⁶ s⁻¹ at that state
3. τ_rad = (s₊ - s_b + Γ_rad×z_b) / (D_target × z_b)

**Calibration results:**
| Parameter | Value | Unit |
|---|---|---|
| τ_rad | 6093 | seconds |
| Γ_rad | 8×10⁻³ | K/m |
| s₊ - s_b + Γ_rad×z_b | 18.608 | K |
| D_coupled | 4.0×10⁻⁶ | s⁻¹ |

**Coupled model results:**
| Variable | Value | Unit |
|---|---|---|
| z_b | 763.5 | m |
| C | 0.708 | — |
| q_b | 8.79 | g/kg |

**Conclusion:** Dynamic D successfully calibrated. Coupled model
reproduces identical steady state as fixed D baseline. The coupling
is self-consistent — τ_rad = 6093 s is the key new parameter.

---

## Experiment 03 — Hysteresis Test ⭐ MAIN RESULT
**File:** `experiments/03_hyteresis.jl`  
**Status:** ✅ Complete

**Goal:** Test whether the model shows bistability. Does the cloud
system remember its past state when forcing is reversed?
This tests whether SCT is a genuine climate tipping point.

**Method:**
- Forward sweep: D reduced 4×10⁻⁶ → 1×10⁻⁶ s⁻¹, 20 steps
- Backward sweep: D increased 1×10⁻⁶ → 4×10⁻⁶ s⁻¹, 20 steps
- Each step: 200 days integration to quasi-equilibrium
- Initial state: baseline stratocumulus (C = 0.708)

**Full results table:**
| D (s⁻¹) | C forward | C backward |
|---|---|---|
| 4.0×10⁻⁶ | 0.708 | 0.245 |
| 3.8×10⁻⁶ | 0.667 | 0.247 |
| 3.7×10⁻⁶ | 0.614 | 0.248 |
| 3.5×10⁻⁶ | 0.534 | 0.249 |
| 3.4×10⁻⁶ | 0.327 | 0.251 |
| 3.2×10⁻⁶ | 0.298 | 0.253 |
| 3.1×10⁻⁶ | 0.285 | 0.255 |
| 2.9×10⁻⁶ | 0.277 | 0.257 |
| 2.7×10⁻⁶ | 0.271 | 0.260 |
| 2.6×10⁻⁶ | 0.267 | 0.263 |
| 2.4×10⁻⁶ | 0.263 | 0.267 |
| 2.3×10⁻⁶ | 0.260 | 0.271 |
| 2.1×10⁻⁶ | 0.257 | 0.277 |
| 1.9×10⁻⁶ | 0.255 | 0.285 |
| 1.8×10⁻⁶ | 0.253 | 0.298 |
| 1.6×10⁻⁶ | 0.251 | 0.327 |
| 1.5×10⁻⁶ | 0.249 | 0.534 |
| 1.3×10⁻⁶ | 0.248 | 0.614 |
| 1.2×10⁻⁶ | 0.246 | 0.667 |
| 1.0×10⁻⁶ | 0.245 | 0.708 |

**Key findings:**
| Metric | Value |
|---|---|
| Tipping point (forward) | D ≈ 3.4×10⁻⁶ s⁻¹ |
| Recovery point (backward) | D ≈ 1.5×10⁻⁶ s⁻¹ |
| Hysteresis width | 1.9×10⁻⁶ s⁻¹ |
| Max C difference | 0.463 |

**HYSTERESIS DETECTED ✅**

**Physical interpretation:**
Once stratocumulus clouds break up into cumulus at D ≈ 3.4×10⁻⁶,
the system does not recover even when D is restored. Recovery only
occurs at D ≈ 1.5×10⁻⁶ — nearly half the collapse threshold.
This confirms a genuine climate tipping point in the coupled model.
The cloud system has memory of its previous state — bistability
is present in the stratocumulus-cumulus transition.

---

## Next Steps
- [ ] Experiment 04: Sensitivity — vary τ_rad (10, 15, 25 days)
- [ ] Fix hysteresis figure (CairoMakie rendering)
- [ ] Rename 03_hyteresis.jl → 03_hysteresis.jl
- [ ] Write src/dynamic_subsidence.jl properly
- [ ] Read Datseris (2025) Section 3 on hysteresis
- [ ] Compare our hysteresis width with Datseris fixed-D results

---

## Key Parameters Reference
| Parameter | Value | Description |
|---|---|---|
| D | 4×10⁻⁶ s⁻¹ | baseline subsidence |
| τ_rad | 6093 s | FT relaxation timescale |
| Γ_rad | 8×10⁻³ K/m | radiative equilibrium lapse rate |
| d_c | 0.0009 | aerodynamic drag coefficient |
| U | 6.8 m/s | surface wind speed |
| e_e | 1.0 | entrainment efficiency |
| τ_C | 2.0 days | cloud fraction relaxation time |

## Dependencies
- ConceptualClimateModels.jl v1.2.0
- DynamicalSystems.jl
- CairoMakie.jl
- Julia 1.11.5

