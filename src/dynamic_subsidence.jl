# =============================================================
# dynamic_subsidence.jl
# New process: dynamic subsidence D(t) from FT energy balance
# Author: Raghab Pokhrel
# Master Thesis 2026
# Prof. Dr. Stefan Buehler Group, Universität Hamburg
# =============================================================

import ConceptualClimateModels.CloudToppedMixedLayerModel as CTMLM
using ConceptualClimateModels

# ── New parameters
@parameters τ_rad = 15.0 [description = "FT radiative relaxation timescale, days"]
@parameters Γ_rad = 8.0e-3 [description = "radiative equilibrium lapse rate, K/m"]

# ── New variable: dynamic subsidence
@variables D_dyn(t) = 5e-6 [
    bounds = (0.0, 3e-5),
    description = "dynamically computed large-scale divergence, 1/s"
]

"""
    dynamic_subsidence_process()

Computes D(t) from free-tropospheric energy balance
using Newtonian cooling approximation:

    D(t) = (T_FT - T_eq) / (τ_rad · z_b)

where:
- T_FT = s₊  (FT static energy at inversion height)
- T_eq = SST - Γ_rad · z_b  (radiative equilibrium temp)
- τ_rad = radiative relaxation timescale (~15 days)
"""
function dynamic_subsidence_process()
    T_FT = CTMLM.s₊
    T_eq = CTMLM.SST - Γ_rad * CTMLM.z_b
    return D_dyn ~ (T_FT - T_eq) / (τ_rad * CTMLM.z_b)
end

"""
    mlm_dynamic_coupled()

Boundary layer ODEs using dynamic D_dyn instead of fixed D.
Replaces mlm_dynamic() for the coupled model experiments.
"""
function mlm_dynamic_coupled()
    return [
        TimeDerivative(CTMLM.z_b,
            CTMLM.w_e - D_dyn * CTMLM.z_b - CTMLM.w_m,
            LiteralParameter(1/CTMLM.sec_in_day)
        ),
        TimeDerivative(CTMLM.s_b,
            (CTMLM.w_e * CTMLM.Δ₊s + (CTMLM.SHF - CTMLM.ΔF_s) /
            CTMLM.ρ₀ / CTMLM.cₚ) / CTMLM.z_b - CTMLM.s_x / CTMLM.sec_in_day,
            LiteralParameter(1/CTMLM.sec_in_day)
        ),
        TimeDerivative(CTMLM.q_b,
            (CTMLM.w_e * CTMLM.Δ₊q + (CTMLM.LHF - CTMLM.ΔF_q) /
            (CTMLM.ρ₀ * (CTMLM.ℓ_v/1e3))) / CTMLM.z_b - CTMLM.q_x / CTMLM.sec_in_day,
            LiteralParameter(1/CTMLM.sec_in_day)
        ),
    ]
end
