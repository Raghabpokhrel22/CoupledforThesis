# =============================================================
# 01_baseline_fixed_D.jl
# Exact reproduction from Datseris (2025) tutorial
# Stevens 2006 boundary layer model with clouds
# =============================================================

using DynamicalSystems, ConceptualClimateModels
import ConceptualClimateModels.CloudToppedMixedLayerModel as CTMLM

const cₚ = 1004.0

eqs = [
    CTMLM.mlm_dynamic(),
    CTMLM.entrainment_velocity(:Stevens2006; use_augmentation = false),
    # Cloud processes
    CTMLM.cf_dynamic(),
    CTMLM.decoupling_variable(),
    CTMLM.cloud_base_height(:Bolton1980),
    # Simple radiation (from tutorial)
    CTMLM.CTRC ~ 10 + 40*CTMLM.C,
    CTMLM.ΔF_s ~ CTMLM.CTRC,
    # Boundary conditions (fixed, from Stevens 2006)
    CTMLM.s₊ ~ 301200.0/cₚ,
    CTMLM.q₊ ~ 1.56,
    CTMLM.s₀ ~ CTMLM.s₊ - 12.5,
    CTMLM.ρ₀ ~ 1,
    CTMLM.q₀ ~ CTMLM.q_saturation(288.96 + 1.25),
]

ds = processes_to_coupledodes(eqs, CTMLM)

# Exact parameters from tutorial
set_parameter!(ds, :D,   4e-6)
set_parameter!(ds, :d_c, 0.0009)
set_parameter!(ds, :U,   6.8)
set_parameter!(ds, :e_e, 1.0)

# Run to steady state
step!(ds, 100.0)

# Print results
println("=== BASELINE RESULTS ===")
println("z_b = ", round(observe_state(ds, CTMLM.z_b), digits=1), " m")
println("C   = ", round(observe_state(ds, CTMLM.C),   digits=3))
println("q_b = ", round(observe_state(ds, CTMLM.q_b), digits=2), " g/kg")
println("s_b = ", round(observe_state(ds, CTMLM.s_b), digits=2), " K")
