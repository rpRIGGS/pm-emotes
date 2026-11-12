-- PM Emotes: standalone model-aware seating, adapted from the MIT-licensed
-- emotes-nopixel-4.0 chair offset reference (see development/THIRD-PARTY-NOTICES.md).
-- Native FiveM implementation; no NPX, EON or ox_target dependency.
local chairModels = {
    { model = GetHashKey('prop_picnictable_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_picnictable_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_01a'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_01b'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_01c'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_03'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_04'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_05'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_06'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_08'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_09'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_10'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_bench_11'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('gabz_lamesapd_cellbench'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_fib_3b_bench'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_ld_bench01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_wait_bench_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_fa_chair01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.68, y = 0.07, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_fa_chair02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.07, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_m_dinechair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_club_stagechair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_fh_barcchair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_fh_dineeamesa'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_fh_dineeamesb'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_fh_dineeamesc'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_fh_easychair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_fh_kitnstool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_fh_singleseat'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_jarmchair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_j_dinechair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_j_stool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_d_highchair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = -0.05, x = 0.0, heading = -180.0 },
    { model = GetHashKey('v_res_m_dinechair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = -0.05, x = 0.0, heading = -180.0 },
    { model = GetHashKey('v_res_study_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = -0.05, x = 0.0, heading = -180.0 },
    { model = GetHashKey('v_res_trev_framechair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = -0.05, x = 0.0, heading = -180.0 },
    { model = GetHashKey('v_res_tre_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = -0.05, x = 0.0, heading = -180.0 },
    { model = GetHashKey('v_res_tre_officechair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = -0.05, x = 0.0, heading = -180.0 },
    { model = GetHashKey('v_res_tre_stool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.9, y = 0.15, x = 0.0, heading = -180.0 },
    { model = GetHashKey('v_res_tre_stool_leather'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.9, y = 0.15, x = 0.0, heading = -180.0 },
    { model = GetHashKey('v_res_tre_stool_scuz'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.9, y = 0.15, x = 0.0, heading = -180.0 },
    { model = GetHashKey('v_med_p_easychair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.68, y = 0.07, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_med_whickerchair1'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.0, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_yacht_lounger'), scenario = 'PROP_HUMAN_SEAT_SUNLOUNGER', z = -0.5, y = 0.35, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ret_chair_white'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ret_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ret_ta_stool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('xm_lab_chairarm_26'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('bkr_prop_weed_chair_01a'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_din_chair_04'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_din_chair_08'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_din_chair_09'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_din_chair_12'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_din_stool_04'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.15, y = 0.12, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairarm_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairarm_03'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairarm_09'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairarm_11'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairarm_12'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairarm_13'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairarm_23'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairarm_24'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairarm_25'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairarm_26'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairstool_12'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairstrip_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairstrip_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairstrip_03'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairstrip_04'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairstrip_05'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairstrip_06'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairstrip_07'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('apa_mp_h_stn_chairstrip_08'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_patio_lounger_2'), scenario = 'PROP_HUMAN_SEAT_SUNLOUNGER', z = -0.6, y = 0.2, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_patio_lounger_3'), scenario = 'PROP_HUMAN_SEAT_SUNLOUNGER', z = -0.6, y = 0.2, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_patio_lounger1'), scenario = 'PROP_HUMAN_SEAT_SUNLOUNGER', z = -0.6, y = -0.2, x = 0.0, heading = 0.0 },
    { model = GetHashKey('gr_dlc_gr_yacht_props_lounger'), scenario = 'PROP_HUMAN_SEAT_SUNLOUNGER', z = -0.5, y = 0.33, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_patio_lounger1_s'), scenario = 'PROP_HUMAN_SEAT_SUNLOUNGER', z = -0.6, y = -0.2, x = 0.0, heading = 0.0 },
    { model = GetHashKey('np_fx_sit_anywhere'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.92, y = 0.08, x = 0.0, heading = -90.0 },
    { model = GetHashKey('np_fx_lounge_anywhere'), scenario = 'PROP_HUMAN_SEAT_SUNLOUNGER', z = -0.96, y = 0.0, x = 0.0, heading = -90.0 },
    { model = GetHashKey('v_serv_ct_chair02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.0, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('hei_prop_heist_off_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('hei_prop_hei_skid_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.92, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_01a'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_01b'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_03'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_04a'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.11, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_04b'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_05'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_06'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_05'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_08'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.0, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_09'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chair_10'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_chateau_chair_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_clown_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_cs_office_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_direct_chair_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.82, y = 0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_direct_chair_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.8, y = 0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_gc_chair02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.0, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_off_chair_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_off_chair_03'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_off_chair_04'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_off_chair_04b'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_off_chair_04_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_off_chair_05'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_old_deck_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.15, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_old_wood_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_rock_chair_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.85, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_skid_chair_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_skid_chair_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.85, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_skid_chair_03'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.85, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_sol_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_wheelchair_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.92, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_wheelchair_01_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.42, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_armchair_01_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_clb_officechair_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_dinechair_01_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_ilev_p_easychair_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_soloffchair_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_yacht_chair_01_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_club_officechair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_corp_bk_chair3'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.08, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_corp_cd_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.09, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_corp_offchair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_chair02_ped'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_hd_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_p_easychair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ret_gc_chair03'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.25, y = -0.05, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_ld_farm_chair01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_table_04_chr'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_table_05_chr'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_table_06_chr'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_leath_chr'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_table_01_chr_a'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.0, y = 0.08, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_table_01_chr_b'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.97, y = 0.1, x = 0.01, heading = -90.0 },
    { model = GetHashKey('prop_table_02_chr'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.08, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_table_03b_chr'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_table_03_chr'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_torture_ch_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.9, y = -0.05, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_fh_dineeamesa'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_fh_kitchenstool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_tort_stool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_fh_kitchenstool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_fh_kitchenstool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_fh_kitchenstool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_fh_kitchenstool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('hei_prop_yah_seat_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('hei_prop_yah_seat_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('hei_prop_yah_seat_03'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_waiting_seat_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_yacht_seat_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_yacht_seat_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_yacht_seat_03'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.36, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_hobo_seat_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.65, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_rub_couch01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('miss_rub_couch_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_ld_farm_couch01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_ld_farm_couch02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_rub_couch02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_rub_couch03'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_rub_couch04'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_lev_sofa_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_res_sofa_l_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_v_med_p_sofa_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('p_yacht_sofa_01_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_ilev_m_sofa'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_tre_sofa_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_tre_sofa_mess_a_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_tre_sofa_mess_b_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_tre_sofa_mess_c_s'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_roller_car_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('prop_roller_car_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('ex_prop_offchair_exec_04'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('ba_prop_battle_club_chair_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.1, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('ba_prop_int_glam_stool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.3, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('np_town_hall_judge_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.0, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('vw_prop_vw_offchair_02'), scenario = 'PROP_HUMAN_SEAT_ARMCHAIR', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('vw_prop_casino_chair_01a'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.25, y = -0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('v_res_mbchair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.02, x = 0.0, heading = 180.0 },
    { model = GetHashKey('V_Res_M_L_Chair1'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = -0.05, x = 0.0, heading = 180.0 },
    { model = GetHashKey('V_Ret_Chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = -0.05, x = 0.0, heading = 180.0 },
    { model = GetHashKey('V_Ret_GC_Chair01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.6, y = 0.11, x = 0.0, heading = 180.0 },
    { model = GetHashKey('V_Ret_GC_Chair02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.95, y = 0.11, x = 0.0, heading = 180.0 },
    { model = GetHashKey('ba_Prop_Battle_Club_Chair_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.1, y = 0.0, x = 0.0, heading = 180.0 },
    { model = GetHashKey('V_Res_M_ArmChair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = -0.05, x = 0.0, heading = 180.0 },
    { model = GetHashKey('v_serv_ct_chair01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.0, y = 0.325, x = 0.0, heading = 180.0 },
    { model = GetHashKey('np_mp_h_din_chair_09'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.2, x = 0.0, heading = 180.0 },
    { model = GetHashKey('prop_bar_stool_01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.2, y = 0.2, x = 0.0, heading = 180.0 },
    { model = GetHashKey('v_med_p_deskchair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.0, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('gabz_pdprops_chair02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.1, x = 0.0, heading = 0.0 },
    { model = GetHashKey('np_black_simple_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('xee_news_cinema_seat_1'), scenario = 'PROP_HUMAN_SEAT_DECKCHAIR', z = -1.1, y = -0.2, x = 0.1, heading = 0.0 },
    { model = GetHashKey('xee_news_cinema_seat_2'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.1, y = -0.2, x = 0.1, heading = 0.0 },
    { model = GetHashKey('xee_news_cinema_seat_3'), scenario = 'PROP_HUMAN_SEAT_DECKCHAIR', z = -1.1, y = -0.2, x = 0.1, heading = 0.0 },
    { model = GetHashKey('ll_bar_stool'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.65, y = 0.0, x = 0.0, heading = 180.0 },
    { model = GetHashKey('ll_meetingroom_chair'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.53, y = 0.0, x = 0.0, heading = 180.0 },
    { model = GetHashKey('v_corp_bk_chair2'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -1.0, y = 0.1, x = 0.0, heading = 180.0 },
    { model = GetHashKey('gabz_pdprops_chair01'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.0, x = 0.0, heading = 180.0 },
    { model = GetHashKey('sf_prop_sf_bench_piano_01a_np'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.0, x = 0.0, heading = 0.0 },
    { model = GetHashKey('sf_prop_sf_chair_stool_08a_np'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.0, x = 0.0, heading = -90.0 },
    { model = GetHashKey('xm_base_cia_chair_conf'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = -0.1, x = 0.05, heading = -180.0 },
    { model = GetHashKey('sm_op_prop_chair_002'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0, x = 0.05, heading = -180.0 },
    { model = GetHashKey('sm_op_prop_off_chair_001'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.05, x = 0.05, heading = -180.0 },
    { model = GetHashKey('sm_op_prop_armchair_001'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.05, x = 0.05, heading = -180.0 },
    { model = GetHashKey('hane_bc_sheriff_wood_chair_b'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.5, y = 0.05, x = 0.05, heading = -180.0 },
    { model = GetHashKey('hane_bc_sheriff_off_chair_a'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.0, x = 0.05, heading = -180.0 },
    { model = GetHashKey('lab_chr'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.25, y = 0.1, x = 0.05, heading = -180.0 },
    { model = GetHashKey('hn_h_stn_chairarm_02'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = -0.325, x = 0.05, heading = -180.0 },
    { model = GetHashKey('hn_bcmed_chair_b'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.05, x = 0.05, heading = -180.0 },
    { model = GetHashKey('sm_op_prop_chair_001'), scenario = 'PROP_HUMAN_SEAT_CHAIR_MP_PLAYER', z = -0.45, y = 0.05, x = 0.05, heading = -180.0 },
    { model = GetHashKey('prop_ld_toilet_01'), scenario = 'PROP_HUMAN_SEAT_ARMCHAIR', z = -0.875, y = 0.0, x = 0, heading = -180.0 },
}

local seated = false
local function findChair()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closest, config, distance = nil, nil, 2.25
    for i = 1, #chairModels do
        local entry = chairModels[i]
        local entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.25, entry.model, false, false, false)
        if entity and entity ~= 0 and DoesEntityExist(entity) then
            local dist = #(coords - GetEntityCoords(entity))
            if dist < distance then
                closest, config, distance = entity, entry, dist
            end
        end
    end
    return closest, config
end

local function stand()
    if not seated then return end
    seated = false
    ClearPedTasks(PlayerPedId())
end

function PMToggleNearbySeat()
    local ped = PlayerPedId()
    if seated then stand() return end
    if IsPedInAnyVehicle(ped, false) or IsPedDeadOrDying(ped, true) then return end
    if LocalPlayer.state.canEmote == false then return end
    local chair, config = findChair()
    if not chair then
        SimpleNotify('No supported chair within reach')
        return
    end
    -- The reference verticalOffset is measured down from the model's top,
    -- NOT down from the entity origin. Using it as an origin offset buried
    -- the player; discarding it broke model-specific chair heights.
    -- Keep the reference offset relative to the actual model bounds.
    local _, boundsMax = GetModelDimensions(GetEntityModel(chair))
    local seatHeight = math.max(0.0, boundsMax.z + config.z)
    local pos = GetOffsetFromEntityInWorldCoords(chair, config.x, config.y, seatHeight)
    -- Do not place the local player on top of another nearby seated player.
    for _, player in ipairs(GetActivePlayers()) do
        if player ~= PlayerId() then
            local otherPed = GetPlayerPed(player)
            if DoesEntityExist(otherPed) and IsPedUsingAnyScenario(otherPed) then
                if #(GetEntityCoords(otherPed) - pos) < 0.7 then
                    SimpleNotify('This seat is occupied')
                    return
                end
            end
        end
    end
    -- Most chair props face opposite the scenario ped's forward direction.
    -- Preserve each reference headingOffset as an adjustment to that base.
    local heading = (GetEntityHeading(chair) + 180.0 + config.heading) % 360.0
    EmoteCancel(true)
    -- Allow an existing emote's exit transition to settle before seating.
    Wait(150)
    if not DoesEntityExist(ped) or IsPedDeadOrDying(ped, true) or IsPedInAnyVehicle(ped, false) then return end
    TaskStartScenarioAtPosition(ped, config.scenario, pos.x, pos.y, pos.z, heading, 0, true, true)
    seated = true
end

RegisterCommand('pmsit', PMToggleNearbySeat, false)
RegisterCommand('pmstand', stand, false)

CreateThread(function()
    while true do
        if seated then
            local ped = PlayerPedId()
            if not IsPedUsingAnyScenario(ped) or IsPedDeadOrDying(ped, true) then
                seated = false
            end
            Wait(500)
        else
            Wait(1000)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then stand() end
end)
