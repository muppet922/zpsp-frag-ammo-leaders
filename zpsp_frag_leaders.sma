// Modules
#include <amxmodx>
#include <zombie_plague_special>
#include <bitsums>

// Constants
#define MAX_LEADERS 3

// Global variables
new g_pcvarDisplayMode, g_pcvarLeaderCount, g_maxPlayers, g_isRoundEnded, g_bsConnected;

enum DisplayMode {
    DISPLAY_OFF,
    DISPLAY_ROUND_START,
    DISPLAY_WELCOME_MESSAGE,
    DISPLAY_ROUND_END
};

public plugin_init() {
    register_plugin("[ZPNM] Frags/Packs Leaders", "1.3.4", "D i 5 7 i n c T")
    
    register_dictionary("zpnm_frags-packs_leaders.txt")
    
    register_event("HLTV", "ev_RoundStart", "a", "1=0", "2=0")
    register_event("TextMsg", "ev_RoundEnd", "a", "2=#Game_Commencing", "2=#Game_will_restart_in")
    
    register_logevent("ev_RoundEnd", 2, "1=Round_End")
    
    g_pcvarDisplayMode = register_cvar("zp_leaders_display_mode", "3")
    g_pcvarLeaderCount = register_cvar("zp_leaders_count", "2")
    
    g_maxPlayers = get_maxplayers();
}

public ev_RoundStart() {
    g_isRoundEnded = false;
    
    new DisplayMode:displayMode = DisplayMode:get_pcvar_num(g_pcvarDisplayMode);
    
    if (displayMode == DISPLAY_ROUND_START) {
        remove_task();
        display_leaders();
    } else if (displayMode == DISPLAY_WELCOME_MESSAGE) {
        remove_task();
        set_task(2.2, "display_leaders");
    }
}

public ev_RoundEnd() {
    if (g_isRoundEnded) return;
    
    g_isRoundEnded = true;
    
    if (DisplayMode:get_pcvar_num(g_pcvarDisplayMode) == DISPLAY_ROUND_END) {
        remove_task();
        display_leaders();
    }
}

public client_putinserver(id) {
    bitsum_add(g_bsConnected, id);
}

public client_disconnected(id) {
    bitsum_del(g_bsConnected, id);
}

public display_leaders() {
    new leaderCount = clamp(get_pcvar_num(g_pcvarLeaderCount), 1, MAX_LEADERS);
    new fragLeaders[MAX_LEADERS], packLeaders[MAX_LEADERS];
    new fragCounts[MAX_LEADERS], packCounts[MAX_LEADERS];
    
    get_top_frag_players(fragLeaders, fragCounts, leaderCount);
    get_top_pack_players(packLeaders, packCounts, leaderCount);
    
    if (!fragLeaders[0] && !packLeaders[0]) return;
    
    new fragMessage[256], packMessage[256];
    format_leader_message(fragMessage, charsmax(fragMessage), fragLeaders, fragCounts, leaderCount, "ZPNM_FRAGS_LEADERS");
    format_leader_message(packMessage, charsmax(packMessage), packLeaders, packCounts, leaderCount, "ZPNM_PACKS_LEADERS");
    
    for (new id = 1; id <= g_maxPlayers; id++) {
        if (!bitsum_get(g_bsConnected, id)) continue;
        
        if (fragLeaders[0]) client_print_color(id, fragLeaders[0], "%s", fragMessage);
        if (packLeaders[0]) client_print_color(id, packLeaders[0], "%s", packMessage);
    }
}

get_top_frag_players(leaders[], counts[], count) {
    for (new id = 1; id <= g_maxPlayers; id++) {
        if (!bitsum_get(g_bsConnected, id)) continue;
        
        // Skip bots - only include human players
        if (is_user_bot(id)) continue;
        
        new frags = get_user_frags(id);
        for (new i = 0; i < count; i++) {
            if (frags > counts[i]) {
                for (new j = count - 1; j > i; j--) {
                    leaders[j] = leaders[j-1];
                    counts[j] = counts[j-1];
                }
                leaders[i] = id;
                counts[i] = frags;
                break;
            }
        }
    }
}

get_top_pack_players(leaders[], counts[], count) {
    for (new id = 1; id <= g_maxPlayers; id++) {
        if (!bitsum_get(g_bsConnected, id)) continue;
        
        // Skip bots - only include human players
        if (is_user_bot(id)) continue;
        
        new packs = zp_get_user_ammo_packs(id);
        for (new i = 0; i < count; i++) {
            if (packs > counts[i]) {
                for (new j = count - 1; j > i; j--) {
                    leaders[j] = leaders[j-1];
                    counts[j] = counts[j-1];
                }
                leaders[i] = id;
                counts[i] = packs;
                break;
            }
        }
    }
}

format_leader_message(message[], len, leaders[], counts[], count, const lang_key[]) {
    new temp[128];
    formatex(message, len, "^1[^4ZvH^1]^4 %L^1:^3 ", LANG_PLAYER, lang_key);
    
    // Count actual leaders
    new actualCount = 0;
    for (new i = 0; i < count; i++) {
        if (leaders[i]) actualCount++;
    }
    
    // Format each leader
    for (new i = 0; i < count && leaders[i]; i++) {
        new name[32];
        get_user_name(leaders[i], name, charsmax(name));
        
        // Add comma only between items, not after the last one
        formatex(temp, charsmax(temp), "%s%s^1(^4%d^1)%s", 
            i > 0 ? "^4, " : "",  // Add comma prefix for all but first item
            name, 
            counts[i],
            i < actualCount - 1 ? "" : "");  // No comma after last item
            
        add(message, len, temp);
    }
}