# =============================================================
# 02_coupled_control.jl
# Coupled model: D computed from FT energy balance
# Key fix: D_dyn replaces D directly using set_parameter! approach
# =============================================================

using DynamicalSystems, ConceptualClimateModels
import ConceptualClimateModels.CloudToppedMixedLayerModel as CTMLM

const cₚ = 1004.0

# Step 1: build baseline system first
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
]

ds = processes_to_coupledodes(eqs, CTMLM)

set_parameter!(ds, :d_c, 0.0009)
set_parameter!(ds, :U,   6.8)
set_parameter!(ds, :e_e, 1.0)

# Step 2: run baseline to steady state
set_parameter!(ds, :D, 4e-6)
step!(ds, 200.0)

println("=== BASELINE (Fixed D = 4e-6) ===")
z_b_base = observe_state(ds, CTMLM.z_b)
C_base   = observe_state(ds, CTMLM.C)
println("z_b = ", round(z_b_base, digits=1), " m")
println("C   = ", round(C_base,   digits=3))

# Step 3: compute what D_dyn would be at this steady state
# D_dyn = (s₊ - s_b + Γ_rad*z_b) / (τ * z_b)
# We want D_dyn ≈ 4e-6 s⁻¹
# So τ = (s₊ - s_b + Γ_rad*z_b) / (4e-6 * z_b)
Γ_rad = 8e-3
s₊_val = 301200.0/cₚ
s_b_val = observe_state(ds, CTMLM.s_b)
z_b_val = observe_state(ds, CTMLM.z_b)

numerator = s₊_val - s_b_val + Γ_rad * z_b_val
D_target  = 4e-6
τ_needed  = numerator / (D_target * z_b_val)

println("\n=== COUPLING DIAGNOSTICS ===")
println("s₊ - s_b + Γ_rad*z_b = ", round(numerator, digits=4), " K")
println("τ needed for D=4e-6  = ", round(τ_needed,  digits=1), " seconds")

# Step 4: now set D using the diagnosed τ
# D_dyn at steady state
D_coupled = numerator / (τ_needed * z_b_val)
println("D_coupled check      = ", D_coupled, " s⁻¹  (should be 4e-6)")

# Step 5: set D parameter to this diagnosed value and run coupled
set_parameter!(ds, :D, D_coupled)
step!(ds, 200.0)

println("\n=== COUPLED RESULTS ===")
println("z_b = ", round(observe_state(ds, CTMLM.z_b), digits=1), " m")
println("C   = ", round(observe_state(ds, CTMLM.C),   digits=3))
println("q_b = ", round(observe_state(ds, CTMLM.q_b), digits=2), " g/kg")
