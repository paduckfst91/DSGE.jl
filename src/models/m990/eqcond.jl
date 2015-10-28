using Debug

# Expresses the equilibrium conditions in canonical form using Γ0, Γ1, C, Ψ, and Π matrices.
# Using the assigned states and equations in modelinds.jl, coefficients are specified in the
#   proper positions.

# Γ0 (num_states x num_states) holds coefficients of current time states.
# Γ1 (num_states x num_states) holds coefficients of lagged states.
# C  (num_states x 1) is a vector of constants
# Ψ  (num_states x num_shocks_exogenous) holds coefficients of iid shocks.
# Π  (num_states x num_states_expectational) holds coefficients of expectational states.

function eqcond(m::Model990) 
    endo = m.endogenous_states
    exo  = m.exogenous_shocks
    ex   = m.expected_shocks
    eq   = m.equilibrium_conditions

    Γ0 = zeros(num_states(m), num_states(m))
    Γ1 = zeros(num_states(m), num_states(m))
    C  = zeros(num_states(m), 1)
    Ψ  = zeros(num_states(m), num_shocks_exogenous(m))
    Π  = zeros(num_states(m), num_shocks_expectational(m))

    ### ENDOGENOUS STATES ###

    ### 1. Consumption Euler Equation

    # Sticky prices and wages
    Γ0[eq[:euler], endo[:c_t]]  = 1.
    Γ0[eq[:euler], endo[:R_t]]  = (1 - m[:h]*exp(-m[:zstar]))/(m[:σ_c]*(1 + m[:h]*exp(-m[:zstar])))
    Γ0[eq[:euler], endo[:b_t]]  = -1.
    Γ0[eq[:euler], endo[:E_π]] = -(1 - m[:h]*exp(-m[:zstar]))/(m[:σ_c]*(1 + m[:h]*exp(-m[:zstar])))
    Γ0[eq[:euler], endo[:z_t]]  = (m[:h]*exp(-m[:zstar]))/(1 + m[:h]*exp(-m[:zstar]))
    Γ0[eq[:euler], endo[:E_c]]  = -1/(1 + m[:h]*exp(-m[:zstar]))
    Γ0[eq[:euler], endo[:E_z]]  = -1/(1 + m[:h]*exp(-m[:zstar]))
    Γ0[eq[:euler], endo[:L_t]]  = -(m[:σ_c] - 1)*m[:wl_c]/(m[:σ_c]*(1 + m[:h]*exp(-m[:zstar])))
    Γ0[eq[:euler], endo[:E_L]]  = (m[:σ_c] - 1)*m[:wl_c]/(m[:σ_c]*(1 + m[:h]*exp(-m[:zstar])))
    Γ1[eq[:euler], endo[:c_t]]  = (m[:h]*exp(-m[:zstar]))/(1 + m[:h]*exp(-m[:zstar]))

    # Flexible prices and wages
    Γ0[eq[:euler_f], endo[:c_f_t]] = 1.
    Γ0[eq[:euler_f], endo[:r_f_t]] = (1 - m[:h]*exp(-m[:zstar]))/(m[:σ_c]*(1 + m[:h]*exp(-m[:zstar])))
    Γ0[eq[:euler_f], endo[:b_t]]   = -1.
    Γ0[eq[:euler_f], endo[:z_t]]   =   (m[:h]*exp(-m[:zstar]))/(1 + m[:h]*exp(-m[:zstar]))
    Γ0[eq[:euler_f], endo[:E_c_f]] = -1/(1 + m[:h]*exp(-m[:zstar]))
    Γ0[eq[:euler_f], endo[:E_z]]   = -1/(1 + m[:h]*exp(-m[:zstar]))
    Γ0[eq[:euler_f], endo[:L_f_t]] = -(m[:σ_c] - 1)*m[:wl_c]/(m[:σ_c]*(1 + m[:h]*exp(-m[:zstar])))
    Γ0[eq[:euler_f], endo[:E_L_f]] = (m[:σ_c] - 1)*m[:wl_c]/(m[:σ_c]*(1 + m[:h]*exp(-m[:zstar])))
    Γ1[eq[:euler_f], endo[:c_f_t]] = (m[:h]*exp(-m[:zstar]))/(1 + m[:h]*exp(-m[:zstar]))



    ### 2. Investment Euler Equation

    # Sticky prices and wages
    Γ0[eq[:inv], endo[:qk_t]] = -1/(m[:S′′]*exp(2.0*m[:zstar])*(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar])))
    Γ0[eq[:inv], endo[:i_t]]  = 1.
    Γ0[eq[:inv], endo[:z_t]]  = 1/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ1[eq[:inv], endo[:i_t]]  = 1/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:inv], endo[:E_i]]  = -m[:β]*exp((1 - m[:σ_c])*m[:zstar])/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:inv], endo[:E_z]]  = -m[:β]*exp((1 - m[:σ_c])*m[:zstar])/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:inv], endo[:μ_t]] = -1.

    # Flexible prices and wages
    Γ0[eq[:inv_f], endo[:qk_f_t]] = -1/(m[:S′′]*exp(2*m[:zstar])*(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar])))
    Γ0[eq[:inv_f], endo[:i_f_t]]  = 1.
    Γ0[eq[:inv_f], endo[:z_t]]    = 1/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ1[eq[:inv_f], endo[:i_f_t]]  = 1/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:inv_f], endo[:E_i_f]]  = -m[:β]*exp((1 - m[:σ_c])*m[:zstar])/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:inv_f], endo[:E_z]]    = -m[:β]*exp((1 - m[:σ_c])*m[:zstar])/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:inv_f], endo[:μ_t]]   = -1.



    ### 3. Financial Friction Block

    # Return to capital
    # Sticky prices and wages
    Γ0[eq[:capval], endo[:Rktil_t]] = 1.
    Γ0[eq[:capval], endo[:π_t]]    = -1.
    Γ0[eq[:capval], endo[:rk_t]]    = -m[:rkstar]/(1 + m[:rkstar] - m[:δ])
    Γ0[eq[:capval], endo[:qk_t]]    = -(1 - m[:δ])/(1 + m[:rkstar] - m[:δ])
    Γ1[eq[:capval], endo[:qk_t]]    = -1.

    # Spreads
    # Sticky prices and wages
    Γ0[eq[:spread], endo[:E_Rktil]] = 1.
    Γ0[eq[:spread], endo[:R_t]]     = -1.
    Γ0[eq[:spread], endo[:b_t]]     = (m[:σ_c]*(1 + m[:h]*exp(-m[:zstar])))/(1 - m[:h]*exp(-m[:zstar]))
    Γ0[eq[:spread], endo[:qk_t]]    = -m[:ζ_spb]
    Γ0[eq[:spread], endo[:kbar_t]]  = -m[:ζ_spb]
    Γ0[eq[:spread], endo[:n_t]]     = m[:ζ_spb]
    Γ0[eq[:spread], endo[:σ_ω_t]]  = -1.
    Γ0[eq[:spread], endo[:μe_t]]   = -1.

    # n evol
    # Sticky prices and wages
    Γ0[eq[:nevol], endo[:n_t]]     = 1.
    Γ0[eq[:nevol], endo[:γ_t]]  = -1.
    Γ0[eq[:nevol], endo[:z_t]]     = m[:γ_star]*m[:vstar]/m[:nstar]
    Γ0[eq[:nevol], endo[:Rktil_t]] = -m[:ζ_nRk]
    Γ0[eq[:nevol], endo[:π_t]]    = (m[:ζ_nRk] - m[:ζ_nR])
    Γ1[eq[:nevol], endo[:σ_ω_t]]  = -m[:ζ_nσ_ω]/m[:ζ_spσ_ω]
    Γ1[eq[:nevol], endo[:μe_t]]   = -m[:ζ_nμe]/m[:ζ_spμe]
    Γ1[eq[:nevol], endo[:qk_t]]    = m[:ζ_nqk]
    Γ1[eq[:nevol], endo[:kbar_t]]  = m[:ζ_nqk]
    Γ1[eq[:nevol], endo[:n_t]]     = m[:ζ_nn]
    Γ1[eq[:nevol], endo[:R_t]]     = -m[:ζ_nR]
    Γ1[eq[:nevol], endo[:b_t]]     = -m[:ζ_nR]

    # Flexible prices and wages - ASSUME NO FINANCIAL FRICTIONS
    Γ0[eq[:capval_f], endo[:E_rk_f]] = -m[:rkstar]/(1 + m[:rkstar] - m[:δ])
    Γ0[eq[:capval_f], endo[:E_qk_f]] = -(1 - m[:δ])/(1 + m[:rkstar] - m[:δ])
    Γ0[eq[:capval_f], endo[:qk_f_t]] = 1.
    Γ0[eq[:capval_f], endo[:r_f_t]]  = 1.
    Γ0[eq[:capval_f], endo[:b_t]]    = -(m[:σ_c]*(1 + m[:h]*exp(-m[:zstar])))/(1 - m[:h]*exp(-m[:zstar]))



    ### 4. Aggregate Production Function

    # Sticky prices and wages
    Γ0[eq[:output], endo[:y_t]] =  1.
    Γ0[eq[:output], endo[:k_t]] = -m[:Φ]*m[:α]
    Γ0[eq[:output], endo[:L_t]] = -m[:Φ]*(1 - m[:α])

    # Flexible prices and wages
    Γ0[eq[:output_f], endo[:y_f_t]] =  1.
    Γ0[eq[:output_f], endo[:k_f_t]] = -m[:Φ]*m[:α]
    Γ0[eq[:output_f], endo[:L_f_t]] = -m[:Φ]*(1 - m[:α])



    ### 5. Capital Utilization

    # Sticky prices and wages
    Γ0[eq[:caputl], endo[:k_t]]    =  1.
    Γ1[eq[:caputl], endo[:kbar_t]] =  1.
    Γ0[eq[:caputl], endo[:z_t]]    = 1.
    Γ0[eq[:caputl], endo[:u_t]]    = -1.

    # Flexible prices and wages
    Γ0[eq[:caputl_f], endo[:k_f_t]]    =  1.
    Γ1[eq[:caputl_f], endo[:kbar_f_t]] =  1.
    Γ0[eq[:caputl_f], endo[:z_t]]      = 1.
    Γ0[eq[:caputl_f], endo[:u_f_t]]    = -1.



    ### 6. Rental Rate of Capital

    # Sticky prices and wages
    Γ0[eq[:capsrv], endo[:u_t]]  = 1.
    Γ0[eq[:capsrv], endo[:rk_t]] = -(1 - m[:ppsi])/m[:ppsi]

    # Flexible prices and wages
    Γ0[eq[:capsrv_f], endo[:u_f_t]]  = 1.
    Γ0[eq[:capsrv_f], endo[:rk_f_t]] = -(1 - m[:ppsi])/m[:ppsi]



    ### 7. Evolution of Capital

    # Sticky prices and wages
    Γ0[eq[:capev], endo[:kbar_t]] = 1.
    Γ1[eq[:capev], endo[:kbar_t]] = 1 - m[:istar]/m[:kbarstar]
    Γ0[eq[:capev], endo[:z_t]]    = 1 - m[:istar]/m[:kbarstar]
    Γ0[eq[:capev], endo[:i_t]]    = -m[:istar]/m[:kbarstar]
    Γ0[eq[:capev], endo[:μ_t]]   = -m[:istar]*m[:S′′]*exp(2*m[:zstar])*(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))/m[:kbarstar]

    # Flexible prices and wages
    Γ0[eq[:capev_f], endo[:kbar_f_t]] = 1.
    Γ1[eq[:capev_f], endo[:kbar_f_t]] = 1 - m[:istar]/m[:kbarstar]
    Γ0[eq[:capev_f], endo[:z_t]]      = 1 - m[:istar]/m[:kbarstar]
    Γ0[eq[:capev_f], endo[:i_f_t]]    = -m[:istar]/m[:kbarstar]
    Γ0[eq[:capev_f], endo[:μ_t]]     = -m[:istar]*m[:S′′]*exp(2*m[:zstar])*(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))/m[:kbarstar]



    ### 8. Price Markup

    # Sticky prices and wages
    Γ0[eq[:mkupp], endo[:mc_t]] =  1.
    Γ0[eq[:mkupp], endo[:w_t]]  = -1.
    Γ0[eq[:mkupp], endo[:L_t]]  = -m[:α]
    Γ0[eq[:mkupp], endo[:k_t]]  =  m[:α]

    # Flexible prices and wages
    Γ0[eq[:mkupp_f], endo[:w_f_t]] = 1.
    Γ0[eq[:mkupp_f], endo[:L_f_t]] =  m[:α]
    Γ0[eq[:mkupp_f], endo[:k_f_t]] =  -m[:α]



    ### 9. Phillips Curve

    # Sticky prices and wages
    Γ0[eq[:phlps], endo[:π_t]] = 1.
    Γ0[eq[:phlps], endo[:mc_t]] =  -((1 - m[:ζ_p]*m[:β]*exp((1 - m[:σ_c])*m[:zstar]))*
        (1 - m[:ζ_p]))/(m[:ζ_p]*((m[:Φ]- 1)*m[:ϵ_p] + 1))/(1 + m[:ι_p]*m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ1[eq[:phlps], endo[:π_t]] = m[:ι_p]/(1 + m[:ι_p]*m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:phlps], endo[:E_π]] = -m[:β]*exp((1 - m[:σ_c])*m[:zstar])/(1 + m[:ι_p]*m[:β]*
        exp((1 - m[:σ_c])*m[:zstar]))

    # Comment out for counterfactual with no price mark up shock
    Γ0[eq[:phlps], endo[:λ_f_t]] = -(1 + m[:ι_p]*m[:β]*exp((1 - m[:σ_c])*m[:zstar]))/
        (1 + m[:ι_p]*m[:β]*exp((1 - m[:σ_c])*m[:zstar]))

    # Flexible prices and wages not necessary

    ### 10. Rental Rate of Capital

    # Sticky prices and wages
    Γ0[eq[:caprnt], endo[:rk_t]] = 1.
    Γ0[eq[:caprnt], endo[:k_t]]  = 1.
    Γ0[eq[:caprnt], endo[:L_t]]  = -1.
    Γ0[eq[:caprnt], endo[:w_t]]  = -1.

    # Flexible prices and wages
    Γ0[eq[:caprnt_f], endo[:rk_f_t]] = 1.
    Γ0[eq[:caprnt_f], endo[:k_f_t]] = 1.
    Γ0[eq[:caprnt_f], endo[:L_f_t]] = -1.
    Γ0[eq[:caprnt_f], endo[:w_f_t]] = -1.



    ### 11. Marginal Substitution

    # Sticky prices and wages
    Γ0[eq[:msub], endo[:μ_ω_t]] = 1.
    Γ0[eq[:msub], endo[:L_t]]   = m[:ν_l]
    Γ0[eq[:msub], endo[:c_t]]   = 1/(1 - m[:h]*exp(-m[:zstar]))
    Γ1[eq[:msub], endo[:c_t]]   = m[:h]*exp(-m[:zstar])/(1 - m[:h]*exp(-m[:zstar]))
    Γ0[eq[:msub], endo[:z_t]]   = m[:h]*exp(-m[:zstar]) /(1 - m[:h]*exp(-m[:zstar]))
    Γ0[eq[:msub], endo[:w_t]]   = -1.

    # Flexible prices and wages
    Γ0[eq[:msub_f], endo[:w_f_t]] = -1.
    Γ0[eq[:msub_f], endo[:L_f_t]] = m[:ν_l]
    Γ0[eq[:msub_f], endo[:c_f_t]] = 1/(1 - m[:h]*exp(-m[:zstar]))
    Γ1[eq[:msub_f], endo[:c_f_t]] = m[:h]*exp(-m[:zstar])/(1 - m[:h]*exp(-m[:zstar]))
    Γ0[eq[:msub_f], endo[:z_t]]   = m[:h]*exp(-m[:zstar])/(1 - m[:h]*exp(-m[:zstar]))


    ### 12. Evolution of Wages

    # Sticky prices and wages
    Γ0[eq[:wage], endo[:w_t]]   = 1
    Γ0[eq[:wage], endo[:μ_ω_t]] = (1 - m[:ζ_w]*m[:β]*exp((1 - m[:σ_c])*m[:zstar]))*
        (1 - m[:ζ_w])/(m[:ζ_w]*((m[:λ_w] - 1)*m[:ϵ_w] + 1))/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:wage], endo[:π_t]]  = (1 + m[:ι_w]*m[:β]*exp((1 - m[:σ_c])*m[:zstar]))/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ1[eq[:wage], endo[:w_t]]   = 1/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:wage], endo[:z_t]]   = 1/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ1[eq[:wage], endo[:π_t]]  = m[:ι_w]/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:wage], endo[:E_w]]   = -m[:β]*exp((1 - m[:σ_c])*m[:zstar])/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:wage], endo[:E_z]]   = -m[:β]*exp((1 - m[:σ_c])*m[:zstar])/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:wage], endo[:E_π]]  = -m[:β]*exp((1 - m[:σ_c])*m[:zstar])/(1 + m[:β]*exp((1 - m[:σ_c])*m[:zstar]))
    Γ0[eq[:wage], endo[:λ_w_t]] = -1.

    # Flexible prices and wages not necessary



    ### 13. Monetary Policy Rule

    # Sticky prices and wages
    Γ0[eq[:mp], endo[:R_t]]    = 1.
    Γ1[eq[:mp], endo[:R_t]]    = m[:ρ]
    Γ0[eq[:mp], endo[:π_t]]   = -(1 - m[:ρ])*m[:ψ1]
    Γ0[eq[:mp], endo[:π_star_t]] = (1 - m[:ρ])*m[:ψ1]
    Γ0[eq[:mp], endo[:y_t]]    = -(1 - m[:ρ])*m[:ψ2] - m[:ψ3]
    Γ0[eq[:mp], endo[:y_f_t]]  = (1 - m[:ρ])*m[:ψ2] + m[:ψ3]
    Γ1[eq[:mp], endo[:y_t]]    = -m[:ψ3]
    Γ1[eq[:mp], endo[:y_f_t]]  = m[:ψ3]
    Γ0[eq[:mp], endo[:rm_t]]   = -1.

    # Flexible prices and wages not necessary



    ### 14. Resource Constraint

    # Sticky prices and wages
    Γ0[eq[:res], endo[:y_t]] = 1.
    Γ0[eq[:res], endo[:g_t]] = -m[:g_star]
    Γ0[eq[:res], endo[:c_t]] = -m[:cstar]/m[:ystar]
    Γ0[eq[:res], endo[:i_t]] = -m[:istar]/m[:ystar]
    Γ0[eq[:res], endo[:u_t]] = -m[:rkstar]*m[:kstar]/m[:ystar]

    # Flexible prices and wages
    Γ0[eq[:res_f], endo[:y_f_t]] = 1.
    Γ0[eq[:res_f], endo[:g_t]]   = -m[:g_star]
    Γ0[eq[:res_f], endo[:c_f_t]] = -m[:cstar]/m[:ystar]
    Γ0[eq[:res_f], endo[:i_f_t]] = -m[:istar]/m[:ystar]
    Γ0[eq[:res_f], endo[:u_f_t]] = -m[:rkstar]*m[:kstar]/m[:ystar]



    ### 15. Extra States
    # These aren't strictly necessary, but they track lags or simplify the equations

    # π_t1
    Γ0[eq[:π1], endo[:π_t1]] = 1.
    Γ1[eq[:π1], endo[:π_t]]  = 1.

    # π_t2
    Γ0[eq[:π2], endo[:π_t2]] = 1.
    Γ1[eq[:π2], endo[:π_t1]] = 1.

    # π_a
    Γ0[eq[:π_a], endo[:π_a_t]] = 1.
    Γ0[eq[:π_a], endo[:π_t]]   = -1.
    Γ0[eq[:π_a], endo[:π_t1]]  = -1.
    Γ0[eq[:π_a], endo[:π_t2]]  = -1.
    Γ1[eq[:π_a], endo[:π_t2]]  = 1.

    # Rt1
    Γ0[eq[:Rt1], endo[:R_t1]] = 1.
    Γ1[eq[:Rt1], endo[:R_t]]  = 1.

    # E_z
    Γ0[eq[:eq_Ez], endo[:E_z]]    = 1.
    Γ0[eq[:eq_Ez], endo[:ztil_t]] = -(m[:ρ_z]-1)/(1-m[:α])
    Γ0[eq[:eq_Ez], endo[:zp_t]]   = -m[:ρ_z_p]



    ### EXOGENOUS SHOCKS ###

    # Neutral technology
    Γ0[eq[:eq_z], endo[:z_t]]    = 1.
    Γ1[eq[:eq_z], endo[:ztil_t]] = (m[:ρ_z] - 1)/(1 - m[:α])
    Γ0[eq[:eq_z], endo[:zp_t]]   = -1.
    Ψ[eq[:eq_z], exo[:z_sh]]     = 1/(1 - m[:α])

    Γ0[eq[:eq_ztil], endo[:ztil_t]] = 1.
    Γ1[eq[:eq_ztil], endo[:ztil_t]] = m[:ρ_z]
    Ψ[eq[:eq_ztil], exo[:z_sh]]     = 1.

    # Long-run changes to productivity
    Γ0[eq[:eq_zp], endo[:zp_t]] = 1.
    Γ1[eq[:eq_zp], endo[:zp_t]] = m[:ρ_z_p]
    Ψ[eq[:eq_zp], exo[:zp_sh]]  = 1.

    # Government spending
    Γ0[eq[:eq_g], endo[:g_t]] = 1.
    Γ1[eq[:eq_g], endo[:g_t]] = m[:ρ_g]
    Ψ[eq[:eq_g], exo[:g_sh]]  = 1.
    Ψ[eq[:eq_g], exo[:z_sh]]  = m[:η_gz]

    # Asset shock
    Γ0[eq[:eq_b], endo[:b_t]] = 1.
    Γ1[eq[:eq_b], endo[:b_t]] = m[:ρ_b]
    Ψ[eq[:eq_b], exo[:b_sh]]  = 1.

    # Investment-specific technology
    Γ0[eq[:eq_μ], endo[:μ_t]] = 1.
    Γ1[eq[:eq_μ], endo[:μ_t]] = m[:ρ_μ]
    Ψ[eq[:eq_μ], exo[:μ_sh]]  = 1.

    # Price mark-up shock
    Γ0[eq[:eq_λ_f], endo[:λ_f_t]]  = 1.
    Γ1[eq[:eq_λ_f], endo[:λ_f_t]]  = m[:ρ_λ_f]
    Γ1[eq[:eq_λ_f], endo[:λ_f_t1]] = -m[:η_λ_f]
    Ψ[eq[:eq_λ_f], exo[:λ_f_sh]]   = 1.

    Γ0[eq[:eq_λ_f1], endo[:λ_f_t1]] = 1.
    Ψ[eq[:eq_λ_f1], exo[:λ_f_sh]]   = 1.

    # Wage mark-up shock
    Γ0[eq[:eq_λ_w], endo[:λ_w_t]]  = 1.
    Γ1[eq[:eq_λ_w], endo[:λ_w_t]]  = m[:ρ_λ_w]
    Γ1[eq[:eq_λ_w], endo[:λ_w_t1]] = -m[:η_λ_w]
    Ψ[eq[:eq_λ_w], exo[:λ_w_sh]]   = 1.

    Γ0[eq[:eq_λ_w1], endo[:λ_w_t1]] = 1.
    Ψ[eq[:eq_λ_w1], exo[:λ_w_sh]]   = 1.

    # Monetary policy shock
    Γ0[eq[:eq_rm], endo[:rm_t]] = 1.
    Γ1[eq[:eq_rm], endo[:rm_t]] = m[:ρ_rm]
    Ψ[eq[:eq_rm], exo[:rm_sh]]  = 1.



    ### Financial frictions

    # σ_ω shock
    Γ0[eq[:eq_σ_ω], endo[:σ_ω_t]] = 1.
    Γ1[eq[:eq_σ_ω], endo[:σ_ω_t]] = m[:ρ_σ_w]
    Ψ[eq[:eq_σ_ω], exo[:σ_ω_sh]]  = 1.

    # μe shock
    Γ0[eq[:eq_μe], endo[:μe_t]] = 1.
    Γ1[eq[:eq_μe], endo[:μe_t]] = m[:ρ_μe]
    Ψ[eq[:eq_μe], exo[:μe_sh]]  = 1.

    # γ shock
    Γ0[eq[:eq_γ], endo[:γ_t]] = 1.
    Γ1[eq[:eq_γ], endo[:γ_t]] = m[:ρ_γ]
    Ψ[eq[:eq_γ], exo[:γ_sh]]  = 1.

    # Long-term inflation expectations
    Γ0[eq[:eq_π_star], endo[:π_star_t]] = 1.
    Γ1[eq[:eq_π_star], endo[:π_star_t]] = m[:ρ_π_star]
    Ψ[eq[:eq_π_star], exo[:π_star_sh]]  = 1.

    # Anticipated policy shocks
    if num_anticipated_shocks(m) > 0 

        # This section adds the anticipated shocks. There is one state for all the
        # anticipated shocks that will hit in a given period (i.e. rm_tl2 holds those that
        # will hit in two periods), and the equations are set up so that rm_tl2 last period
        # will feed into rm_tl1 this period (and so on for other numbers), and last period's
        # rm_tl1 will feed into the rm_t process (and affect the Taylor Rule this period).

        Γ1[eq[:eq_rm], endo[:rm_tl1]]   = 1.
        Γ0[eq[:eq_rml1], endo[:rm_tl1]] = 1.
        Ψ[eq[:eq_rml1], exo[:rm_shl1]]  = 1.

        if num_anticipated_shocks(m) > 1
            for i = 2:num_anticipated_shocks(m)
                Γ1[eq[symbol("eq_rml$(i-1)")], endo[symbol("rm_tl$i")]] = 1.
                Γ0[eq[symbol("eq_rml$i")], endo[symbol("rm_tl$i")]] = 1.
                Ψ[eq[symbol("eq_rml$i")], exo[symbol("rm_shl$i")]] = 1.
            end
        end
    end



    ### EXPECTATION ERRORS ###

    ### E(c)

    # Sticky prices and wages
    Γ0[eq[:eq_Ec], endo[:c_t]]         = 1.
    Γ1[eq[:eq_Ec], endo[:E_c]]         = 1.
    Π[eq[:eq_Ec], ex[:Ec_sh]]          = 1.

    # Flexible prices and wages
    Γ0[eq[:eq_Ec_f], endo[:c_f_t]]     = 1.
    Γ1[eq[:eq_Ec_f], endo[:E_c_f]]     = 1.
    Π[eq[:eq_Ec_f], ex[:Ec_f_sh]]      = 1.



    ### E(q)

    # Sticky prices and wages
    Γ0[eq[:eq_Eqk], endo[:qk_t]]       = 1.
    Γ1[eq[:eq_Eqk], endo[:E_qk]]       = 1.
    Π[eq[:eq_Eqk], ex[:Eqk_sh]]        = 1.

    # Flexible prices and wages
    Γ0[eq[:eq_Eqk_f], endo[:qk_f_t]]   = 1.
    Γ1[eq[:eq_Eqk_f], endo[:E_qk_f]]   = 1.
    Π[eq[:eq_Eqk_f], ex[:Eqk_f_sh]]    = 1.

    ### E(i)

    # Sticky prices and wages
    Γ0[eq[:eq_Ei], endo[:i_t]]         = 1.
    Γ1[eq[:eq_Ei], endo[:E_i]]         = 1.
    Π[eq[:eq_Ei], ex[:Ei_sh]]          = 1.

    # Flexible prices and wages
    Γ0[eq[:eq_Ei_f], endo[:i_f_t]]     = 1.
    Γ1[eq[:eq_Ei_f], endo[:E_i_f]]     = 1.
    Π[eq[:eq_Ei_f], ex[:Ei_f_sh]]      = 1.



    ### E(π)

    # Sticky prices and wages
    Γ0[eq[:eq_Eπ], endo[:π_t]]       = 1.
    Γ1[eq[:eq_Eπ], endo[:E_π]]       = 1.
    Π[eq[:eq_Eπ], ex[:Eπ_sh]]        = 1.



    ### E(l)

    # Sticky prices and wages
    Γ0[eq[:eq_EL], endo[:L_t]]         = 1.
    Γ1[eq[:eq_EL], endo[:E_L]]         = 1.
    Π[eq[:eq_EL], ex[:EL_sh]]          = 1.

    # Flexible prices and wages
    Γ0[eq[:eq_EL_f], endo[:L_f_t]]     = 1.
    Γ1[eq[:eq_EL_f], endo[:E_L_f]]     = 1.
    Π[eq[:eq_EL_f], ex[:EL_f_sh]]      = 1.



    ### E(rk)

    # Sticky prices and wages
    Γ0[eq[:eq_Erk], endo[:rk_t]]       = 1.
    Γ1[eq[:eq_Erk], endo[:E_rk]]       = 1.
    Π[eq[:eq_Erk], ex[:Erk_sh]]        = 1.

    # Flexible prices and wages
    Γ0[eq[:eq_Erk_f], endo[:rk_f_t]]   = 1.
    Γ1[eq[:eq_Erk_f], endo[:E_rk_f]]   = 1.
    Π[eq[:eq_Erk_f], ex[:Erk_f_sh]]    = 1.



    ### E(w)

    # Sticky prices and wages
    Γ0[eq[:eq_Ew], endo[:w_t]]         = 1.
    Γ1[eq[:eq_Ew], endo[:E_w]]         = 1.
    Π[eq[:eq_Ew], ex[:Ew_sh]]          = 1.



    ### E(Rktil)

    # Sticky prices and wages
    Γ0[eq[:eq_ERktil], endo[:Rktil_t]] = 1.
    Γ1[eq[:eq_ERktil], endo[:E_Rktil]] = 1.
    Π[eq[:eq_ERktil], ex[:ERktil_sh]]  = 1.



    return Γ0, Γ1, C, Ψ, Π
end