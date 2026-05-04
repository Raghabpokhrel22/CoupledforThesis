# =============================================================
# 01_baseline_fixed_D.jl
# Reproduce baseline using the exact tutorial approach from
# Datseris (2025) - known working configuration
# Target: z_b ≈ 705m, C ≈ 0.85, Δ₊s ≈ 8.8 K
# =============================================================

using DynamicalSystems, ConceptualClimateModels
import ConceptualClimateModels.CloudToppedMixedLayerModel as CTMLM

eqs = [
    CTMLM.cf_dynamic(),
    CTMLM.decoupling_variable(),
    CTMLM.mlm_dynamic(),
    CTMLM.mlm_q₊(:relative),
    CTMLM.mlm_s₊(:difference),
    CTMLM.entrainment_velocity(:Stevens2006),
    CTMLM.mlm_radiative_cooling(:three_layer),
    CTMLM.cloud_longwave_cooling(),
    CTMLM.cloud_shortwave_warming(),
    CTMLM.cloud_emissivity(),
    CTMLM.cloud_albedo(),
    CTMLM.cloud_base_height(:Bolton1980),
    CTMLM.downwards_longwave_radiation(:three_layer),
    CTMLM.free_troposphere_emission_temperature(),
]

ds = processes_to_coupledodes(eqs, CTMLM)

# Set baseline parameters (fixed D)
set_parameter!(ds, :D,   5e-6)
set_parameter!(ds, :d_c, 0.0012)
set_parameter!(ds, :U,   6.0)
set_parameter!(ds, :τ_C, 2.0)
set_parameter!(ds, :RH₊, 0.2)

# Run to steady state - 500 days
step!(ds, 500.0)

# Print results
println("=== BASELINE RESULTS (Fixed D) ===")
println("z_b  = ", round(observe_state(ds, CTMLM.z_b),  digits=1), " m    (target: ~705)")
println("C    = ", round(observe_state(ds, CTMLM.C),    digits=3), "      (target: ~0.85)")
println("Δ₊s  = ", round(observe_state(ds, CTMLM.Δ₊s), digits=2), " K    (target: ~8.8)")
println("SST  = ", round(observe_state(ds, CTMLM.SST),  digits=2), " K")
println("LHF  = ", round(observe_state(ds, CTMLM.LHF),  digits=2), " W/m²")
