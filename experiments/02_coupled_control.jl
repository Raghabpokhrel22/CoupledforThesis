# =============================================================
# 02_coupled_control.jl
# Coupled model: D(t) computed dynamically from FT energy balance
# Compare with baseline fixed D results
# =============================================================

using DynamicalSystems, ConceptualClimateModels
import ConceptualClimateModels.CloudToppedMixedLayerModel as CTMLM
using ModelingToolkit

const cₚ = 1004.0

# New parameters for dynamic subsidence
@parameters τ_rad = 15.0
@parameters Γ_rad = 8.0e-3

# New variable: dynamic D
@variables D_dyn(t) = 4e-6

eqs = [
    CTMLM.mlm_dynamic(),
    CTMLM.entrainment_velocity(:Stevens2006; use_augmentation = false),
    CTMLM.cf_dynamic(),
    CTMLM.decoupling_variable(),
    CTMLM.cloud_base_height(:Bolton1980),
    CTMLM.CTRC ~ 10 + 40*CTMLM.C,
    CTMLM.ΔF_s ~ CTMLM.CTRC,
    CTMLM.s₊ ~ 301200.0/cₚ,
    CTMLM.q₊ ~ 1.56,
    CTMLM.s₀ ~ CTMLM.s₊ - 12.5,
    CTMLM.ρ₀ ~ 1,
    CTMLM.q₀ ~ CTMLM.q_saturation(288.96 + 1.25),
    # Dynamic subsidence process
    D_dyn ~ (CTMLM.s₊ - (CTMLM.s_b - Γ_rad * CTMLM.z_b)) / (τ_rad * CTMLM.z_b),
]

ds = processes_to_coupledodes(eqs, CTMLM)

set_parameter!(ds, :D,   0.0)  # zero out fixed D
set_parameter!(ds, :d_c, 0.0009)
set_parameter!(ds, :U,   6.8)
set_parameter!(ds, :e_e, 1.0)

step!(ds, 100.0)

println("=== COUPLED MODEL RESULTS ===")
println("z_b   = ", round(observe_state(ds, CTMLM.z_b),  digits=1), " m")
println("C     = ", round(observe_state(ds, CTMLM.C),    digits=3))
println("D_dyn = ", observe_state(ds, D_dyn), " s⁻¹")
println("q_b   = ", round(observe_state(ds, CTMLM.q_b),  digits=2), " g/kg")
