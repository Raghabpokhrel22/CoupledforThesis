# =============================================================
# 01_baseline_fixed_D.jl
# Reproduce Raghab baseline with fixed D
# Target: z_b ≈ 705m, C ≈ 0.85, Δ₊s ≈ 8.8 K
# =============================================================

using DynamicalSystems, ConceptualClimateModels
import ConceptualClimateModels.CloudToppedMixedLayerModel as CTMLM

eqs = [
    CTMLM.mlm_dynamic(),
    CTMLM.cf_dynamic(),
    CTMLM.decoupling_variable(),
    CTMLM.entrainment_velocity(:Stevens2006),
    CTMLM.mlm_radiative_cooling(:three_layer),
    CTMLM.cloud_emissivity(),
    CTMLM.mlm_s₊(:difference),
    CTMLM.mlm_q₊(:relative),
    CTMLM.free_troposphere_emission_temperature(),
]

ds = processes_to_coupledodes(eqs, CTMLM)

# Set baseline parameters
set_parameter!(ds, :D,   5e-6)
set_parameter!(ds, :d_c, 0.0012)
set_parameter!(ds, :U,   6.0)
set_parameter!(ds, :τ_C, 2.0)

# Run to steady state
step!(ds, 500.0)

# Print results
println("=== BASELINE RESULTS (Fixed D) ===")
println("z_b  = ", round(observe_state(ds, CTMLM.z_b),  digits=1), " m    (target: ~705)")
println("C    = ", round(observe_state(ds, CTMLM.C),    digits=3), "      (target: ~0.85)")
println("Δ₊s  = ", round(observe_state(ds, CTMLM.Δ₊s), digits=2), " K    (target: ~8.8)")
println("SST  = ", round(observe_state(ds, CTMLM.SST),  digits=2), " K")
