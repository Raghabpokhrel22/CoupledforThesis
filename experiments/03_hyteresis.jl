# =============================================================
# 03_hysteresis.jl
# Test whether coupled model shows hysteresis
# Forward sweep: reduce D → cloud collapses
# Backward sweep: increase D → does cloud recover?
# =============================================================

using DynamicalSystems, ConceptualClimateModels
import ConceptualClimateModels.CloudToppedMixedLayerModel as CTMLM

const cₚ = 1004.0

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

# Forward sweep: D from 4e-6 down to 1e-6
D_forward = range(4e-6, 1e-6, length = 20)
C_forward = Float64[]

set_parameter!(ds, :D, 4e-6)
step!(ds, 200.0)  # start from steady state

for D_val in D_forward
    set_parameter!(ds, :D, D_val)
    step!(ds, 200.0)
    push!(C_forward, observe_state(ds, CTMLM.C))
end

# Backward sweep: D from 1e-6 back up to 4e-6
D_backward = range(1e-6, 4e-6, length = 20)
C_backward = Float64[]

for D_val in D_backward
    set_parameter!(ds, :D, D_val)
    step!(ds, 200.0)
    push!(C_backward, observe_state(ds, CTMLM.C))
end

# Print results
println("=== HYSTERESIS RESULTS ===")
println("D_value      C_forward  C_backward")
for i in 1:20
    println(
        round(D_forward[i], sigdigits=2), "   ",
        round(C_forward[i],  digits=3),   "      ",
        round(C_backward[i], digits=3)
    )
end

# Check if hysteresis exists
max_diff = maximum(abs.(C_forward .- C_backward))
println("\nMax difference forward vs backward: ", round(max_diff, digits=4))
if max_diff > 0.05
    println("HYSTERESIS DETECTED ✅")
else
    println("No hysteresis found")
end
