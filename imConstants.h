//
//  Header.h
//  imPlayr2
//
//  Created by YAZ on 5/27/14.
//  Copyright (c) 2014 Haris Rafiq. All rights reserved.
//

#ifndef IMP_imPlayr_h
#define IMP_imPlayr_h



#endif
#ifdef __cplusplus
#define imPlayr_EXTERN extern "C"
#else /* __cplusplus */
#define imPlayr_EXTERN extern
#endif /* __cplusplus */



#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height >= 568.0f)
#define NOTIFICATION_INVITATION_RECEIVED @"notif_invitation_request"
#define NOTIFICATION_INVITATION_ACCEPTED @"notif_invitation_accepted"
#define NOTIFICATION_INVITATION_DECLINED @"notif_invitation_declined"
#define NOTIFICATION_iAD_LOADED @"notif_iad_loaded"
#define NOTIFICATION_iAD_FAILED @"notif_iad_failed"
#define NOTIFICATION_NO_MUSIC @"notif_no_music"
#define NOTIFICATION_PURCHASE_UPGRADE @"notif_purchase_upgrade"

#define NOTIFICATION_TRACK_PLAYING_ERROR @"notif_track_playing_error"
#define NOTIFICATION_TRACK_FINISHED_PLAYING @"notif_track_finished_playing"
#define NOTIFICATION_TRACK_CHANGED @"notif_track_changed"
#define NOTIFICATION_DID_SELECT_SONG @"notif_did_select_song"
#define NOTIFICATION_TRACK_STARTED_PLAYING @"notif_track_started_playing"
#define NOTIFICATION_TRACK_PAUSED @"notif_track_paused"
#define NOTIFICATION_TRACK_BUFFERING @"notif_track_buffering"
#define NOTIFICATION_TRACK_IDLE @"notif_track_idle"


#define NOTIFICATION_COLORS_UPDATING @"notif_colors_updating"
#define NOTIFICATION_NO_MORE_SONGS_TOSKIP @"notif_no_more_songs_toskip"

#define NOTIFICATION_COLORS_CHANGED @"notif_colors_changed"
#define NOTIFICATION_PLAYBACK_CHANGED @"notif_playback_changed"
#define NOTIFICATION_SEEKBAR_UPDATED @"notif_seekbar_updated"
#define NOTIFICATION_TOGGLE_ISHIDDEN @"notif_toggle_ishidden"
#define NOTIFICATION_VISUALIZER_SWITCH @"notif_visulaizer_switch"
#define NOTIFICATION_PLAY_FIRST_SONG @"notif_play_first_song"

#define NOTIFICATION_CLOSE_NOWPLAYING @"notif_close_nowplaying"
#define NOTIFICATION_SHUFFLE_TOGGLED @"notif_shuffle_toggled"
#define NOTIFICATION_REPEAT_TOGGLED @"notif_repeat_toggled"
#define NOTIFICATION_TOGGLE_COLOR_SLIDER @"notif_toggle_color_slider"

#define NOTIFICATION_CHANGE_MAIN_CONTROLLER @"notif_change_main_controller"

#define NOTIFICATION_SHOW_PLAYER_EDIT_CONTROLLER @"notif_show_player_edit_controller"

#define NOTIFICATION_HIDE_PLAYER_EDIT_CONTROLLER @"notif_hide_player_edit_controller"
#define NOTIFICATION_DELETE_ACTION @"notif_delete_action"
#define NOTIFICATION_CLEAR_ACTION @"notif_clear_action"
#define NOTIFICATION_SAVE_ACTION @"notif_save_action"
#define NOTIFICATION_TOGGLE_EDIT_ACTION @"notif_toggle_edit_action"



#define NOTIFICATION_TOGGLE_MENU @"notif_toggle_menu"
#define NOTIFICATION_TOGGLE_ALBUM_COVER @"notif_toggle_albumCover"



 
#define kSupportedAudioFileExtensions @"\\.(aac|m4a|mp1|mp2|mp3|mpa|wav|caf)$"
#define NOTIFICATION_NETWORK_REQUEST_STARTED @"notif_network_request_started"
#define NOTIFICATION_NETWORK_REQUEST_ENDED @"notif_network_request_ended"

#define NOTIFICATION_DB_REQUEST_PROGRESS_ENDED @"notif_db_download_progress_ended"

#define NOTIFICATION_DB_DOWNLOAD_PROGRESS_ENDED @"notif_db_download_progress_ended"
#define NOTIFICATION_DB_DOWNLOAD_PROGRESS_UPDATED @"notif_db_download_progress_updated"
#define NOTIFICATION_DB_DOWNLOAD_REMAINING_TIME_UPDATED @"notif_db_download_remaining_time_updated"

#define NOTIFICATION_DB_DOWNLOAD_PROGRESS_STARTED @"notif_db_download_progress_started"
#define NOTIFICATION_DB_FILE_LIST_UPDATED @"notif_db_file_list_updated"


#define NOTIFICATION_DB_DOWNLOAD_QUEUE_CHANGED @"notif_db_download_queue_changed"



 
#define NOTIFICATION_TRACK_REMOVE_MEMORY @"notif_track_remove_memory"

#define NOTIFICATION_TRACK_ADDED_MEMORY @"notif_track_added_memory"
#define NOTIFICATION_STREAMER_PLAYBACK_CHANGED @"notif_streamer_playback_changed"


