Lib.Blips = {}
Lib.Blips.Active = {}

function Lib.Blips.Create(style, color, sprite, scale, name)
    local t = type(style)
    local blip = nil
    if t == 'vector3' or t == 'vector4' or t == 'table' then
        blip = Lib.Natives.BlipAddForCoords(style.x, style.y, style.z, 1664425300)
    elseif t == 'number' or t == 'string' then
        if DoesEntityExist(tonumber(style)) then
            blip = Lib.Natives.AddBlipForEntity(tonumber(style), -1230993421)
        else
            print('Entity does not exist.')
        end
    else
        return false
    end

    if color then
        if Lib.Blips.Colors[color] then
            Lib.Natives.SetBlipColor(blip, tonumber(Lib.Blips.Colors[color]))
        else
            print(string.format('Blip color %s is invalid', color))
        end
    end

    if sprite then
        if type(sprite) == 'number' then
            Lib.Natives.SetBlipSprite(blip, sprite)
        elseif type(sprite) == 'string' then
            if Lib.Blips.Sprites[sprite] then
                Lib.Natives.SetBlipSprite(blip, tonumber(Lib.Blips.Sprites[sprite]))
            else
                print(string.format('Blip sprite %s is invalid', sprite))
            end
        else
            print(string.format('Blip sprite %s is invalid', sprite))
        end
    end

    if scale then
        Lib.Natives.SetBlipScale(blip, scale)
    end

    if name then
        Lib.Natives.SetBlipName(blip, name)
    end

    local id = #Lib.Blips.Active + 1
    Lib.Blips.Active[id] = blip
    return id, blip
end

RegisterNetEvent("blips:Create", Lib.Blips.Create)

function Lib.Blips.Remove(id)
    local blip = Lib.Blips.Active[id]
    if blip then
        Lib.Natives.SetThisScriptCanRemoveBlipsCreatedByAnyScript(1)
        Lib.Natives.RemoveBlip(blip)
        Lib.Blips.Active[id] = nil
    end
end

RegisterNetEvent("blips:Create", Lib.Blips.Create)
RegisterNetEvent("blips:Remove", Lib.Blips.Remove)

CreateThread(function()
    for i = 100, 100000 do -- Range of blip ids that are created by R* scripts
        if DoesBlipExist(i) then
            RemoveBlip(i)
        end
    end
end)

-- https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/blip_modifiers
Lib.Blips.Colors = {
    ['blue']   = GetHashKey('BLIP_MODIFIER_MP_COLOR_1'),
    ['red']    = GetHashKey('BLIP_MODIFIER_MP_COLOR_2'),
    ['purple'] = GetHashKey('BLIP_MODIFIER_MP_COLOR_3'),
    ['orange'] = GetHashKey('BLIP_MODIFIER_MP_COLOR_4'),
    ['teal']   = GetHashKey('BLIP_MODIFIER_MP_COLOR_5'),
    ['yellow'] = GetHashKey('BLIP_MODIFIER_MP_COLOR_6'),
    ['pink']   = GetHashKey('BLIP_MODIFIER_MP_COLOR_7'),
    ['green']  = GetHashKey('BLIP_MODIFIER_MP_COLOR_8'),
    ['mediumblue']   = GetHashKey('BLIP_MODIFIER_MP_COLOR_9'),
    ['darkred']    = GetHashKey('BLIP_MODIFIER_MP_COLOR_10'),
    ['darkgreen'] = GetHashKey('BLIP_MODIFIER_MP_COLOR_11'),
    ['darkteal'] = GetHashKey('BLIP_MODIFIER_MP_COLOR_12'),
    ['darkblue']   = GetHashKey('BLIP_MODIFIER_MP_COLOR_13'),
    ['darkpurple'] = GetHashKey('BLIP_MODIFIER_MP_COLOR_14'),
    ['grape']   = GetHashKey('BLIP_MODIFIER_MP_COLOR_15'),
    ['maroon']  = GetHashKey('BLIP_MODIFIER_MP_COLOR_16'),
    ['grey']  = GetHashKey('BLIP_MODIFIER_MP_COLOR_17'),
    ['darkpink']  = GetHashKey('BLIP_MODIFIER_MP_COLOR_18'),
    ['lime']  = GetHashKey('BLIP_MODIFIER_MP_COLOR_19'),
    ['forestgreen']  = GetHashKey('BLIP_MODIFIER_MP_COLOR_20'),
    ['lightblue']  = GetHashKey('BLIP_MODIFIER_MP_COLOR_21'),
    ['lightpurple']  = GetHashKey('BLIP_MODIFIER_MP_COLOR_22'),
    ['gold']  = GetHashKey('BLIP_MODIFIER_MP_COLOR_23'),
}
-- https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/textures/blips
Lib.Blips.Sprites = {
    ['bounty_hunter'] = -861219276,
    ['bounty_hunter_higher'] = -535302224,
    ['bounty_hunter_lower'] = 28148096,
    ['bounty_target'] = 1481032477,
    ['chore'] = 1321928545,
    ['coach'] = 1012165077,
    ['companion'] = -185399168,
    ['companion_higher'] = 54149631,
    ['companion_lower'] = -1971029474,
    ['corpse'] = -1116208957,
    ['death'] = 350569997,
    ['eyewitness'] = -2018361632,
    ['gang_leader'] = -1489164512,
    ['herd'] = 423351566,
    ['herd_straggler'] = -1979146842,
    ['higher'] = -920572370,
    ['hitching_post'] = 1220803671,
    ['horseshoe'] = -643888085,
    ['law'] = 	-1596758107,
    ['loan_shark'] = 1838354131,
    ['lower'] = 	-1843639063,
    ['new'] = 419258445,
    ['newspaper'] = 587827268,
    ['npc'] = 305281166,
    ['npc_higher'] = 978474677,
    ['npc_lower'] = -67528377,
    ['downed'] = 1453767378,
    ['medium'] = -1350763423,
    ['medium_higher'] = 1386031480,
    ['medium_lower'] = 1995891146,
    ['small'] = 692310,
    ['small_higher'] = 195811413,
    ['small_lower'] = 511626456,
    ['quartermaster'] = 249721687,
    ['riberboat'] = 2033397166,
    ['secret'] = 675509286,
    ['sheriff'] = -693644997,
    ['telegraph'] = 503049244,
    ['theatre'] = -417940443,
    ['tithing'] = 	-1954662204,
    ['tracking'] = -1580514024,
    ['train'] = -250506368,
    ['wagon'] = 874255393,
    ['warp'] = 784218150,
    ['arrow'] = 573732443,
    ['bullets'] = 1445158214,
    ['animal'] = -1646261997,
    ['animal_dead'] = 1340161527,
    ['quality_01'] = 1996684768,
    ['quality_02'] = -171082889,
    ['quality_03'] = 	-480291173,
    ['animal_skin'] = 218395012,
    ['connected'] = 1173759417,
    ['attention'] = -774688241,
    ['bank_debt'] = 1869246576,
    ['bath_house'] = -304640465,
    ['camp'] = 327180499,
    ['request'] = -1043855483,
    ['camp_tent'] = -910004446,
    ['campfire'] = 1754365229,
    ['campfire_full'] = 773587962,
    ['canoe'] = 62421675,
    ['cash_arthur'] = 1420154945,
    ['cash_bag'] = 688589278,
    ['chest'] = -1138864184,
    ['code_center'] = -758439257,
    ['code_center_on_horse'] = 648067515,
    ['code_waypoint'] = 960467426,
    ['deadeye_cross'] = 1754506823,
    ['destroy'] = 456887900,
    ['direction_pointer'] = 51988200,
    ['donate_food'] = -1236018085,
    ['event_appleseed'] = 1904459580,
    ['event_castor'] = -1989725258,
    ['event_railroad_camp'] = -487631996,
    ['event_riggs_camp'] = -1944395098,
    ['fence_building'] = -1179229323,
    ['for_sale'] = -1383036426,
    ['gang_savings'] = 571063529,
    ['gang_savings_special'] = 1350383321,
    ['grub'] = 935247438,
    ['hat'] = 990667866,
    ['horse_higher'] = 600220762,
    ['horse_lower'] = 2131881492,
    ['horse_owned'] = -1715189579,
    ['horse_owned_active'] = 1210165179,
    ['horse_owned_bonding_0'] = -217389439,
    ['horse_owned_bonding_1'] = 13992470,
    ['horse_owned_bonding_2'] = 396341162,
    ['horse_owned_bonding_3'] = 623069873,
    ['horse_owned_bonding_4'] = -637422489,
    ['horse_owned_hitched'] = -44909892,
    ['horse_temp'] = -641397381,
    ['horse_temp_bonding_0'] = 937553910,
    ['horse_temp_bonding_1'] = 489732756,
    ['horse_temp_bonding_2'] = 195204984,
    ['horse_temp_bonding_3'] = -103418913,
    ['horse_temp_bonding_4'] = -815685893,
    ['horse_temp_hitched'] = 444737100,
    ['horseshoe_0'] = 444737100,
    ['horseshoe_1'] = 2100933368,
    ['horseshoe_2'] = 1166328735,
    ['horseshoe_3'] = 1463641872,
    ['horseshoe_4'] = 687278724,
    ['hotel_bed'] = -211556852,
    ['job'] = -986795390,
    ['location_higher'] = -902701436,
    ['location_lower'] = -432067112,
    ['locked'] = 1255312268,
    ['blackjack'] = 595820042,
    ['dominoes'] = -1650465405,
    ['dominoes_all3s'] = -1581061148,
    ['dominoes_all5s'] = -48718882,
    ['dominoes_draw'] = -379108622,
    ['drinking'] = 	1242464081,
    ['fishing'] = -1575595762,
    ['five_finger_fillet'] = 1974815632,
    ['five_finger_fillet_burnout'] = 1015604260,
    ['five_finger_fillet_guts'] = 126262516,
    ['poker'] = 1243830185,
    ['mission_area_beau'] = -1477394468,
    ['mission_area_bill'] = 455154152,
    ['mission_area_bounty'] = 2125146709,
    ['mission_area_bronte'] = -7025387450,
    ['mission_area_david_geddes'] = 1403865185,
    ['mission_area_dutch'] = 1729623738,
    ['mission_area_eagle_flies'] = 508736310,
    ['mission_area_edith'] = -486409706,
    ['mission_area_grays'] = 1876890949,
    ['mission_area_gunslinger_1'] = -1849394918,
    ['mission_area_gunslinger_2'] = 1665113105,
    ['mission_area_henri'] = 1048219592,
    ['mission_area_hosea'] = 783937097,
    ['mission_area_javier'] = 495717394,
    ['mission_area_john'] = 231806605,
    ['mission_area_kitty'] = 1003036114,
    ['mission_area_leon'] = -686621143,
    ['mission_area_lightning'] = 1084717321,
    ['mission_area_loanshark'] = -1034306897,
    ['mission_area_mary'] = -925245417,
    ['mission_area_micah'] = -977737823,
    ['mission_area_rains'] = 1255014523,
    ['mission_area_rc'] = -1998899839,
    ['mission_area_reverend'] = -164151171,
    ['mission_area_sadie'] = 1631595563,
    ['mission_area_strauss'] = -721238161,
    ['mission_area_trelawney'] = -1245830589,
    ['mission_bg'] = -125278436,
    ['mission_bill'] = 944812202,
    ['mission_bounty'] = -907204276,
    ['mission_camp'] = -1125110489,
    ['mission_dutch'] = -106554210,
    ['mission_higher'] = 1605798866,
    ['mission_hosea'] = -1724301546,
    ['mission_john'] = -887880659,
    ['mission_lower'] = -839061276,
    ['mission_micah'] = 1267381595,
    ['mp_pickup'] = 1109348405,
    ['npc_search'] = 2031478856,
    ['objective'] = -570710357,
    ['objective_minor'] = 1192138201,
    ['overlay_1'] = 480724882,
    ['overlay_2'] = -300946848,
    ['overlay_3'] = 7900981,
    ['overlay_4'] = 1675187701,
    ['overlay_5'] = 1846307419,
    ['overlay_bill'] = 68100707,
    ['overlay_charles'] = -674292488,
    ['overlay_hosea'] = -985772686,
    ['overlay_javier'] = 495452413,
    ['overlay_john'] = -1764128257,
    ['overlay_karen'] = -1283959649,
    ['overlay_kieran'] = 577712810,
    ['overlay_lenny'] = -1491306790,
    ['overlay_loanshark'] = -1713383509,
    ['overlay_micah'] = 809358939,
    ['overlay_party'] = 1097265030,
    ['overlay_pearson'] = 1083384676,
    ['overlay_ring'] = -184692826,
    ['overlay_saddle'] = -271586249,
    ['overlay_sean'] = -656301087,
    ['overlay_strauss'] = 1737923688,
    ['overlay_tilly'] = 2009192597,
    ['overlay_uncle'] = 	-1706952903,
    ['overlay_white_1'] = -810005617,
    ['overlay_white_2'] = 	-512626942,
    ['overlay_white_3'] = -1268149006,
    ['overlay_white_4'] = -969951106,
    ['overlay_white_5'] = 1222000069,
    ['photo_studio'] = 1364029453,
    ['plant'] = -675651933,
    ['player'] = -523921054,
    ['player_coach'] = -361388975,
    ['poi'] = -2039778370,
    ['post_office'] = 1861010125,
    ['post_office_rec'] = 1475382911,
    ['proc_bank'] = -2128054417,
    ['proc_bounty_poster'] = -1636832113,
    ['proc_home'] = 1586273744,
    ['proc_home_locked'] = -1498696713,
    ['proc_loanshark'] = -997121570,
    ['proc_track'] = 421058601,
    ['radar_edge_pointer'] = -1192977721,
    ['radius_search'] = 150441873,
    ['rc'] = -1822497728,
    ['rc_albert'] = -1259688762,
    ['rc_algernon_wasp'] = 2107943776,
    ['rc_art'] = 	-434412386,
    ['rc_calloway'] = -1744398657,
    ['rc_chain_gang'] = 	-622951465,
    ['rc_charlotte_balfour'] = -1676833170,
    ['rc_crackpot'] = 877823184,
    ['rc_deborah'] = 1162303770,
    ['rc_gunslinger_1'] = 858349040,
    ['rc_gunslinger_2'] = 479604938,
    ['rc_gunslinger_3'] = 240424007,
    ['rc_gunslinger_5'] = 1813565390,
    ['rc_henri'] = 	-340501579,
    ['rc_hobbs'] = 1986498931,
    ['rc_jeremy_gill'] = 	-273196610,
    ['rc_kitty'] = 1970061205,
    ['rc_lightning'] = -1962480616,
    ['rc_obediah_hinton'] = 415367144,
    ['rc_odd_fellows'] = 825960713,
    ['rc_oh_brother'] = 	-1280269885,
    ['rc_old_flame'] = 1429600911,
    ['rc_slave_catcher'] = 194953189,
    ['rc_war_veteran'] = 1770336866,
    ['region_caravan'] = -1606321000,
    ['region_hideout'] = -428972082,
    ['region_hunting'] = 500148876,
    ['robbery_bank'] = 623155783,
    ['robbery_coach'] = 	-729441538,
    ['robbery_home'] = 444204045,
    ['rpg_overweight'] = 	-1107942598,
    ['rpg_underweight'] = 1111652008,
    ['saddle'] = 	-1327110633,

}