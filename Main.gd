extends Control

@onready var result_container = $MarginContainer/Panel/VBoxContainer/TabContainer/Discover/VBoxContainer/ScrollContainer/ResultList
@onready var discover_status_label = $MarginContainer/Panel/VBoxContainer/TabContainer/Discover/VBoxContainer/HBoxContainer/DiscoverStatusLabel
@onready var discover_refresh_btn = $MarginContainer/Panel/VBoxContainer/TabContainer/Discover/VBoxContainer/HBoxContainer/DiscoverRefreshBtn
@onready var library_list = $"MarginContainer/Panel/VBoxContainer/TabContainer/My Library/VBoxContainer/ScrollContainer/LibraryList"
@onready var delete_btn = $"MarginContainer/Panel/VBoxContainer/TabContainer/My Library/VBoxContainer/HBoxContainer/DeleteButton"
@onready var spotify_btn = $MarginContainer/Panel/VBoxContainer/TabContainer/Import/VBoxContainer/SpotifyButton
@onready var status_label = $MarginContainer/Panel/VBoxContainer/HeaderMargin/Header/TitleBlock/StatusLabel
@onready var title_label = $MarginContainer/Panel/VBoxContainer/HeaderMargin/Header/TitleBlock/Title
@onready var settings_btn = $MarginContainer/Panel/VBoxContainer/HeaderMargin/Header/SettingsBtn

# Settings modal nodes
@onready var settings_modal = $SettingsModal
@onready var settings_dirs_container = $SettingsModal/CenterContainer/SettingsPanel/MarginContainer/VBoxContainer/DirsContainer
@onready var add_dir_field = $SettingsModal/CenterContainer/SettingsPanel/MarginContainer/VBoxContainer/AddDirRow/AddDirField
@onready var add_dir_btn = $SettingsModal/CenterContainer/SettingsPanel/MarginContainer/VBoxContainer/AddDirRow/AddDirBtn
@onready var target_ch_toggle = $SettingsModal/CenterContainer/SettingsPanel/MarginContainer/VBoxContainer/GameTargetRow/TargetCloneHero
@onready var target_yarg_toggle = $SettingsModal/CenterContainer/SettingsPanel/MarginContainer/VBoxContainer/GameTargetRow/TargetYARG
@onready var settings_close_btn = $SettingsModal/CenterContainer/SettingsPanel/MarginContainer/VBoxContainer/SettingsCloseBtn

var base_ch_path = ""
var song_directories: Array = []   # all configured songs directories
var target_clone_hero: bool = true
var target_yarg: bool = false
var installed_artists = []          # list of artist names (for compatibility)
var installed_artist_counts = {}    # artist_name_lower -> song count
var recommended_artists = []
var final_charts = []
var installed_songs_map = {} # signature -> folder/file name
var current_seed_artists = []
var is_discovering = false
var discover_view = "artists"  # "artists" or "songs"
var discover_current_artist = ""  # artist name when in songs view

var pending_musicmap = 0
var pending_enchor = 0

var custom_font = preload("res://LuckiestGuy-Regular.ttf")

@onready var tab_container = $MarginContainer/Panel/VBoxContainer/TabContainer
@onready var tab_discover = $MarginContainer/Panel/VBoxContainer/TabNavMargin/TabBarPanel/TabButtons/TabDiscover
@onready var tab_top_tracks = $MarginContainer/Panel/VBoxContainer/TabNavMargin/TabBarPanel/TabButtons/TabTopTracks
@onready var tab_library = $MarginContainer/Panel/VBoxContainer/TabNavMargin/TabBarPanel/TabButtons/TabLibrary
@onready var tab_import = $MarginContainer/Panel/VBoxContainer/TabNavMargin/TabBarPanel/TabButtons/TabImport

@onready var top_tracks_container = $"MarginContainer/Panel/VBoxContainer/TabContainer/Top Tracks/VBoxContainer/ScrollContainer/TopTracksList"
@onready var top_tracks_status_label = $"MarginContainer/Panel/VBoxContainer/TabContainer/Top Tracks/VBoxContainer/TopTracksStatusLabel"
@onready var filter_classics_btn = $"MarginContainer/Panel/VBoxContainer/TabContainer/Top Tracks/VBoxContainer/HeaderBar/FilterClassicsBtn"
@onready var filter_latest_btn = $"MarginContainer/Panel/VBoxContainer/TabContainer/Top Tracks/VBoxContainer/HeaderBar/FilterLatestBtn"
@onready var filter_csc_btn = $"MarginContainer/Panel/VBoxContainer/TabContainer/Top Tracks/VBoxContainer/HeaderBar/FilterCscBtn"
@onready var top_tracks_search_field = $"MarginContainer/Panel/VBoxContainer/TabContainer/Top Tracks/VBoxContainer/HeaderBar/TopTracksSearchField"
@onready var top_tracks_search_btn = $"MarginContainer/Panel/VBoxContainer/TabContainer/Top Tracks/VBoxContainer/HeaderBar/TopTracksSearchBtn"
@onready var top_tracks_refresh_btn = $"MarginContainer/Panel/VBoxContainer/TabContainer/Top Tracks/VBoxContainer/HeaderBar/TopTracksRefreshBtn"

var current_top_tracks_category = "classics"
var current_top_tracks_query = ""
var is_fetching_top_tracks = false
var top_tracks_charts = []
var top_tracks_cache = {}

const COMMUNITY_CLASSICS = [
	{"name": "Through the Fire and Flames", "artist": "DragonForce"},
	{"name": "Cliffs of Dover", "artist": "Eric Johnson"},
	{"name": "Free Bird", "artist": "Lynyrd Skynyrd"},
	{"name": "Jordan", "artist": "Buckethead"},
	{"name": "Bohemian Rhapsody", "artist": "Queen"},
	{"name": "Sweet Child O' Mine", "artist": "Guns N' Roses"},
	{"name": "One", "artist": "Metallica"},
	{"name": "Master of Puppets", "artist": "Metallica"},
	{"name": "G.O.A.T.", "artist": "Polyphia"},
	{"name": "Slow Dancing in a Burning Room", "artist": "John Mayer"},
	{"name": "The Trooper", "artist": "Iron Maiden"},
	{"name": "Sultans of Swing", "artist": "Dire Straits"},
	{"name": "Cult of Personality", "artist": "Living Colour"},
	{"name": "Bark at the Moon", "artist": "Ozzy Osbourne"},
	{"name": "Carry On Wayward Son", "artist": "Kansas"},
	{"name": "YYZ", "artist": "Rush"},
	{"name": "Bat Country", "artist": "Avenged Sevenfold"},
	{"name": "Hotel California", "artist": "Eagles"},
	{"name": "Raining Blood", "artist": "Slayer"},
	{"name": "Hangar 18", "artist": "Megadeth"}
]

@onready var logout_btn = $MarginContainer/Panel/VBoxContainer/TabContainer/Import/VBoxContainer/LogoutButton

@onready var picker_modal = $PickerModal
@onready var modal_title = $PickerModal/CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ModalTitle
@onready var modal_subtitle = $PickerModal/CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ModalSubtitle
@onready var modal_option_list = $PickerModal/CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ScrollContainer/ModalOptionList
@onready var modal_cancel_btn = $PickerModal/CenterContainer/ModalPanel/MarginContainer/VBoxContainer/ModalCancelBtn

func _ready():
	# Configure fallback fonts for full international Unicode, CJK, and Emoji support
	var fallback_font = SystemFont.new()
	fallback_font.font_names = PackedStringArray([
		"Segoe UI Emoji",
		"Segoe UI Symbol",
		"Segoe UI",
		"MS Gothic",
		"Meiryo",
		"Yu Gothic",
		"Malgun Gothic",
		"Apple Color Emoji",
		"Hiragino Sans",
		"Noto Sans CJK JP",
		"Noto Sans",
		"Arial Unicode MS",
		"sans-serif"
	])
	custom_font.fallbacks = [fallback_font]
	
	# Set runtime window & taskbar icon
	var icon_tex = load("res://icon.png")
	if icon_tex and icon_tex is Texture2D:
		DisplayServer.set_icon(icon_tex.get_image())
	
	_apply_font_to_ui(self)
	_setup_tab_nav()
	_setup_top_tracks_controls()
	
	delete_btn.pressed.connect(_on_delete_selected)
	var del_style = StyleBoxFlat.new()
	del_style.bg_color = Color(0.22, 0.08, 0.08, 1)
	del_style.corner_radius_top_left = 8
	del_style.corner_radius_top_right = 8
	del_style.corner_radius_bottom_right = 8
	del_style.corner_radius_bottom_left = 8
	del_style.border_color = Color(0.8, 0.25, 0.25, 1)
	del_style.border_width_left = 1
	del_style.border_width_top = 1
	del_style.border_width_right = 1
	del_style.border_width_bottom = 1
	var del_hover = del_style.duplicate()
	del_hover.bg_color = Color(0.35, 0.1, 0.1, 1)
	del_hover.border_color = Color(1.0, 0.4, 0.4, 1)
	delete_btn.add_theme_stylebox_override("normal", del_style)
	delete_btn.add_theme_stylebox_override("hover", del_hover)
	delete_btn.add_theme_stylebox_override("focus", del_hover)
	
	spotify_btn.pressed.connect(_on_spotify_button_pressed)
	logout_btn.pressed.connect(_on_logout_pressed)
	modal_cancel_btn.pressed.connect(func(): picker_modal.visible = false)
	
	discover_refresh_btn.pressed.connect(_discover_new_recommendations)
	var ref_style = StyleBoxFlat.new()
	ref_style.bg_color = Color(0.12, 0.28, 0.44, 1)
	ref_style.corner_radius_top_left = 8
	ref_style.corner_radius_top_right = 8
	ref_style.corner_radius_bottom_right = 8
	ref_style.corner_radius_bottom_left = 8
	ref_style.border_color = Color(0.35, 0.85, 1.0, 1)
	ref_style.border_width_left = 1
	ref_style.border_width_top = 1
	ref_style.border_width_right = 1
	ref_style.border_width_bottom = 1
	var ref_hover = ref_style.duplicate()
	ref_hover.bg_color = Color(0.18, 0.38, 0.58, 1)
	ref_hover.border_color = Color(0.5, 0.95, 1.0, 1)
	discover_refresh_btn.add_theme_stylebox_override("normal", ref_style)
	discover_refresh_btn.add_theme_stylebox_override("hover", ref_hover)
	discover_refresh_btn.add_theme_stylebox_override("focus", ref_hover)
	
	status_label.text = "Searching for Song Directories..."
	_load_settings()
	call_deferred("_find_song_directories")
	_check_saved_session()
	
	# Settings cog button
	settings_btn.pressed.connect(_open_settings_modal)
	settings_close_btn.pressed.connect(_close_settings_modal)
	add_dir_btn.pressed.connect(_on_add_dir_pressed)
	add_dir_field.text_submitted.connect(func(_t): _on_add_dir_pressed())
	target_ch_toggle.toggled.connect(func(_v): _save_settings())
	target_yarg_toggle.toggled.connect(func(_v): _save_settings())
	_style_settings_btn()

func _apply_font_to_ui(node: Node):
	if node is Label or node is Button:
		node.add_theme_font_override("font", custom_font)
	for child in node.get_children():
		_apply_font_to_ui(child)

# ─── SETTINGS ────────────────────────────────────────────────────────────────

func _load_settings():
	var cfg = ConfigFile.new()
	if cfg.load("user://settings.cfg") == OK:
		var dirs = cfg.get_value("directories", "list", [])
		song_directories = dirs if dirs is Array else []
		target_clone_hero = cfg.get_value("targets", "clone_hero", true)
		target_yarg       = cfg.get_value("targets", "yarg", false)
	target_ch_toggle.button_pressed  = target_clone_hero
	target_yarg_toggle.button_pressed = target_yarg

func _save_settings():
	target_clone_hero = target_ch_toggle.button_pressed
	target_yarg       = target_yarg_toggle.button_pressed
	var cfg = ConfigFile.new()
	cfg.set_value("directories", "list", song_directories)
	cfg.set_value("targets", "clone_hero", target_clone_hero)
	cfg.set_value("targets", "yarg", target_yarg)
	cfg.save("user://settings.cfg")
	if target_yarg:
		_sync_with_yarg()

func _style_settings_btn():
	var st = StyleBoxFlat.new()
	st.bg_color = Color(0.1, 0.1, 0.14, 0.9)
	st.corner_radius_top_left = 10
	st.corner_radius_top_right = 10
	st.corner_radius_bottom_right = 10
	st.corner_radius_bottom_left = 10
	st.border_color = Color(0.25, 0.28, 0.38, 1)
	st.border_width_left = 1
	st.border_width_top = 1
	st.border_width_right = 1
	st.border_width_bottom = 1
	var st_h = st.duplicate()
	st_h.bg_color = Color(0.18, 0.22, 0.32, 1)
	st_h.border_color = Color(0.35, 0.85, 1.0, 1)
	settings_btn.add_theme_stylebox_override("normal", st)
	settings_btn.add_theme_stylebox_override("hover", st_h)
	settings_btn.add_theme_stylebox_override("focus", st_h)
	settings_btn.add_theme_color_override("font_color", Color(0.75, 0.78, 0.9, 1))
	settings_btn.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))

func _open_settings_modal():
	# Sync toggles to current state
	target_ch_toggle.button_pressed  = target_clone_hero
	target_yarg_toggle.button_pressed = target_yarg
	_rebuild_dirs_ui()
	settings_modal.visible = true

func _close_settings_modal():
	_save_settings()
	settings_modal.visible = false
	# If the active songs path changed, repopulate library
	_sync_base_ch_path()
	_populate_library()

func _sync_base_ch_path():
	# Keep base_ch_path pointing at the appropriate directory
	if song_directories.is_empty():
		base_ch_path = ""
		return
	if target_yarg and not target_clone_hero:
		for d in song_directories:
			if (d.to_lower().contains("yarg") or d.to_lower().contains("yarc")) and DirAccess.dir_exists_absolute(d):
				base_ch_path = d
				return
	for d in song_directories:
		if DirAccess.dir_exists_absolute(d):
			base_ch_path = d
			return
	base_ch_path = song_directories[0]

func _rebuild_dirs_ui():
	for child in settings_dirs_container.get_children():
		child.queue_free()
	
	if song_directories.is_empty():
		var hint = Label.new()
		hint.text = "No directories configured. Add one below."
		hint.add_theme_font_override("font", custom_font)
		hint.add_theme_color_override("font_color", Color(0.55, 0.58, 0.68, 1))
		settings_dirs_container.add_child(hint)
		return
	
	for i in range(song_directories.size()):
		var dir_path = song_directories[i]
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		
		var exists = DirAccess.dir_exists_absolute(dir_path)
		
		var lbl = Label.new()
		lbl.text = ("✔  " if exists else "✖  ") + dir_path
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.add_theme_font_override("font", custom_font)
		lbl.add_theme_color_override("font_color",
			Color(0.35, 0.9, 0.55, 1) if exists else Color(0.95, 0.35, 0.35, 1))
		row.add_child(lbl)
		
		var rm_btn = Button.new()
		rm_btn.text = "Remove"
		rm_btn.custom_minimum_size = Vector2(80, 32)
		rm_btn.add_theme_font_override("font", custom_font)
		rm_btn.add_theme_font_size_override("font_size", 13)
		var rm_st = StyleBoxFlat.new()
		rm_st.bg_color = Color(0.22, 0.08, 0.08, 1)
		rm_st.corner_radius_top_left = 6
		rm_st.corner_radius_top_right = 6
		rm_st.corner_radius_bottom_right = 6
		rm_st.corner_radius_bottom_left = 6
		rm_st.border_color = Color(0.8, 0.25, 0.25, 1)
		rm_st.border_width_left = 1
		rm_st.border_width_top = 1
		rm_st.border_width_right = 1
		rm_st.border_width_bottom = 1
		var rm_h = rm_st.duplicate()
		rm_h.bg_color = Color(0.38, 0.1, 0.1, 1)
		rm_h.border_color = Color(1.0, 0.4, 0.4, 1)
		rm_btn.add_theme_stylebox_override("normal", rm_st)
		rm_btn.add_theme_stylebox_override("hover", rm_h)
		rm_btn.add_theme_stylebox_override("focus", rm_h)
		rm_btn.add_theme_color_override("font_color", Color(1, 0.55, 0.55, 1))
		var idx_capture = i
		rm_btn.pressed.connect(func():
			song_directories.remove_at(idx_capture)
			_save_settings()
			_rebuild_dirs_ui()
		)
		row.add_child(rm_btn)
		settings_dirs_container.add_child(row)

func _on_add_dir_pressed():
	var new_path = add_dir_field.text.strip_edges()
	if new_path == "":
		return
	# Normalise slashes
	new_path = new_path.replace("\\", "/")
	if song_directories.has(new_path):
		add_dir_field.text = ""
		return
	song_directories.append(new_path)
	if base_ch_path == "" and DirAccess.dir_exists_absolute(new_path):
		base_ch_path = new_path
	_save_settings()
	add_dir_field.text = ""
	_rebuild_dirs_ui()

# ─── END SETTINGS ─────────────────────────────────────────────────────────────

func _setup_tab_nav():
	tab_discover.pressed.connect(func(): _switch_tab(0))
	tab_top_tracks.pressed.connect(func(): _switch_tab(1))
	tab_library.pressed.connect(func(): _switch_tab(2))
	tab_import.pressed.connect(func(): _switch_tab(3))
	# Start application on My Library tab (index 2)
	_switch_tab(2)

func _switch_tab(idx: int):
	tab_container.current_tab = idx
	var tabs = [tab_discover, tab_top_tracks, tab_library, tab_import]
	for i in range(tabs.size()):
		var btn = tabs[i] as Button
		var is_active = (i == idx)
		
		var st = StyleBoxFlat.new()
		st.corner_radius_top_left = 12
		st.corner_radius_top_right = 12
		st.corner_radius_bottom_right = 12
		st.corner_radius_bottom_left = 12
		
		var st_h = st.duplicate()
		
		if is_active:
			st.bg_color = Color(0.12, 0.28, 0.44, 1)
			st.border_color = Color(0.35, 0.85, 1.0, 1)
			st.border_width_left = 2
			st.border_width_top = 2
			st.border_width_right = 2
			st.border_width_bottom = 2
			st.shadow_color = Color(0.18, 0.55, 0.9, 0.35)
			st.shadow_size = 8
			btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			btn.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
			btn.add_theme_color_override("font_focus_color", Color(1, 1, 1, 1))
			st_h = st
		else:
			st.bg_color = Color(0.08, 0.08, 0.12, 0.9)
			st.border_color = Color(0.2, 0.22, 0.28, 0.9)
			st.border_width_left = 1
			st.border_width_top = 1
			st.border_width_right = 1
			st.border_width_bottom = 1
			
			st_h.bg_color = Color(0.15, 0.18, 0.25, 1)
			st_h.border_color = Color(0.4, 0.55, 0.75, 1)
			st_h.border_width_left = 1
			st_h.border_width_top = 1
			st_h.border_width_right = 1
			st_h.border_width_bottom = 1
			
			btn.add_theme_color_override("font_color", Color(0.65, 0.68, 0.78, 1))
			btn.add_theme_color_override("font_hover_color", Color(0.95, 0.95, 1.0, 1))
			btn.add_theme_color_override("font_focus_color", Color(0.95, 0.95, 1.0, 1))
			
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", st_h)
		btn.add_theme_stylebox_override("focus", st_h)
		btn.add_theme_stylebox_override("pressed", st)
		
	if idx == 0:
		if recommended_artists.is_empty() and not is_discovering:
			_discover_new_recommendations()
	elif idx == 1:
		if top_tracks_charts.is_empty() and not is_fetching_top_tracks:
			_load_top_tracks_category(current_top_tracks_category)

# ─── TOP TRACKS ───────────────────────────────────────────────────────────────

func _setup_top_tracks_controls():
	filter_classics_btn.pressed.connect(func(): _select_top_tracks_category("classics"))
	filter_latest_btn.pressed.connect(func(): _select_top_tracks_category("latest"))
	filter_csc_btn.pressed.connect(func(): _select_top_tracks_category("csc"))
	top_tracks_search_btn.pressed.connect(_search_top_tracks)
	top_tracks_search_field.text_submitted.connect(func(_t): _search_top_tracks())
	top_tracks_refresh_btn.pressed.connect(_refresh_top_tracks)
	
	# Style search input field
	var sf_st = StyleBoxFlat.new()
	sf_st.bg_color = Color(0.1, 0.1, 0.14, 1)
	sf_st.corner_radius_top_left = 8
	sf_st.corner_radius_top_right = 8
	sf_st.corner_radius_bottom_right = 8
	sf_st.corner_radius_bottom_left = 8
	sf_st.border_color = Color(0.25, 0.28, 0.38, 1)
	sf_st.border_width_left = 1
	sf_st.border_width_top = 1
	sf_st.border_width_right = 1
	sf_st.border_width_bottom = 1
	sf_st.content_margin_left = 12
	sf_st.content_margin_right = 12
	top_tracks_search_field.add_theme_stylebox_override("normal", sf_st)
	top_tracks_search_field.add_theme_stylebox_override("focus", sf_st)
	
	# Style search & refresh buttons
	var s_btn_st = StyleBoxFlat.new()
	s_btn_st.bg_color = Color(0.14, 0.18, 0.26, 1)
	s_btn_st.corner_radius_top_left = 8
	s_btn_st.corner_radius_top_right = 8
	s_btn_st.corner_radius_bottom_right = 8
	s_btn_st.corner_radius_bottom_left = 8
	s_btn_st.border_color = Color(0.3, 0.55, 0.85, 1)
	s_btn_st.border_width_left = 1
	s_btn_st.border_width_top = 1
	s_btn_st.border_width_right = 1
	s_btn_st.border_width_bottom = 1
	var s_btn_hover = s_btn_st.duplicate()
	s_btn_hover.bg_color = Color(0.2, 0.28, 0.4, 1)
	s_btn_hover.border_color = Color(0.45, 0.75, 1, 1)
	
	top_tracks_search_btn.add_theme_stylebox_override("normal", s_btn_st)
	top_tracks_search_btn.add_theme_stylebox_override("hover", s_btn_hover)
	top_tracks_search_btn.add_theme_stylebox_override("focus", s_btn_hover)
	
	top_tracks_refresh_btn.add_theme_stylebox_override("normal", s_btn_st)
	top_tracks_refresh_btn.add_theme_stylebox_override("hover", s_btn_hover)
	top_tracks_refresh_btn.add_theme_stylebox_override("focus", s_btn_hover)
	
	_update_category_buttons_style()

func _update_category_buttons_style():
	var cats = [
		{"btn": filter_classics_btn, "id": "classics", "color": Color(0.95, 0.45, 0.15, 1), "bg": Color(0.32, 0.14, 0.06, 1)},
		{"btn": filter_latest_btn, "id": "latest", "color": Color(0.4, 0.75, 1.0, 1), "bg": Color(0.12, 0.25, 0.42, 1)},
		{"btn": filter_csc_btn, "id": "csc", "color": Color(0.95, 0.8, 0.25, 1), "bg": Color(0.32, 0.26, 0.08, 1)}
	]
	for item in cats:
		var btn = item["btn"] as Button
		var is_sel = (current_top_tracks_category == item["id"])
		var st = StyleBoxFlat.new()
		st.corner_radius_top_left = 8
		st.corner_radius_top_right = 8
		st.corner_radius_bottom_right = 8
		st.corner_radius_bottom_left = 8
		if is_sel:
			st.bg_color = item["bg"]
			st.border_color = item["color"]
			st.border_width_left = 2
			st.border_width_top = 2
			st.border_width_right = 2
			st.border_width_bottom = 2
			btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		else:
			st.bg_color = Color(0.11, 0.12, 0.16, 0.9)
			st.border_color = Color(0.22, 0.25, 0.32, 0.9)
			st.border_width_left = 1
			st.border_width_top = 1
			st.border_width_right = 1
			st.border_width_bottom = 1
			btn.add_theme_color_override("font_color", Color(0.65, 0.7, 0.8, 1))
		var st_h = st.duplicate()
		st_h.bg_color = st.bg_color.lightened(0.08)
		btn.add_theme_stylebox_override("normal", st)
		btn.add_theme_stylebox_override("hover", st_h)
		btn.add_theme_stylebox_override("focus", st_h)
		btn.add_theme_stylebox_override("pressed", st)

func _select_top_tracks_category(cat: String):
	current_top_tracks_category = cat
	_update_category_buttons_style()
	_load_top_tracks_category(cat)

func _search_top_tracks():
	var q = top_tracks_search_field.text.strip_edges()
	if q == "":
		return
	current_top_tracks_category = "search"
	current_top_tracks_query = q
	_update_category_buttons_style()
	_fetch_top_tracks_query(q)

func _refresh_top_tracks():
	if current_top_tracks_category == "search":
		if current_top_tracks_query != "":
			top_tracks_cache.erase("search:" + current_top_tracks_query)
			_fetch_top_tracks_query(current_top_tracks_query)
	else:
		top_tracks_cache.erase(current_top_tracks_category)
		_load_top_tracks_category(current_top_tracks_category)

func _set_top_tracks_loading(loading: bool):
	top_tracks_refresh_btn.disabled = loading
	top_tracks_refresh_btn.text = "⏳ Loading..." if loading else "🔄  Refresh"
	if loading:
		for child in top_tracks_container.get_children():
			child.queue_free()
		var load_lbl = Label.new()
		load_lbl.text = "⏳ Loading tracks from Enchor..."
		load_lbl.add_theme_font_override("font", custom_font)
		load_lbl.add_theme_font_size_override("font_size", 18)
		load_lbl.add_theme_color_override("font_color", Color(0.4, 0.75, 1, 1))
		top_tracks_container.add_child(load_lbl)

func _load_top_tracks_category(cat: String):
	if top_tracks_cache.has(cat):
		top_tracks_charts = top_tracks_cache[cat]
		_render_top_tracks_ui()
		return
		
	if is_fetching_top_tracks:
		return
		
	is_fetching_top_tracks = true
	_set_top_tracks_loading(true)
	
	if cat == "classics":
		top_tracks_status_label.text = "Loading Community Classics (querying iconic rhythm game anthems on Enchor)..."
		_fetch_community_classics()
	elif cat == "latest":
		top_tracks_status_label.text = "Fetching Latest Releases from Enchor..."
		_fetch_latest_releases()
	elif cat == "csc":
		top_tracks_status_label.text = "Fetching Custom Songs Central & Official verified charts..."
		_fetch_csc_charts()

func _fetch_community_classics():
	var collected = []
	var total = COMMUNITY_CLASSICS.size()
	var queue = COMMUNITY_CLASSICS.duplicate()
	var active_workers = [3]
	
	var worker = func():
		while not queue.is_empty():
			var anthem = queue.pop_front()
			var s_name = anthem["name"]
			var a_name = anthem["artist"]
			
			var http = HTTPRequest.new()
			add_child(http)
			var query = s_name + " " + a_name
			var url = "https://api.enchor.us/search"
			var payload = JSON.stringify({"search": query, "page": 1, "per_page": 5})
			var req_headers = ["Content-Type: application/json", "User-Agent: CloneHeroCompanion/1.0"]
			var err = http.request(url, req_headers, HTTPClient.METHOD_POST, payload)
			if err != OK:
				http.queue_free()
				await get_tree().create_timer(0.3).timeout
				queue.push_back(anthem)
				continue
				
			var res = await http.request_completed
			http.queue_free()
			
			var response_code = res[1]
			var body = res[3]
			if response_code == 200 or response_code == 201:
				var json = JSON.parse_string(body.get_string_from_utf8())
				if json and json is Dictionary and json.has("data") and not (json["data"] as Array).is_empty():
					var matches = json["data"] as Array
					var best_chart = null
					for cand in matches:
						if _can_chart_be_downloaded(cand):
							var cand_artist = (cand.get("artist", "") as String).to_lower()
							if cand_artist.contains(a_name.to_lower()) or a_name.to_lower().contains(cand_artist):
								best_chart = cand
								break
					if best_chart == null:
						for cand in matches:
							if _can_chart_be_downloaded(cand):
								best_chart = cand
								break
					if best_chart == null:
						best_chart = matches[0]
					collected.append(best_chart)
			elif response_code == 429 or response_code == 503:
				await get_tree().create_timer(0.5).timeout
				queue.push_back(anthem)
				
			if top_tracks_status_label:
				top_tracks_status_label.text = "Loading Community Classics (%d/%d loaded)..." % [collected.size(), total]
			await get_tree().create_timer(0.06).timeout
			
		active_workers[0] -= 1
		if active_workers[0] <= 0:
			is_fetching_top_tracks = false
			_set_top_tracks_loading(false)
			top_tracks_charts = collected
			top_tracks_cache["classics"] = collected
			_render_top_tracks_ui()
			
	for w in range(3):
		worker.call()

func _fetch_latest_releases():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_result, response_code, _headers, body):
		http.queue_free()
		is_fetching_top_tracks = false
		_set_top_tracks_loading(false)
		if response_code == 200 or response_code == 201:
			var json = JSON.parse_string(body.get_string_from_utf8())
			if json and json is Dictionary and json.has("data"):
				top_tracks_charts = json["data"]
				top_tracks_cache["latest"] = top_tracks_charts
				_render_top_tracks_ui()
				return
		top_tracks_status_label.text = "Failed to load latest charts from Enchor. Click Refresh to try again."
	)
	var url = "https://api.enchor.us/search"
	var payload = JSON.stringify({
		"search": "*",
		"page": 1,
		"per_page": 30,
		"sort": {
			"type": "modifiedTime",
			"direction": "desc"
		}
	})
	var req_headers = ["Content-Type: application/json", "User-Agent: CloneHeroCompanion/1.0"]
	var err = http.request(url, req_headers, HTTPClient.METHOD_POST, payload)
	if err != OK:
		http.queue_free()
		is_fetching_top_tracks = false
		_set_top_tracks_loading(false)
		top_tracks_status_label.text = "Error connecting to Enchor."

func _fetch_csc_charts():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_result, response_code, _headers, body):
		http.queue_free()
		is_fetching_top_tracks = false
		_set_top_tracks_loading(false)
		if response_code == 200 or response_code == 201:
			var json = JSON.parse_string(body.get_string_from_utf8())
			if json and json is Dictionary and json.has("data"):
				top_tracks_charts = json["data"]
				top_tracks_cache["csc"] = top_tracks_charts
				_render_top_tracks_ui()
				return
		top_tracks_status_label.text = "Failed to load CSC charts from Enchor. Click Refresh to try again."
	)
	var url = "https://api.enchor.us/search"
	var payload = JSON.stringify({
		"search": "Custom Songs Central",
		"page": 1,
		"per_page": 30,
		"sort": {
			"type": "modifiedTime",
			"direction": "desc"
		}
	})
	var req_headers = ["Content-Type: application/json", "User-Agent: CloneHeroCompanion/1.0"]
	var err = http.request(url, req_headers, HTTPClient.METHOD_POST, payload)
	if err != OK:
		http.queue_free()
		is_fetching_top_tracks = false
		_set_top_tracks_loading(false)
		top_tracks_status_label.text = "Error connecting to Enchor."

func _fetch_top_tracks_query(query: String):
	var cache_key = "search:" + query
	if top_tracks_cache.has(cache_key):
		top_tracks_charts = top_tracks_cache[cache_key]
		_render_top_tracks_ui()
		return
		
	if is_fetching_top_tracks:
		return
	is_fetching_top_tracks = true
	_set_top_tracks_loading(true)
	top_tracks_status_label.text = "Searching Enchor for '%s'..." % query
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_result, response_code, _headers, body):
		http.queue_free()
		is_fetching_top_tracks = false
		_set_top_tracks_loading(false)
		if response_code == 200 or response_code == 201:
			var json = JSON.parse_string(body.get_string_from_utf8())
			if json and json is Dictionary and json.has("data"):
				top_tracks_charts = json["data"]
				top_tracks_cache[cache_key] = top_tracks_charts
				_render_top_tracks_ui()
				return
		top_tracks_status_label.text = "No charts found for '%s'." % query
	)
	var url = "https://api.enchor.us/search"
	var payload = JSON.stringify({
		"search": query,
		"page": 1,
		"per_page": 30
	})
	var req_headers = ["Content-Type: application/json", "User-Agent: CloneHeroCompanion/1.0"]
	var err = http.request(url, req_headers, HTTPClient.METHOD_POST, payload)
	if err != OK:
		http.queue_free()
		is_fetching_top_tracks = false
		_set_top_tracks_loading(false)
		top_tracks_status_label.text = "Error connecting to Enchor."

func _render_top_tracks_ui():
	for child in top_tracks_container.get_children():
		child.queue_free()
		
	if top_tracks_charts.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "No charts found. Try another category or search term!"
		empty_lbl.add_theme_font_override("font", custom_font)
		empty_lbl.add_theme_font_size_override("font_size", 16)
		empty_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 1))
		top_tracks_container.add_child(empty_lbl)
		return
		
	var cat_label = ""
	if current_top_tracks_category == "classics":
		cat_label = "🔥 Showing %d Community Classics — all-time rhythm game anthems" % top_tracks_charts.size()
	elif current_top_tracks_category == "latest":
		cat_label = "✨ Showing %d Latest Releases — freshly charted on Enchor" % top_tracks_charts.size()
	elif current_top_tracks_category == "csc":
		cat_label = "🏆 Showing %d CSC & Official Charts — premier quality standard" % top_tracks_charts.size()
	else:
		cat_label = "🔍 Showing %d results for '%s'" % [top_tracks_charts.size(), current_top_tracks_query]
	top_tracks_status_label.text = cat_label
	
	for i in range(top_tracks_charts.size()):
		var chart = top_tracks_charts[i]
		var rank = i + 1
		var artist_name = str(chart.get("artist", "Unknown")).strip_edges()
		var song_name = str(chart.get("name", "Unknown")).strip_edges()
		var charter = str(chart.get("charter", "Unknown")).strip_edges()
		var diff_str = _format_difficulty_rating(chart)
		var can_dl = _can_chart_be_downloaded(chart)
		var installed_folder = _find_installed_song([artist_name], song_name)
		var is_installed = (installed_folder != "")
		
		# Root Card Container
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 60)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color(0.11, 0.12, 0.16, 1)
		card_style.corner_radius_top_left = 8
		card_style.corner_radius_top_right = 8
		card_style.corner_radius_bottom_right = 8
		card_style.corner_radius_bottom_left = 8
		card_style.content_margin_left = 12
		card_style.content_margin_right = 12
		card_style.content_margin_top = 6
		card_style.content_margin_bottom = 6
		if is_installed:
			card_style.border_color = Color(0.2, 0.65, 0.85, 0.45)
			card_style.border_width_left = 1
			card_style.border_width_top = 1
			card_style.border_width_right = 1
			card_style.border_width_bottom = 1
		else:
			card_style.border_color = Color(0.2, 0.24, 0.32, 0.6)
			card_style.border_width_left = 1
			card_style.border_width_top = 1
			card_style.border_width_right = 1
			card_style.border_width_bottom = 1
		card.add_theme_stylebox_override("panel", card_style)
		
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 14)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		card.add_child(row)
		
		# Column 1: Rank Badge
		var rank_lbl = Button.new()
		rank_lbl.custom_minimum_size = Vector2(46, 48)
		rank_lbl.text = "#%d" % rank
		rank_lbl.add_theme_font_override("font", custom_font)
		rank_lbl.add_theme_font_size_override("font_size", 14)
		var r_st = StyleBoxFlat.new()
		r_st.corner_radius_top_left = 8
		r_st.corner_radius_top_right = 8
		r_st.corner_radius_bottom_right = 8
		r_st.corner_radius_bottom_left = 8
		r_st.bg_color = Color(0.12, 0.14, 0.19, 1)
		r_st.border_color = Color(0.25, 0.3, 0.42, 1)
		r_st.border_width_left = 1
		r_st.border_width_top = 1
		r_st.border_width_right = 1
		r_st.border_width_bottom = 1
		rank_lbl.add_theme_stylebox_override("normal", r_st)
		rank_lbl.add_theme_stylebox_override("hover", r_st)
		rank_lbl.add_theme_stylebox_override("focus", r_st)
		rank_lbl.add_theme_color_override("font_color", Color(0.7, 0.8, 1, 1))
		row.add_child(rank_lbl)
		
		# Column 2: Title & Artist Column
		var track_col = VBoxContainer.new()
		track_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		track_col.size_flags_stretch_ratio = 2.8
		track_col.alignment = BoxContainer.ALIGNMENT_CENTER
		track_col.add_theme_constant_override("separation", 2)
		track_col.mouse_filter = Control.MOUSE_FILTER_STOP
		track_col.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var title_row = HBoxContainer.new()
		title_row.add_theme_constant_override("separation", 6)
		
		var title_lbl = Label.new()
		title_lbl.text = song_name
		title_lbl.add_theme_font_override("font", custom_font)
		title_lbl.add_theme_font_size_override("font_size", 15)
		title_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title_row.add_child(title_lbl)
		
		if is_installed:
			var tag = Label.new()
			tag.name = "InLibTag"
			tag.text = "[💾 In Library]"
			tag.add_theme_font_override("font", custom_font)
			tag.add_theme_font_size_override("font_size", 11)
			tag.add_theme_color_override("font_color", Color(0.2, 0.9, 0.65, 1))
			title_row.add_child(tag)
			
		track_col.add_child(title_row)
		
		var artist_lbl = Label.new()
		artist_lbl.text = artist_name
		artist_lbl.add_theme_font_override("font", custom_font)
		artist_lbl.add_theme_font_size_override("font_size", 13)
		artist_lbl.add_theme_color_override("font_color", Color(0.7, 0.76, 0.88, 1))
		artist_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		track_col.add_child(artist_lbl)
		
		row.add_child(track_col)
		
		# Column 3: Charter & Origin Badge Column
		var charter_col = VBoxContainer.new()
		charter_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		charter_col.size_flags_stretch_ratio = 1.6
		charter_col.alignment = BoxContainer.ALIGNMENT_CENTER
		charter_col.add_theme_constant_override("separation", 2)
		
		var p_val = chart.get("packName")
		var pack_name = (p_val if p_val is String else "").strip_edges()
		var charter_lower = charter.to_lower()
		var pack_lower = pack_name.to_lower()
		var is_csc = pack_lower.contains("custom songs central") or charter_lower.contains("custom songs central") or str(chart.get("icon", "")).to_lower() == "csc"
		var official_names = ["harmonix", "neversoft", "redoctane", "activision", "vicarious visions"]
		var is_official = official_names.any(func(x): return charter_lower.contains(x))
		
		var charter_lbl = Label.new()
		charter_lbl.add_theme_font_override("font", custom_font)
		charter_lbl.add_theme_font_size_override("font_size", 13)
		charter_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		
		if is_csc:
			charter_lbl.text = "🏆 Custom Songs Central"
			charter_lbl.add_theme_color_override("font_color", Color(0.88, 0.7, 1.0, 1))
		elif is_official:
			charter_lbl.text = "⭐ %s" % charter
			charter_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1))
		else:
			charter_lbl.text = "👤 %s" % (charter if charter != "" else "Unknown Charter")
			charter_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95, 1))
		charter_col.add_child(charter_lbl)
		
		var pack_sub_lbl = Label.new()
		pack_sub_lbl.add_theme_font_override("font", custom_font)
		pack_sub_lbl.add_theme_font_size_override("font_size", 11)
		pack_sub_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		
		if is_csc and charter_lower != "custom songs central" and charter != "" and charter != "Unknown":
			pack_sub_lbl.text = "by %s" % charter
			pack_sub_lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 0.85, 0.9))
			charter_col.add_child(pack_sub_lbl)
		elif pack_name != "" and pack_name != "None" and not is_csc:
			pack_sub_lbl.text = "📦 %s" % pack_name
			pack_sub_lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.82, 0.85))
			charter_col.add_child(pack_sub_lbl)
		elif is_official:
			pack_sub_lbl.text = "Official Release"
			pack_sub_lbl.add_theme_color_override("font_color", Color(0.35, 0.7, 0.9, 0.8))
			charter_col.add_child(pack_sub_lbl)
			
		row.add_child(charter_col)
		
		# Column 4: Difficulty & Details Column
		var diff_col = VBoxContainer.new()
		diff_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		diff_col.size_flags_stretch_ratio = 1.4
		diff_col.alignment = BoxContainer.ALIGNMENT_CENTER
		diff_col.add_theme_constant_override("separation", 2)
		
		var diff_lbl = Label.new()
		diff_lbl.text = diff_str
		diff_lbl.add_theme_font_override("font", custom_font)
		diff_lbl.add_theme_font_size_override("font_size", 13)
		diff_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		
		if diff_str.contains("DEVIL"):
			diff_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45, 1))
		elif diff_str.begins_with("★"):
			diff_lbl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.38, 1))
		elif diff_str.contains("No Lead"):
			diff_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.8))
		else:
			diff_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95, 1))
		diff_col.add_child(diff_lbl)
		
		var total_sec = int(chart.get("song_length", 0) / 1000.0)
		var length_str = "%d:%02d" % [int(total_sec / 60.0), total_sec % 60] if total_sec > 0 else ""
		
		var nd_val = chart.get("notesData")
		var nd: Dictionary = nd_val if nd_val is Dictionary else {}
		var insts_val = nd.get("instruments")
		var insts: Array = insts_val if insts_val is Array else []
		var inst_icons = []
		if insts.has("guitar"): inst_icons.append("🎸 Lead")
		if insts.has("bass"): inst_icons.append("🎸 Bass")
		if insts.has("drums"): inst_icons.append("🥁 Drums")
		if insts.has("vocals"): inst_icons.append("🎤 Vocals")
		if insts.has("keys"): inst_icons.append("🎹 Keys")
		
		var details_parts = []
		if not inst_icons.is_empty():
			details_parts.append(inst_icons[0] if inst_icons.size() == 1 else "%s (+%d)" % [inst_icons[0], inst_icons.size() - 1])
		if length_str != "":
			details_parts.append(length_str)
			
		var details_sub = " • ".join(details_parts) if not details_parts.is_empty() else "Standard Chart"
		
		var details_lbl = Label.new()
		details_lbl.text = details_sub
		details_lbl.add_theme_font_override("font", custom_font)
		details_lbl.add_theme_font_size_override("font_size", 11)
		details_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 0.7, 0.9))
		details_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		diff_col.add_child(details_lbl)
		
		row.add_child(diff_col)
		
		# Column 5: Action Buttons
		var actions_col = HBoxContainer.new()
		actions_col.alignment = BoxContainer.ALIGNMENT_END
		actions_col.add_theme_constant_override("separation", 8)
		
		var dl_btn = Button.new()
		dl_btn.custom_minimum_size = Vector2(145, 46)
		dl_btn.add_theme_font_override("font", custom_font)
		dl_btn.add_theme_font_size_override("font_size", 13)
		
		var dl_style = StyleBoxFlat.new()
		dl_style.corner_radius_top_left = 8
		dl_style.corner_radius_top_right = 8
		dl_style.corner_radius_bottom_right = 8
		dl_style.corner_radius_bottom_left = 8
		
		if is_installed:
			dl_btn.text = "💾 In Library"
			dl_style.bg_color = Color(0.08, 0.22, 0.32, 1)
			dl_style.border_color = Color(0.2, 0.7, 0.95, 1)
			dl_style.border_width_left = 1
			dl_style.border_width_top = 1
			dl_style.border_width_right = 1
			dl_style.border_width_bottom = 1
			dl_btn.disabled = true
		elif can_dl:
			dl_btn.text = "⬇ Add to Library"
			dl_style.bg_color = Color(0.08, 0.28, 0.15, 1)
			dl_style.border_color = Color(0.11, 0.85, 0.35, 1)
			dl_style.border_width_left = 1
			dl_style.border_width_top = 1
			dl_style.border_width_right = 1
			dl_style.border_width_bottom = 1
		else:
			dl_btn.text = "⬇ Add to Library"
			dl_style.bg_color = Color(0.12, 0.2, 0.3, 1)
			dl_style.border_color = Color(0.3, 0.65, 0.95, 1)
			dl_style.border_width_left = 1
			dl_style.border_width_top = 1
			dl_style.border_width_right = 1
			dl_style.border_width_bottom = 1
			
		var dl_hover = dl_style.duplicate()
		dl_hover.bg_color = Color(0.15, 0.38, 0.22, 1) if can_dl else Color(0.18, 0.28, 0.42, 1)
		dl_btn.add_theme_stylebox_override("normal", dl_style)
		dl_btn.add_theme_stylebox_override("hover", dl_hover)
		dl_btn.add_theme_stylebox_override("focus", dl_hover)
		actions_col.add_child(dl_btn)
		
		var web_btn = Button.new()
		web_btn.text = "🔗 Enchor"
		web_btn.custom_minimum_size = Vector2(85, 46)
		web_btn.add_theme_font_override("font", custom_font)
		web_btn.add_theme_font_size_override("font_size", 12)
		var wb_style = StyleBoxFlat.new()
		wb_style.bg_color = Color(0.12, 0.13, 0.17, 1)
		wb_style.corner_radius_top_left = 8
		wb_style.corner_radius_top_right = 8
		wb_style.corner_radius_bottom_right = 8
		wb_style.corner_radius_bottom_left = 8
		wb_style.border_color = Color(0.25, 0.28, 0.36, 1)
		wb_style.border_width_left = 1
		wb_style.border_width_top = 1
		wb_style.border_width_right = 1
		wb_style.border_width_bottom = 1
		var wb_hover = wb_style.duplicate()
		wb_hover.bg_color = Color(0.18, 0.22, 0.32, 1)
		wb_hover.border_color = Color(0.4, 0.7, 1, 1)
		web_btn.add_theme_stylebox_override("normal", wb_style)
		web_btn.add_theme_stylebox_override("hover", wb_hover)
		web_btn.add_theme_stylebox_override("focus", wb_hover)
		actions_col.add_child(web_btn)
		
		row.add_child(actions_col)
		
		# Setup button actions
		var open_enchor = func():
			var q = song_name + " " + artist_name
			OS.shell_open("https://www.enchor.us/?search=" + q.uri_encode())
			
		web_btn.pressed.connect(open_enchor)
		
		var captured_chart = chart
		var on_dl_clicked = func():
			if is_installed:
				status_label.text = "Song is already in library: %s - %s" % [artist_name, song_name]
				return
			if can_dl:
				dl_btn.disabled = true
				dl_btn.text = "⏳ Downloading..."
				status_label.text = "Downloading %s - %s..." % [artist_name, song_name]
				var success = await _download_single_chart(captured_chart)
				if success:
					dl_btn.text = "💾 In Library"
					dl_btn.disabled = true
					var succ_st = dl_style.duplicate()
					succ_st.bg_color = Color(0.08, 0.22, 0.32, 1)
					succ_st.border_color = Color(0.2, 0.7, 0.95, 1)
					dl_btn.add_theme_stylebox_override("normal", succ_st)
					dl_btn.add_theme_stylebox_override("hover", succ_st)
					dl_btn.add_theme_stylebox_override("focus", succ_st)
					
					var inst_st = card_style.duplicate()
					inst_st.border_color = Color(0.2, 0.65, 0.85, 0.6)
					card.add_theme_stylebox_override("panel", inst_st)
					
					if not title_row.has_node("InLibTag"):
						var new_tag = Label.new()
						new_tag.name = "InLibTag"
						new_tag.text = "[💾 In Library]"
						new_tag.add_theme_font_override("font", custom_font)
						new_tag.add_theme_font_size_override("font_size", 11)
						new_tag.add_theme_color_override("font_color", Color(0.2, 0.9, 0.65, 1))
						title_row.add_child(new_tag)
						
					status_label.text = "Successfully installed %s - %s into library!" % [artist_name, song_name]
				else:
					dl_btn.disabled = false
					dl_btn.text = "Retry Download"
					status_label.text = "Download failed for %s. Click Retry or use '🔗 Enchor' to view online." % song_name
			else:
				# Search Enchor for downloadable versions of this song
				status_label.text = "Checking Enchor for downloadable versions of '%s'..." % song_name
				dl_btn.disabled = true
				dl_btn.text = "⏳ Checking..."
				var http_search = HTTPRequest.new()
				add_child(http_search)
				var payload = JSON.stringify({"search": song_name + " " + artist_name, "page": 1})
				var s_headers = ["Content-Type: application/json", "User-Agent: CloneHeroCompanion/1.0"]
				http_search.request("https://api.enchor.us/search", s_headers, HTTPClient.METHOD_POST, payload)
				var res = await http_search.request_completed
				http_search.queue_free()
				dl_btn.disabled = false
				dl_btn.text = "⬇ Add to Library"
				var j = JSON.parse_string(res[3].get_string_from_utf8()) if (res[1] == 200 or res[1] == 201) else null
				var dls = []
				if j is Dictionary and j.has("data") and j["data"] is Array:
					for c in j["data"]:
						if _can_chart_be_downloaded(c):
							dls.append(c)
				if not dls.is_empty():
					_open_preferred_chart_modal(song_name, artist_name, dls, func(picked):
						status_label.text = "Downloading chosen version of %s..." % song_name
						dl_btn.disabled = true
						dl_btn.text = "⏳ Downloading..."
						var s = await _download_single_chart(picked)
						if s:
							dl_btn.text = "💾 In Library"
							dl_btn.disabled = true
							var succ_st = dl_style.duplicate()
							succ_st.bg_color = Color(0.08, 0.22, 0.32, 1)
							succ_st.border_color = Color(0.2, 0.7, 0.95, 1)
							dl_btn.add_theme_stylebox_override("normal", succ_st)
							dl_btn.add_theme_stylebox_override("hover", succ_st)
							dl_btn.add_theme_stylebox_override("focus", succ_st)
							
							var inst_st = card_style.duplicate()
							inst_st.border_color = Color(0.2, 0.65, 0.85, 0.6)
							card.add_theme_stylebox_override("panel", inst_st)
							
							if not title_row.has_node("InLibTag"):
								var new_tag = Label.new()
								new_tag.name = "InLibTag"
								new_tag.text = "[💾 In Library]"
								new_tag.add_theme_font_override("font", custom_font)
								new_tag.add_theme_font_size_override("font_size", 11)
								new_tag.add_theme_color_override("font_color", Color(0.2, 0.9, 0.65, 1))
								title_row.add_child(new_tag)
								
							status_label.text = "Successfully installed %s into library!" % song_name
						else:
							dl_btn.disabled = false
							dl_btn.text = "Retry Download"
					)
				else:
					open_enchor.call()
		
		track_col.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				on_dl_clicked.call()
		)
		dl_btn.pressed.connect(on_dl_clicked)
		
		top_tracks_container.add_child(card)

func _get_home_dir() -> String:
	var home = OS.get_environment("USERPROFILE")
	if home == "":
		home = OS.get_environment("HOME")
	if home == "":
		home = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).get_base_dir()
	return home.replace("\\", "/")

func _get_yarg_settings_path() -> String:
	var home = _get_home_dir()
	var candidates = [
		home + "/.config/unity3d/YARC/YARG/release/settings.json",
		home + "/.config/unity3d/YARC/YARG/settings.json",
		home + "/AppData/LocalLow/YARC/YARG/release/settings.json",
		home + "/AppData/LocalLow/YARC/YARG/settings.json",
		home + "/Library/Application Support/unity.YARC.YARG/release/settings.json",
		home + "/.var/app/net.yarg.YARG/config/unity3d/YARC/YARG/release/settings.json"
	]
	for p in candidates:
		if FileAccess.file_exists(p):
			return p
	if OS.has_feature("windows"):
		return home + "/AppData/LocalLow/YARC/YARG/release/settings.json"
	elif OS.has_feature("macos"):
		return home + "/Library/Application Support/unity.YARC.YARG/release/settings.json"
	else:
		return home + "/.config/unity3d/YARC/YARG/release/settings.json"

func _get_yarc_setlists_path() -> String:
	var local_app_data = OS.get_environment("LOCALAPPDATA")
	var home = _get_home_dir()
	var candidates = []
	if local_app_data != "":
		candidates.append(local_app_data.replace("\\", "/") + "/YARC/Setlists")
	candidates.append(home + "/.local/share/YARC/Setlists")
	candidates.append(home + "/.config/YARC/Setlists")
	for p in candidates:
		if DirAccess.dir_exists_absolute(p):
			return p
	return ""

func _find_song_directories():
	var docs = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	var home = _get_home_dir()

	var test_paths = [
		docs + "/Clone Hero/Songs",
		docs + "/YARG/Songs",
		home + "/.clonehero/Songs",
		home + "/Clone Hero/Songs",
		home + "/YARG/Songs",
		home + "/Games/YARG/Songs",
		home + "/.config/unity3d/YARC/YARG/Songs",
		home + "/.local/share/YARG/Songs",
		home + "/.config/unity3d/srylain Inc_/Clone Hero/Songs",
		docs + "/Clone Hero PTB/Songs"
	]

	# Auto-detect YARG / YARC installations & setlists
	var yarc_setlists = _get_yarc_setlists_path()
	if yarc_setlists != "" and DirAccess.dir_exists_absolute(yarc_setlists):
		var s_dir = DirAccess.open(yarc_setlists)
		if s_dir:
			s_dir.list_dir_begin()
			var entry = s_dir.get_next()
			while entry != "":
				if not entry.begins_with("."):
					var inst_dir = yarc_setlists + "/" + entry + "/installation"
					if DirAccess.dir_exists_absolute(inst_dir):
						test_paths.append(inst_dir)
				entry = s_dir.get_next()

	# Read any existing SongFolders configured in YARG
	var yarg_cfg_path = _get_yarg_settings_path()
	if FileAccess.file_exists(yarg_cfg_path):
		var y_fa = FileAccess.open(yarg_cfg_path, FileAccess.READ)
		if y_fa:
			var y_json = JSON.parse_string(y_fa.get_as_text())
			if y_json is Dictionary and y_json.has("SongFolders") and y_json["SongFolders"] is Array:
				for y_path in y_json["SongFolders"]:
					if y_path is String and y_path != "":
						test_paths.append(y_path.replace("\\", "/"))
			y_fa.close()

	var _found_any = false
	for path in test_paths:
		var normalised = path.replace("\\", "/")
		if DirAccess.dir_exists_absolute(normalised) and not song_directories.has(normalised):
			song_directories.append(normalised)
			_found_any = true

	if not song_directories.is_empty():
		_sync_base_ch_path()
		_save_settings()
		if target_yarg:
			_sync_with_yarg()
		status_label.text = "Loaded %d song directories (%s)" % [song_directories.size(), base_ch_path.get_file()]
		_populate_library()
		call_deferred("_discover_new_recommendations")
	else:
		status_label.text = "Could not automatically find Songs folder. Use Settings (cog) to set a directory."

func _sync_with_yarg():
	var yarg_cfg_path = _get_yarg_settings_path()
	if not FileAccess.file_exists(yarg_cfg_path):
		return
	var y_fa = FileAccess.open(yarg_cfg_path, FileAccess.READ)
	if not y_fa:
		return
	var y_json = JSON.parse_string(y_fa.get_as_text())
	y_fa.close()
	if not (y_json is Dictionary):
		return
	var sf_list: Array = y_json.get("SongFolders", [])
	var is_win = OS.has_feature("windows")
	var changed = false
	for d in song_directories:
		if DirAccess.dir_exists_absolute(d):
			var formatted_path = d.replace("/", "\\") if is_win else d.replace("\\", "/")
			var norm_d = d.replace("\\", "/").trim_suffix("/").to_lower()
			var already_has = false
			for existing in sf_list:
				if str(existing).replace("\\", "/").trim_suffix("/").to_lower() == norm_d:
					already_has = true
					break
			if not already_has:
				sf_list.append(formatted_path)
				changed = true
	if changed:
		y_json["SongFolders"] = sf_list
		var out_fa = FileAccess.open(yarg_cfg_path, FileAccess.WRITE)
		if out_fa:
			out_fa.store_string(JSON.stringify(y_json, "  "))
			out_fa.close()

func _scan_directory_for_songs(dir_path: String, max_depth: int = 4) -> Array:
	var results = []
	_scan_dir_recursive(dir_path, results, 0, max_depth)
	return results

func _scan_dir_recursive(dir_path: String, out_results: Array, current_depth: int, max_depth: int):
	if current_depth > max_depth:
		return
	var dir = DirAccess.open(dir_path)
	if not dir:
		return
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if not fname.begins_with("."):
			var full_path = dir_path.path_join(fname)
			if dir.current_is_dir():
				var has_ini = FileAccess.file_exists(full_path.path_join("song.ini"))
				var has_chart = FileAccess.file_exists(full_path.path_join("notes.chart"))
				var has_mid = FileAccess.file_exists(full_path.path_join("notes.mid"))
				if has_ini or has_chart or has_mid:
					out_results.append({"path": full_path, "is_dir": true, "name": fname})
				else:
					_scan_dir_recursive(full_path, out_results, current_depth + 1, max_depth)
			elif fname.to_lower().ends_with(".sng") or fname.to_lower().ends_with(".yargsong"):
				out_results.append({"path": full_path, "is_dir": false, "name": fname})
		fname = dir.get_next()

func _scan_for_artists():
	if installed_artists.is_empty():
		_populate_library()
	_discover_new_recommendations()

func _weighted_pick_artists(count: int) -> Array:
	# Build a weighted pool: each artist appears once per song they have
	var pool = []
	for artist in installed_artists:
		var key = artist.to_lower()
		var weight = installed_artist_counts.get(key, 1)
		for _i in range(weight):
			pool.append(artist)
	pool.shuffle()
	# Pick unique artists from the shuffled weighted pool
	var picked = []
	var picked_lower = []
	for candidate in pool:
		var cl = candidate.to_lower()
		if not picked_lower.has(cl):
			picked.append(candidate)
			picked_lower.append(cl)
		if picked.size() >= count:
			break
	return picked

func _discover_new_recommendations():
	if is_discovering:
		return
	if installed_artists.is_empty():
		status_label.text = "No songs found to base recommendations on!"
		if discover_status_label:
			discover_status_label.text = "No songs found in library. Add songs to get recommendations!"
		return
		
	is_discovering = true
	discover_view = "artists"
	discover_current_artist = ""
	if discover_refresh_btn:
		discover_refresh_btn.disabled = true
		discover_refresh_btn.text = "⏳ Discovering..."
		
	for child in result_container.get_children():
		child.queue_free()
		
	var loading_lbl = Label.new()
	loading_lbl.text = "🎧 Finding similar artists via Music-Map..."
	loading_lbl.add_theme_font_override("font", custom_font)
	loading_lbl.add_theme_font_size_override("font_size", 18)
	loading_lbl.add_theme_color_override("font_color", Color(0.4, 0.75, 1, 1))
	result_container.add_child(loading_lbl)
	
	# Weighted seed: artists with more songs are more likely to be seeds
	current_seed_artists = _weighted_pick_artists(3)
	status_label.text = "Fetching recommendations based on: " + ", ".join(current_seed_artists)
	if discover_status_label:
		discover_status_label.text = "Discovering artists similar to: " + ", ".join(current_seed_artists)
		
	_fetch_similar_artists(current_seed_artists)

func _fetch_similar_artists(artists: Array):
	recommended_artists.clear()
	pending_musicmap = artists.size()
	if pending_musicmap == 0:
		_on_recommendations_ready()
		return
	
	for artist in artists:
		var http = HTTPRequest.new()
		add_child(http)
		http.request_completed.connect(func(_result, response_code, _headers, body):
			if response_code == 200:
				var html = body.get_string_from_utf8()
				_parse_musicmap_html(html, artist)
			http.queue_free()
			pending_musicmap -= 1
			if pending_musicmap <= 0:
				_on_recommendations_ready()
		)
		var safe_artist = artist.strip_edges().uri_encode().replace("%20", "+")
		var url = "https://www.music-map.com/" + safe_artist
		var req_headers = ["User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)"]
		var err = http.request(url, req_headers)
		if err != OK:
			http.queue_free()
			pending_musicmap -= 1
			if pending_musicmap <= 0:
				_on_recommendations_ready()

func _parse_musicmap_html(html: String, seed_artist: String):
	var regex = RegEx.new()
	regex.compile("class=S[^>]*>([^<]+)</a>")
	var matches = regex.search_all(html)
	var added = 0
	var seed_norm = _clean_text_for_matching(seed_artist)
	for m in matches:
		var sim = m.get_string(1).strip_edges()
		if sim.is_empty():
			continue
		var sim_norm = _clean_text_for_matching(sim)
		if sim_norm == "" or sim_norm == seed_norm:
			continue
		var in_library = installed_artists.any(func(a): return _clean_text_for_matching(a) == sim_norm)
		var in_recommended = recommended_artists.any(func(a): return _clean_text_for_matching(a) == sim_norm)
		if not in_library and not in_recommended:
			recommended_artists.append(sim)
			added += 1
			if added >= 8:
				break

func _on_recommendations_ready():
	is_discovering = false
	if discover_refresh_btn:
		discover_refresh_btn.disabled = false
		discover_refresh_btn.text = "🎲  Discover More"
		
	# Deduplicate recommended artists strictly using normalized signatures
	var unique_artists = []
	var seen_signatures = {}
	for a in recommended_artists:
		var sig = _clean_text_for_matching(a)
		if sig != "" and not seen_signatures.has(sig):
			seen_signatures[sig] = true
			unique_artists.append(a)
	recommended_artists = unique_artists

	if recommended_artists.is_empty():
		status_label.text = "Could not find similar artists. Click 'Discover More' to try again!"
		if discover_status_label:
			discover_status_label.text = "Could not find similar artists on Music-Map. Try clicking 'Discover More'!"
		_render_artist_recommendations_ui()
		return
		
	status_label.text = "Ready! Found %d recommended artists based on your library." % recommended_artists.size()
	if discover_status_label:
		if not current_seed_artists.is_empty():
			discover_status_label.text = "Recommended based on: %s (%d artists)" % [", ".join(current_seed_artists), recommended_artists.size()]
		else:
			discover_status_label.text = "Found %d recommended artists" % recommended_artists.size()
			
	_render_artist_recommendations_ui()

func _render_artist_recommendations_ui():
	discover_view = "artists"
	discover_current_artist = ""
	
	for child in result_container.get_children():
		child.queue_free()
		
	if recommended_artists.is_empty():
		var empty_panel = VBoxContainer.new()
		empty_panel.add_theme_constant_override("separation", 12)
		
		var lbl = Label.new()
		lbl.text = "No similar artists found for this discovery mix."
		lbl.add_theme_font_override("font", custom_font)
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9, 1))
		empty_panel.add_child(lbl)
		
		var hint_lbl = Label.new()
		hint_lbl.text = "Click 'Discover More' above to discover artists based on other songs in your library!"
		hint_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 1))
		empty_panel.add_child(hint_lbl)
		
		result_container.add_child(empty_panel)
		return
		
	var header_hint = Label.new()
	header_hint.text = "Click any artist below to explore their top charts and sync them with your library:"
	header_hint.add_theme_font_override("font", custom_font)
	header_hint.add_theme_font_size_override("font_size", 14)
	header_hint.add_theme_color_override("font_color", Color(0.65, 0.75, 0.9, 1))
	result_container.add_child(header_hint)
	
	for artist in recommended_artists:
		var card_btn = Button.new()
		card_btn.custom_minimum_size = Vector2(0, 56)
		card_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		card_btn.add_theme_font_override("font", custom_font)
		card_btn.add_theme_font_size_override("font_size", 17)
		card_btn.text = "  🎤  " + artist
		
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.12, 0.13, 0.17, 1)
		st.corner_radius_top_left = 10
		st.corner_radius_top_right = 10
		st.corner_radius_bottom_right = 10
		st.corner_radius_bottom_left = 10
		st.border_color = Color(0.22, 0.25, 0.35, 1)
		st.border_width_left = 1
		st.border_width_top = 1
		st.border_width_right = 1
		st.border_width_bottom = 1
		st.content_margin_left = 16
		st.content_margin_right = 16
		
		var st_h = st.duplicate()
		st_h.bg_color = Color(0.16, 0.22, 0.32, 1)
		st_h.border_color = Color(0.35, 0.85, 1.0, 1)
		st_h.border_width_left = 2
		st_h.border_width_top = 2
		st_h.border_width_right = 2
		st_h.border_width_bottom = 2
		
		card_btn.add_theme_stylebox_override("normal", st)
		card_btn.add_theme_stylebox_override("hover", st_h)
		card_btn.add_theme_stylebox_override("focus", st_h)
		card_btn.add_theme_stylebox_override("pressed", st_h)
		
		var arrow_lbl = Label.new()
		arrow_lbl.text = "Explore Charts  ➔"
		arrow_lbl.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
		arrow_lbl.add_theme_font_override("font", custom_font)
		arrow_lbl.add_theme_font_size_override("font_size", 13)
		arrow_lbl.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0, 0.8))
		arrow_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		arrow_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		arrow_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		arrow_lbl.position.x = -180
		card_btn.add_child(arrow_lbl)
		
		var captured_artist = artist
		card_btn.pressed.connect(func(): _show_artist_songs(captured_artist))
		result_container.add_child(card_btn)

func _show_artist_songs(artist_name: String):
	discover_view = "songs"
	discover_current_artist = artist_name
	
	for child in result_container.get_children():
		child.queue_free()
		
	var top_nav = HBoxContainer.new()
	top_nav.add_theme_constant_override("separation", 14)
	
	var back_btn = Button.new()
	back_btn.text = "← Back to Artists"
	back_btn.add_theme_font_override("font", custom_font)
	back_btn.custom_minimum_size = Vector2(170, 42)
	var b_st = StyleBoxFlat.new()
	b_st.bg_color = Color(0.12, 0.16, 0.24, 1)
	b_st.corner_radius_top_left = 8
	b_st.corner_radius_top_right = 8
	b_st.corner_radius_bottom_right = 8
	b_st.corner_radius_bottom_left = 8
	b_st.border_color = Color(0.3, 0.5, 0.75, 1)
	b_st.border_width_left = 1
	b_st.border_width_top = 1
	b_st.border_width_right = 1
	b_st.border_width_bottom = 1
	var b_h = b_st.duplicate()
	b_h.bg_color = Color(0.18, 0.26, 0.38, 1)
	b_h.border_color = Color(0.45, 0.8, 1.0, 1)
	back_btn.add_theme_stylebox_override("normal", b_st)
	back_btn.add_theme_stylebox_override("hover", b_h)
	back_btn.add_theme_stylebox_override("focus", b_h)
	back_btn.pressed.connect(_render_artist_recommendations_ui)
	top_nav.add_child(back_btn)
	
	var heading_lbl = Label.new()
	heading_lbl.text = "Top Charts for: " + artist_name
	heading_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_lbl.add_theme_font_override("font", custom_font)
	heading_lbl.add_theme_font_size_override("font_size", 18)
	heading_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	top_nav.add_child(heading_lbl)
	
	var open_artist_enchor_btn = Button.new()
	open_artist_enchor_btn.text = "🔗 Enchor Page"
	open_artist_enchor_btn.add_theme_font_override("font", custom_font)
	open_artist_enchor_btn.custom_minimum_size = Vector2(140, 42)
	open_artist_enchor_btn.pressed.connect(func():
		OS.shell_open("https://www.enchor.us/?search=" + artist_name.uri_encode())
	)
	top_nav.add_child(open_artist_enchor_btn)
	
	result_container.add_child(top_nav)
	
	var loading_lbl = Label.new()
	loading_lbl.text = "Searching Enchor for charts from %s..." % artist_name
	loading_lbl.add_theme_font_override("font", custom_font)
	loading_lbl.add_theme_color_override("font_color", Color(0.4, 0.75, 1, 1))
	result_container.add_child(loading_lbl)
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_result, response_code, _headers, body):
		http.queue_free()
		if is_instance_valid(loading_lbl):
			loading_lbl.queue_free()
			
		if response_code != 200 and response_code != 201:
			var err_lbl = Label.new()
			err_lbl.text = "Failed to load charts from Enchor (HTTP %s)." % response_code
			err_lbl.add_theme_font_override("font", custom_font)
			err_lbl.add_theme_color_override("font_color", Color(1, 0.4, 0.4, 1))
			result_container.add_child(err_lbl)
			return
			
		var json = JSON.parse_string(body.get_string_from_utf8())
		var artist_charts = []
		if json and json is Dictionary and json.has("data") and json["data"] is Array:
			var target_lower = artist_name.to_lower()
			for chart in json["data"]:
				var c_artist = chart.get("artist", "").strip_edges().to_lower()
				if c_artist == target_lower or c_artist.begins_with(target_lower + " ") or target_lower.begins_with(c_artist):
					artist_charts.append(chart)
			if artist_charts.is_empty():
				artist_charts = json["data"]
				
		if artist_charts.is_empty():
			var no_c = Label.new()
			no_c.text = "No charts found on Enchor for '%s'." % artist_name
			no_c.add_theme_font_override("font", custom_font)
			no_c.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 1))
			result_container.add_child(no_c)
			return
			
		for chart in artist_charts:
			var chart_artist = chart.get("artist", artist_name)
			var song_name = chart.get("name", "Unknown")
			var charter = chart.get("charter", "Unknown")
			var diff_str = _format_difficulty_rating(chart)
			var can_dl = _can_chart_be_downloaded(chart)
			var installed_folder = _find_installed_song([chart_artist], song_name)
			var is_installed = (installed_folder != "")
			
			# Root Card Container
			var card = PanelContainer.new()
			card.custom_minimum_size = Vector2(0, 60)
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var card_style = StyleBoxFlat.new()
			card_style.bg_color = Color(0.11, 0.12, 0.16, 1)
			card_style.corner_radius_top_left = 8
			card_style.corner_radius_top_right = 8
			card_style.corner_radius_bottom_right = 8
			card_style.corner_radius_bottom_left = 8
			card_style.content_margin_left = 14
			card_style.content_margin_right = 14
			card_style.content_margin_top = 6
			card_style.content_margin_bottom = 6
			if is_installed:
				card_style.border_color = Color(0.2, 0.65, 0.85, 0.45)
				card_style.border_width_left = 1
				card_style.border_width_top = 1
				card_style.border_width_right = 1
				card_style.border_width_bottom = 1
			else:
				card_style.border_color = Color(0.2, 0.24, 0.32, 0.6)
				card_style.border_width_left = 1
				card_style.border_width_top = 1
				card_style.border_width_right = 1
				card_style.border_width_bottom = 1
			card.add_theme_stylebox_override("panel", card_style)
			
			var row = HBoxContainer.new()
			row.add_theme_constant_override("separation", 14)
			row.alignment = BoxContainer.ALIGNMENT_CENTER
			card.add_child(row)
			
			# Column 1: Title & Artist Column
			var track_col = VBoxContainer.new()
			track_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			track_col.size_flags_stretch_ratio = 2.8
			track_col.alignment = BoxContainer.ALIGNMENT_CENTER
			track_col.add_theme_constant_override("separation", 2)
			track_col.mouse_filter = Control.MOUSE_FILTER_STOP
			track_col.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			
			var title_row = HBoxContainer.new()
			title_row.add_theme_constant_override("separation", 6)
			
			var title_lbl = Label.new()
			title_lbl.text = song_name
			title_lbl.add_theme_font_override("font", custom_font)
			title_lbl.add_theme_font_size_override("font_size", 15)
			title_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			title_row.add_child(title_lbl)
			
			if is_installed:
				var tag = Label.new()
				tag.name = "InLibTag"
				tag.text = "[💾 In Library]"
				tag.add_theme_font_override("font", custom_font)
				tag.add_theme_font_size_override("font_size", 11)
				tag.add_theme_color_override("font_color", Color(0.2, 0.9, 0.65, 1))
				title_row.add_child(tag)
				
			track_col.add_child(title_row)
			
			var artist_lbl = Label.new()
			artist_lbl.text = chart_artist
			artist_lbl.add_theme_font_override("font", custom_font)
			artist_lbl.add_theme_font_size_override("font_size", 13)
			artist_lbl.add_theme_color_override("font_color", Color(0.7, 0.76, 0.88, 1))
			artist_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			track_col.add_child(artist_lbl)
			
			row.add_child(track_col)
			
			# Column 2: Charter & Origin Badge Column
			var charter_col = VBoxContainer.new()
			charter_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			charter_col.size_flags_stretch_ratio = 1.6
			charter_col.alignment = BoxContainer.ALIGNMENT_CENTER
			charter_col.add_theme_constant_override("separation", 2)
			
			var p_val = chart.get("packName")
			var pack_name = (p_val if p_val is String else "").strip_edges()
			var charter_lower = charter.to_lower()
			var pack_lower = pack_name.to_lower()
			var is_csc = pack_lower.contains("custom songs central") or charter_lower.contains("custom songs central") or str(chart.get("icon", "")).to_lower() == "csc"
			var official_names = ["harmonix", "neversoft", "redoctane", "activision", "vicarious visions"]
			var is_official = official_names.any(func(x): return charter_lower.contains(x))
			
			var charter_lbl = Label.new()
			charter_lbl.add_theme_font_override("font", custom_font)
			charter_lbl.add_theme_font_size_override("font_size", 13)
			charter_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			
			if is_csc:
				charter_lbl.text = "🏆 Custom Songs Central"
				charter_lbl.add_theme_color_override("font_color", Color(0.88, 0.7, 1.0, 1))
			elif is_official:
				charter_lbl.text = "⭐ %s" % charter
				charter_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1))
			else:
				charter_lbl.text = "👤 %s" % (charter if charter != "" else "Unknown Charter")
				charter_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95, 1))
			charter_col.add_child(charter_lbl)
			
			var pack_sub_lbl = Label.new()
			pack_sub_lbl.add_theme_font_override("font", custom_font)
			pack_sub_lbl.add_theme_font_size_override("font_size", 11)
			pack_sub_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			
			if is_csc and charter_lower != "custom songs central" and charter != "" and charter != "Unknown":
				pack_sub_lbl.text = "by %s" % charter
				pack_sub_lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 0.85, 0.9))
				charter_col.add_child(pack_sub_lbl)
			elif pack_name != "" and pack_name != "None" and not is_csc:
				pack_sub_lbl.text = "📦 %s" % pack_name
				pack_sub_lbl.add_theme_color_override("font_color", Color(0.65, 0.7, 0.82, 0.85))
				charter_col.add_child(pack_sub_lbl)
			elif is_official:
				pack_sub_lbl.text = "Official Release"
				pack_sub_lbl.add_theme_color_override("font_color", Color(0.35, 0.7, 0.9, 0.8))
				charter_col.add_child(pack_sub_lbl)
				
			row.add_child(charter_col)
			
			# Column 3: Difficulty & Details Column
			var diff_col = VBoxContainer.new()
			diff_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			diff_col.size_flags_stretch_ratio = 1.4
			diff_col.alignment = BoxContainer.ALIGNMENT_CENTER
			diff_col.add_theme_constant_override("separation", 2)
			
			var diff_lbl = Label.new()
			diff_lbl.text = diff_str
			diff_lbl.add_theme_font_override("font", custom_font)
			diff_lbl.add_theme_font_size_override("font_size", 13)
			diff_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			
			if diff_str.contains("DEVIL"):
				diff_lbl.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45, 1))
			elif diff_str.begins_with("★"):
				diff_lbl.add_theme_color_override("font_color", Color(1.0, 0.82, 0.38, 1))
			elif diff_str.contains("No Lead"):
				diff_lbl.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.8))
			else:
				diff_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95, 1))
			diff_col.add_child(diff_lbl)
			
			var total_sec = int(chart.get("song_length", 0) / 1000.0)
			var length_str = "%d:%02d" % [int(total_sec / 60.0), total_sec % 60] if total_sec > 0 else ""
			
			var nd_val = chart.get("notesData")
			var nd: Dictionary = nd_val if nd_val is Dictionary else {}
			var insts_val = nd.get("instruments")
			var insts: Array = insts_val if insts_val is Array else []
			var inst_icons = []
			if insts.has("guitar"): inst_icons.append("🎸 Lead")
			if insts.has("bass"): inst_icons.append("🎸 Bass")
			if insts.has("drums"): inst_icons.append("🥁 Drums")
			if insts.has("vocals"): inst_icons.append("🎤 Vocals")
			if insts.has("keys"): inst_icons.append("🎹 Keys")
			
			var details_parts = []
			if not inst_icons.is_empty():
				details_parts.append(inst_icons[0] if inst_icons.size() == 1 else "%s (+%d)" % [inst_icons[0], inst_icons.size() - 1])
			if length_str != "":
				details_parts.append(length_str)
				
			var details_sub = " • ".join(details_parts) if not details_parts.is_empty() else "Standard Chart"
			
			var details_lbl = Label.new()
			details_lbl.text = details_sub
			details_lbl.add_theme_font_override("font", custom_font)
			details_lbl.add_theme_font_size_override("font_size", 11)
			details_lbl.add_theme_color_override("font_color", Color(0.4, 0.85, 0.7, 0.9))
			details_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
			diff_col.add_child(details_lbl)
			
			row.add_child(diff_col)
			
			# Column 4: Action Buttons
			var actions_col = HBoxContainer.new()
			actions_col.alignment = BoxContainer.ALIGNMENT_END
			actions_col.add_theme_constant_override("separation", 8)
			
			var dl_btn = Button.new()
			dl_btn.custom_minimum_size = Vector2(145, 46)
			dl_btn.add_theme_font_override("font", custom_font)
			dl_btn.add_theme_font_size_override("font_size", 13)
			
			var dl_style = StyleBoxFlat.new()
			dl_style.corner_radius_top_left = 8
			dl_style.corner_radius_top_right = 8
			dl_style.corner_radius_bottom_right = 8
			dl_style.corner_radius_bottom_left = 8
			
			if is_installed:
				dl_btn.text = "💾 In Library"
				dl_style.bg_color = Color(0.08, 0.22, 0.32, 1)
				dl_style.border_color = Color(0.2, 0.7, 0.95, 1)
				dl_style.border_width_left = 1
				dl_style.border_width_top = 1
				dl_style.border_width_right = 1
				dl_style.border_width_bottom = 1
				dl_btn.disabled = true
			elif can_dl:
				dl_btn.text = "⬇ Add to Library"
				dl_style.bg_color = Color(0.08, 0.28, 0.15, 1)
				dl_style.border_color = Color(0.11, 0.85, 0.35, 1)
				dl_style.border_width_left = 1
				dl_style.border_width_top = 1
				dl_style.border_width_right = 1
				dl_style.border_width_bottom = 1
			else:
				dl_btn.text = "⬇ Add to Library"
				dl_style.bg_color = Color(0.12, 0.2, 0.3, 1)
				dl_style.border_color = Color(0.3, 0.65, 0.95, 1)
				dl_style.border_width_left = 1
				dl_style.border_width_top = 1
				dl_style.border_width_right = 1
				dl_style.border_width_bottom = 1
				
			var dl_hover = dl_style.duplicate()
			dl_hover.bg_color = Color(0.15, 0.38, 0.22, 1) if can_dl else Color(0.18, 0.28, 0.42, 1)
			dl_btn.add_theme_stylebox_override("normal", dl_style)
			dl_btn.add_theme_stylebox_override("hover", dl_hover)
			dl_btn.add_theme_stylebox_override("focus", dl_hover)
			actions_col.add_child(dl_btn)
			
			var web_btn = Button.new()
			web_btn.text = "🔗 Enchor"
			web_btn.custom_minimum_size = Vector2(85, 46)
			web_btn.add_theme_font_override("font", custom_font)
			web_btn.add_theme_font_size_override("font_size", 12)
			var wb_style = StyleBoxFlat.new()
			wb_style.bg_color = Color(0.12, 0.13, 0.17, 1)
			wb_style.corner_radius_top_left = 8
			wb_style.corner_radius_top_right = 8
			wb_style.corner_radius_bottom_right = 8
			wb_style.corner_radius_bottom_left = 8
			wb_style.border_color = Color(0.25, 0.28, 0.36, 1)
			wb_style.border_width_left = 1
			wb_style.border_width_top = 1
			wb_style.border_width_right = 1
			wb_style.border_width_bottom = 1
			var wb_hover = wb_style.duplicate()
			wb_hover.bg_color = Color(0.18, 0.22, 0.32, 1)
			wb_hover.border_color = Color(0.4, 0.7, 1, 1)
			web_btn.add_theme_stylebox_override("normal", wb_style)
			web_btn.add_theme_stylebox_override("hover", wb_hover)
			web_btn.add_theme_stylebox_override("focus", wb_hover)
			actions_col.add_child(web_btn)
			
			row.add_child(actions_col)
			
			# Setup button actions
			var open_enchor = func():
				var q = song_name + " " + chart_artist
				OS.shell_open("https://www.enchor.us/?search=" + q.uri_encode())
				
			web_btn.pressed.connect(open_enchor)
			
			var captured_chart = chart
			var on_dl_clicked = func():
				if is_installed:
					status_label.text = "Song is already in library: %s - %s" % [chart_artist, song_name]
					return
				if can_dl:
					dl_btn.disabled = true
					dl_btn.text = "⏳ Downloading..."
					status_label.text = "Downloading %s - %s..." % [chart_artist, song_name]
					var success = await _download_single_chart(captured_chart)
					if success:
						dl_btn.text = "💾 In Library"
						dl_btn.disabled = true
						var succ_st = dl_style.duplicate()
						succ_st.bg_color = Color(0.08, 0.22, 0.32, 1)
						succ_st.border_color = Color(0.2, 0.7, 0.95, 1)
						dl_btn.add_theme_stylebox_override("normal", succ_st)
						dl_btn.add_theme_stylebox_override("hover", succ_st)
						dl_btn.add_theme_stylebox_override("focus", succ_st)
						
						var inst_st = card_style.duplicate()
						inst_st.border_color = Color(0.2, 0.65, 0.85, 0.6)
						card.add_theme_stylebox_override("panel", inst_st)
						
						if not title_row.has_node("InLibTag"):
							var new_tag = Label.new()
							new_tag.name = "InLibTag"
							new_tag.text = "[💾 In Library]"
							new_tag.add_theme_font_override("font", custom_font)
							new_tag.add_theme_font_size_override("font_size", 11)
							new_tag.add_theme_color_override("font_color", Color(0.2, 0.9, 0.65, 1))
							title_row.add_child(new_tag)
							
						status_label.text = "Successfully installed %s - %s into library!" % [chart_artist, song_name]
					else:
						dl_btn.disabled = false
						dl_btn.text = "Retry Download"
						status_label.text = "Download failed for %s. Click Retry to try again." % song_name
				else:
					open_enchor.call()
			
			track_col.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					on_dl_clicked.call()
			)
			dl_btn.pressed.connect(on_dl_clicked)
			
			result_container.add_child(card)
	)
	var url = "https://api.enchor.us/search"
	var payload = JSON.stringify({"search": artist_name, "page": 1, "per_page": 30})
	var req_headers = ["Content-Type: application/json", "User-Agent: CloneHeroCompanion/1.0"]
	http.request(url, req_headers, HTTPClient.METHOD_POST, payload)

func _can_chart_be_downloaded(chart) -> bool:
	if not (chart is Dictionary):
		return false
	if chart.has("md5") and chart["md5"] != null:
		var md5_str = str(chart["md5"]).strip_edges()
		if md5_str != "" and md5_str != "null" and md5_str != "<null>":
			return true
	if chart.has("driveFileId") and chart["driveFileId"] != null:
		var did_str = str(chart["driveFileId"]).strip_edges()
		if did_str != "" and did_str != "null" and did_str != "<null>":
			return true
	return false

func _download_single_chart(chart) -> bool:
	if not (chart is Dictionary):
		return false
		
	if base_ch_path == "" or not DirAccess.dir_exists_absolute(base_ch_path):
		_find_song_directories()
		if base_ch_path == "" or not DirAccess.dir_exists_absolute(base_ch_path):
			status_label.text = "Songs folder not found! Please check library directory in Settings."
			return false
			
	var artist = "Unknown Artist"
	if chart.has("artist") and chart["artist"] != null:
		var a_str = str(chart["artist"]).strip_edges()
		if a_str != "" and a_str != "null" and a_str != "<null>":
			artist = a_str
			
	var s_name = "Unknown Song"
	if chart.has("name") and chart["name"] != null:
		var n_str = str(chart["name"]).strip_edges()
		if n_str != "" and n_str != "null" and n_str != "<null>":
			s_name = n_str
			
	var charter = "Unknown Charter"
	if chart.has("charter") and chart["charter"] != null:
		var c_str = str(chart["charter"]).strip_edges()
		if c_str != "" and c_str != "null" and c_str != "<null>":
			charter = c_str
	
	var md5 = ""
	if chart.has("md5") and chart["md5"] != null:
		var m_str = str(chart["md5"]).strip_edges()
		if m_str != "" and m_str != "null" and m_str != "<null>":
			md5 = m_str
			
	var encoder_version = 0
	if chart.has("encoderVersion") and chart["encoderVersion"] != null:
		var ev = chart["encoderVersion"]
		if ev is int or ev is float:
			encoder_version = int(ev)
			
	var drive_id = ""
	if chart.has("driveFileId") and chart["driveFileId"] != null:
		var did_str = str(chart["driveFileId"]).strip_edges()
		if did_str != "" and did_str != "null" and did_str != "<null>":
			drive_id = did_str
			
	var drive_fname = "chart.sng"
	if chart.has("driveFileName") and chart["driveFileName"] != null:
		var df = str(chart["driveFileName"]).strip_edges()
		if df != "" and df != "null" and df != "<null>":
			drive_fname = df
			
	if md5 == "" and drive_id == "":
		status_label.text = "No direct download link available for %s." % s_name
		return false
		
	var folder_name = _sanitize_filename("%s - %s (%s)" % [artist, s_name, charter])
	var target_dir = base_ch_path.path_join(folder_name)
	DirAccess.make_dir_recursive_absolute(target_dir)
	
	var download_success = false
	
	# Strategy 1: Enchor official SNG CDN (Cloudflare CDN, ultra-fast and direct binary .sng)
	if md5 != "":
		var sng_url = ""
		if encoder_version > 0:
			sng_url = "https://files.enchor.us/charts/v%d/%s.sng" % [encoder_version, md5]
		else:
			sng_url = "https://files.enchor.us/%s.sng" % md5
			
		var safe_sng_name = _sanitize_filename("%s - %s.sng" % [artist, s_name])
		if safe_sng_name == ".sng" or safe_sng_name.strip_edges() == "" or safe_sng_name == "chart.sng":
			safe_sng_name = "%s - %s.sng" % [_sanitize_filename(artist), _sanitize_filename(s_name)]
			if safe_sng_name == " - .sng":
				safe_sng_name = "song.sng"
		var sng_path = target_dir.path_join(safe_sng_name)
		
		var http = HTTPRequest.new()
		add_child(http)
		http.download_file = sng_path
		http.timeout = 60.0
		var headers = ["User-Agent: CloneHeroCompanion/1.0", "Accept: */*"]
		var err = http.request(sng_url, headers)
		if err == OK:
			var res = await http.request_completed
			http.queue_free()
			var http_code = res[1]
			if http_code == 200 and FileAccess.file_exists(sng_path):
				var fa = FileAccess.open(sng_path, FileAccess.READ)
				var f_size = fa.get_length() if fa else 0
				if fa:
					fa.close()
				if f_size > 1024:
					download_success = true
				else:
					DirAccess.remove_absolute(sng_path)
			else:
				if FileAccess.file_exists(sng_path):
					DirAccess.remove_absolute(sng_path)
		else:
			http.queue_free()
			
	# Strategy 2: Google Drive fallback if Strategy 1 did not succeed and drive_id is present
	if not download_success and drive_id != "":
		var safe_drive_fname = _sanitize_filename(drive_fname)
		if safe_drive_fname == "" or safe_drive_fname == "chart":
			safe_drive_fname = "chart.sng"
		var dl_temp_path = target_dir.path_join(safe_drive_fname)
		
		var drive_urls = [
			"https://drive.usercontent.google.com/download?id=%s&export=download&confirm=t" % drive_id,
			"https://drive.google.com/uc?export=download&id=%s&confirm=t" % drive_id
		]
		
		for dl_url in drive_urls:
			var dl_http = HTTPRequest.new()
			add_child(dl_http)
			dl_http.download_file = dl_temp_path
			dl_http.timeout = 120.0
			var gd_headers = [
				"User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
				"Accept: */*"
			]
			var err = dl_http.request(dl_url, gd_headers)
			if err != OK:
				dl_http.queue_free()
				continue
				
			var res = await dl_http.request_completed
			dl_http.queue_free()
			var code = res[1]
			
			if code == 200 and FileAccess.file_exists(dl_temp_path):
				var fa = FileAccess.open(dl_temp_path, FileAccess.READ)
				var is_html = false
				var length = 0
				if fa:
					length = fa.get_length()
					var prefix = fa.get_buffer(mini(length, 100)).get_string_from_utf8().to_lower()
					fa.close()
					if prefix.contains("<!doctype") or prefix.contains("<html") or prefix.contains("google drive"):
						is_html = true
				
				if not is_html and length > 500:
					_process_downloaded_file(dl_temp_path, target_dir)
					download_success = true
					break
				else:
					DirAccess.remove_absolute(dl_temp_path)
			else:
				if FileAccess.file_exists(dl_temp_path):
					DirAccess.remove_absolute(dl_temp_path)
					
	if download_success:
		var sig = _get_song_signature(artist, s_name)
		installed_songs_map[sig] = folder_name
		var clean_t = _clean_song_title(s_name)
		if clean_t != s_name and clean_t != "":
			installed_songs_map[_get_song_signature(artist, clean_t)] = folder_name
		if not installed_artists.has(artist):
			installed_artists.append(artist)
		installed_artist_counts[artist.to_lower()] = installed_artist_counts.get(artist.to_lower(), 0) + 1
		_populate_library()
		return true
		
	return false


func _populate_library():
	for child in library_list.get_children():
		child.queue_free()
		
	installed_songs_map.clear()
	installed_artists.clear()
	installed_artist_counts.clear()

	var scan_dirs = []
	if not song_directories.is_empty():
		for d in song_directories:
			if DirAccess.dir_exists_absolute(d) and not scan_dirs.has(d):
				scan_dirs.append(d)
	elif base_ch_path != "" and DirAccess.dir_exists_absolute(base_ch_path):
		scan_dirs.append(base_ch_path)

	if scan_dirs.is_empty():
		return
		
	var song_items = []
	for d in scan_dirs:
		var items = _scan_directory_for_songs(d)
		song_items.append_array(items)

	for item in song_items:
		var full_path = item["path"]
		var is_dir = item["is_dir"]
		var file_name = item["name"]
		var is_yarg = file_name.to_lower().ends_with(".yargsong")
		
		# Index song for duplicate identification
		var s_artist = ""
		var s_title = ""
		if is_dir:
			var ini_path = full_path.path_join("song.ini")
			if FileAccess.file_exists(ini_path):
				var fa = FileAccess.open(ini_path, FileAccess.READ)
				if fa:
					while not fa.eof_reached():
						var line = fa.get_line().strip_edges()
						if (line.to_lower().begins_with("name") or line.to_lower().begins_with("title")) and line.contains("="):
							s_title = line.split("=", false, 1)[1].strip_edges().trim_prefix("\"").trim_suffix("\"").trim_prefix("'").trim_suffix("'").strip_edges()
						elif line.to_lower().begins_with("artist") and line.contains("="):
							s_artist = line.split("=", false, 1)[1].strip_edges().trim_prefix("\"").trim_suffix("\"").trim_prefix("'").trim_suffix("'").strip_edges()

					fa.close()
		if s_artist == "" or s_title == "":
			var raw = file_name.trim_suffix(".sng").trim_suffix(".yargsong")
			var parts = raw.split("-")
			if parts.size() > 1:
				s_artist = parts[0].strip_edges()
				s_title = parts[1].strip_edges()
				var p_idx = s_title.find("(")
				if p_idx != -1:
					s_title = s_title.substr(0, p_idx).strip_edges()
		if s_artist == "" or s_title == "":
			var p_raw = full_path.get_base_dir().get_file().trim_suffix(".sng").trim_suffix(".yargsong")
			var p_parts = p_raw.split("-")
			if p_parts.size() > 1:
				s_artist = p_parts[0].strip_edges()
				s_title = p_parts[1].strip_edges()
				var p_idx = s_title.find("(")
				if p_idx != -1:
					s_title = s_title.substr(0, p_idx).strip_edges()

					
		s_artist = s_artist.strip_edges()
		s_title = s_title.strip_edges()
		
		if s_artist != "":
			var has_a = installed_artists.any(func(a): return a.to_lower() == s_artist.to_lower())
			if not has_a:
				installed_artists.append(s_artist)
			# Accumulate per-artist song count for weighted discovery
			var artist_key = s_artist.to_lower()
			installed_artist_counts[artist_key] = installed_artist_counts.get(artist_key, 0) + 1
				
		if s_artist != "" and s_title != "":
			var sig = _get_song_signature(s_artist, s_title)
			installed_songs_map[sig] = file_name
			var clean_t = _clean_song_title(s_title)
			if clean_t != s_title and clean_t != "":
				installed_songs_map[_get_song_signature(s_artist, clean_t)] = file_name
				
		var raw_name = file_name.trim_suffix(".sng").trim_suffix(".yargsong")
		var raw_parts = raw_name.split("-")
		if raw_parts.size() > 1:
			var f_art = raw_parts[0].strip_edges()
			var f_tit = raw_parts[1].strip_edges()
			var f_p = f_tit.find("(")
			if f_p != -1:
				f_tit = f_tit.substr(0, f_p).strip_edges()
			if f_art != "" and f_tit != "":
				installed_songs_map[_get_song_signature(f_art, f_tit)] = file_name

		# Song Row matching Importer aesthetic
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		
		# Visible 44x44 Checkbox status square
		var box = Button.new()
		box.name = "Box"
		box.custom_minimum_size = Vector2(44, 44)
		box.text = ""
		box.add_theme_font_override("font", custom_font)
		box.add_theme_font_size_override("font_size", 16)
		box.set_meta("path", full_path)
		box.set_meta("is_dir", is_dir)
		box.set_meta("is_selected", false)
		
		var style_empty = StyleBoxFlat.new()
		style_empty.bg_color = Color(0.12, 0.12, 0.16, 1)
		style_empty.corner_radius_top_left = 8
		style_empty.corner_radius_top_right = 8
		style_empty.corner_radius_bottom_right = 8
		style_empty.corner_radius_bottom_left = 8
		style_empty.border_color = Color(0.3, 0.32, 0.4, 1)
		style_empty.border_width_left = 1
		style_empty.border_width_top = 1
		style_empty.border_width_right = 1
		style_empty.border_width_bottom = 1
		box.add_theme_stylebox_override("normal", style_empty)
		
		var style_checked = style_empty.duplicate()
		style_checked.bg_color = Color(0.08, 0.28, 0.15, 1)
		style_checked.border_color = Color(0.11, 0.85, 0.35, 1)
		style_checked.border_width_left = 2
		style_checked.border_width_top = 2
		style_checked.border_width_right = 2
		style_checked.border_width_bottom = 2
		
		var style_hover = style_empty.duplicate()
		style_hover.bg_color = Color(0.16, 0.18, 0.24, 1)
		style_hover.border_color = Color(0.4, 0.75, 1, 1)
		style_hover.border_width_left = 2
		style_hover.border_width_top = 2
		style_hover.border_width_right = 2
		style_hover.border_width_bottom = 2
		box.add_theme_stylebox_override("hover", style_hover)
		box.add_theme_stylebox_override("focus", style_hover)
		
		# Interactive Song Card Button
		var song_btn = Button.new()
		var badge = "  [🎮 YARG]" if is_yarg else ""
		if s_artist != "" and s_title != "":
			song_btn.text = "  %s - %s%s" % [s_artist, s_title, badge]
		else:
			song_btn.text = "  %s%s" % [file_name, badge]
		song_btn.custom_minimum_size = Vector2(0, 44)
		song_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		song_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		song_btn.add_theme_font_override("font", custom_font)
		song_btn.add_theme_font_size_override("font_size", 16)
		
		var s_normal = StyleBoxFlat.new()
		s_normal.bg_color = Color(0.1, 0.1, 0.13, 1)
		s_normal.corner_radius_top_left = 8
		s_normal.corner_radius_top_right = 8
		s_normal.corner_radius_bottom_right = 8
		s_normal.corner_radius_bottom_left = 8
		s_normal.content_margin_left = 14
		if is_yarg:
			s_normal.border_color = Color(0.8, 0.35, 0.2, 0.5)
			s_normal.border_width_left = 1
			s_normal.border_width_top = 1
			s_normal.border_width_right = 1
			s_normal.border_width_bottom = 1
		
		var s_hover = s_normal.duplicate()
		s_hover.bg_color = Color(0.15, 0.2, 0.26, 1)
		s_hover.border_color = Color(0.4, 0.75, 1, 1)
		s_hover.border_width_left = 2
		s_hover.border_width_top = 2
		s_hover.border_width_right = 2
		s_hover.border_width_bottom = 2
		
		var s_checked = s_normal.duplicate()
		s_checked.bg_color = Color(0.1, 0.18, 0.14, 1)
		s_checked.border_color = Color(0.11, 0.85, 0.35, 0.6)
		s_checked.border_width_left = 1
		s_checked.border_width_top = 1
		s_checked.border_width_right = 1
		s_checked.border_width_bottom = 1
		
		song_btn.add_theme_stylebox_override("normal", s_normal)
		song_btn.add_theme_stylebox_override("hover", s_hover)
		song_btn.add_theme_stylebox_override("focus", s_hover)
		
		var toggle_select = func():
			var sel = not box.get_meta("is_selected", false)
			box.set_meta("is_selected", sel)
			if sel:
				box.text = "✔"
				box.add_theme_stylebox_override("normal", style_checked)
				song_btn.add_theme_stylebox_override("normal", s_checked)
			else:
				box.text = ""
				box.add_theme_stylebox_override("normal", style_empty)
				song_btn.add_theme_stylebox_override("normal", s_normal)
				
		box.pressed.connect(toggle_select)
		song_btn.pressed.connect(toggle_select)
		
		# Open Folder action button
		var edit_btn = Button.new()
		edit_btn.text = "Open Folder" if is_dir else "Open Location"
		edit_btn.custom_minimum_size = Vector2(140, 44)
		edit_btn.add_theme_font_override("font", custom_font)
		edit_btn.add_theme_font_size_override("font_size", 13)
		
		var eb_style = StyleBoxFlat.new()
		eb_style.bg_color = Color(0.14, 0.14, 0.18, 1)
		eb_style.corner_radius_top_left = 8
		eb_style.corner_radius_top_right = 8
		eb_style.corner_radius_bottom_right = 8
		eb_style.corner_radius_bottom_left = 8
		eb_style.border_color = Color(0.25, 0.28, 0.35, 1)
		eb_style.border_width_left = 1
		eb_style.border_width_top = 1
		eb_style.border_width_right = 1
		eb_style.border_width_bottom = 1
		
		var eb_hover = eb_style.duplicate()
		eb_hover.bg_color = Color(0.18, 0.22, 0.3, 1)
		eb_hover.border_color = Color(0.45, 0.65, 0.9, 1)
		
		edit_btn.add_theme_stylebox_override("normal", eb_style)
		edit_btn.add_theme_stylebox_override("hover", eb_hover)
		edit_btn.add_theme_stylebox_override("focus", eb_hover)
		
		edit_btn.pressed.connect(func():
			OS.shell_open("file://" + (full_path if is_dir else full_path.get_base_dir()).replace(" ", "%20"))
		)
		
		row.add_child(box)
		row.add_child(song_btn)
		row.add_child(edit_btn)
		library_list.add_child(row)

func _on_delete_selected():
	for child in library_list.get_children():
		var box = child.get_node_or_null("Box")
		if box and box.get_meta("is_selected", false):
			var path = box.get_meta("path")
			var is_dir = box.get_meta("is_dir", true)
			if is_dir:
				var d = DirAccess.open(path)
				if d:
					d.list_dir_begin()
					var fn = d.get_next()
					while fn != "":
						if not fn.begins_with("."):
							d.remove(fn)
						fn = d.get_next()
					var parent_dir = DirAccess.open(path.get_base_dir())
					if parent_dir:
						parent_dir.remove(path.get_file())
			else:
				var parent_dir = DirAccess.open(path.get_base_dir())
				if parent_dir:
					parent_dir.remove(path.get_file())
	_populate_library()

func _clean_text_for_matching(text: String) -> String:
	var clean = text.to_lower()
	clean = clean.replace("&", " and ").replace("+", " and ")
	var re = RegEx.new()
	re.compile("(?i)\\s*\\((.*?)\\)|\\[(.*?)\\]")
	clean = re.sub(clean, "", true)
	var re2 = RegEx.new()
	re2.compile("[^a-z0-9]")
	clean = re2.sub(clean, "", true)
	return clean

func _get_song_signature(artist: String, title: String) -> String:
	return _clean_text_for_matching(artist) + "_" + _clean_text_for_matching(title)

func _clean_song_title(title: String) -> String:
	var clean = title
	var re1 = RegEx.new()
	re1.compile("(?i)\\s*\\((feat\\.|ft\\.|with|remaster|live|from).*?\\)")
	clean = re1.sub(clean, "", true)
	var re2 = RegEx.new()
	re2.compile("(?i)\\s*-\\s*(remaster|live|single|radio edit|mono|stereo|album version|from).*")
	clean = re2.sub(clean, "", true)
	return clean.strip_edges()

func _find_installed_song(artist_names: Array, track_title: String) -> String:
	if installed_songs_map.is_empty():
		_populate_library()
	if installed_songs_map.is_empty():
		return ""
		
	var clean_title = _clean_song_title(track_title)
	var title_variants = [track_title]
	if clean_title != track_title and clean_title != "":
		title_variants.append(clean_title)
		
	var artist_variants = []
	for a in artist_names:
		if a is String and a.strip_edges() != "":
			var a_str = a.strip_edges()
			if not artist_variants.has(a_str):
				artist_variants.append(a_str)
			if a_str.to_lower().begins_with("the "):
				var without_the = a_str.substr(4).strip_edges()
				if not artist_variants.has(without_the):
					artist_variants.append(without_the)
			else:
				var with_the = "The " + a_str
				if not artist_variants.has(with_the):
					artist_variants.append(with_the)
					
	if artist_names.size() > 1:
		var joined = ", ".join(artist_names)
		if not artist_variants.has(joined):
			artist_variants.append(joined)
			
	# 1. Exact signature dictionary lookups
	for a in artist_variants:
		for t in title_variants:
			var sig = _get_song_signature(a, t)
			if installed_songs_map.has(sig):
				return installed_songs_map[sig]
				
	# 2. Resilient substring / containment lookup
	for t in title_variants:
		var t_sig = _clean_text_for_matching(t)
		if t_sig.length() < 3:
			continue
		for a in artist_variants:
			var a_sig = _clean_text_for_matching(a)
			if a_sig.length() < 2:
				continue
			var target_sig = a_sig + "_" + t_sig
			if installed_songs_map.has(target_sig):
				return installed_songs_map[target_sig]
				
			for k in installed_songs_map.keys():
				if k.ends_with("_" + t_sig):
					var k_art = k.split("_", false, 1)[0]
					if k_art == a_sig or k_art.begins_with(a_sig) or a_sig.begins_with(k_art):
						return installed_songs_map[k]
						
	return ""


func _sanitize_filename(raw_input) -> String:
	if raw_input == null:
		return "chart"
	var clean = str(raw_input).strip_edges()
	if clean == "" or clean == "<null>" or clean == "null":
		return "chart"
	var invalid_chars = ["\\", "/", ":", "*", "?", "\"", "<", ">", "|", "\n", "\r", "\t"]
	for c in invalid_chars:
		clean = clean.replace(c, "_")
	clean = clean.strip_edges()
	return clean if clean != "" else "chart"

func _process_downloaded_file(file_path: String, target_dir: String):
	var lower = file_path.to_lower()
	if lower.ends_with(".zip"):
		var reader = ZIPReader.new()
		var err = reader.open(file_path)
		if err == OK:
			var files = reader.get_files()
			for f in files:
				if f.ends_with("/"):
					DirAccess.make_dir_recursive_absolute(target_dir.path_join(f))
				else:
					var out_path = target_dir.path_join(f)
					DirAccess.make_dir_recursive_absolute(out_path.get_base_dir())
					var data = reader.read_file(f)
					var fa = FileAccess.open(out_path, FileAccess.WRITE)
					if fa:
						fa.store_buffer(data)
						fa.close()
			reader.close()
			DirAccess.remove_absolute(file_path)
		else:
			_extract_with_tar(file_path, target_dir)
	elif lower.ends_with(".7z") or lower.ends_with(".rar") or lower.ends_with(".tar.gz") or lower.ends_with(".tar"):
		_extract_with_tar(file_path, target_dir)

func _extract_with_tar(archive_path: String, dest_dir: String):
	var global_archive = ProjectSettings.globalize_path(archive_path)
	var global_dest = ProjectSettings.globalize_path(dest_dir)
	var output = []
	var exit_code = OS.execute("tar", ["-xf", global_archive, "-C", global_dest], output)
	if exit_code == 0:
		DirAccess.remove_absolute(archive_path)

# --- SPOTIFY PKCE LOGIC ---

const SPOTIFY_CLIENT_ID = "fe0e1d00301549bcbb424d972574c665"
var tcp_server = TCPServer.new()
var spotify_access_token = ""
var code_verifier = ""

func _generate_code_verifier(length: int = 64) -> String:
	var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"
	var result = ""
	for i in range(length):
		result += chars[randi() % chars.length()]
	return result

func _generate_code_challenge(verifier: String) -> String:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(verifier.to_utf8_buffer())
	var raw_hash = ctx.finish()
	var b64 = Marshalls.raw_to_base64(raw_hash)
	return b64.replace("+", "-").replace("/", "_").replace("=", "")

func _on_spotify_button_pressed():
	code_verifier = _generate_code_verifier()
	var code_challenge = _generate_code_challenge(code_verifier)
	
	var err = tcp_server.listen(8080)
	if err != OK:
		status_label.text = "Could not start local server on port 8080."
		return
		
	status_label.text = "Opening browser for Spotify login..."
	var redirect_uri = "http://127.0.0.1:8080/callback"
	var scopes = "playlist-read-private playlist-read-collaborative user-library-read"
	var url = "https://accounts.spotify.com/authorize?client_id=%s&response_type=code&redirect_uri=%s&scope=%s&code_challenge_method=S256&code_challenge=%s" % [SPOTIFY_CLIENT_ID, redirect_uri.uri_encode(), scopes.uri_encode(), code_challenge]
	OS.shell_open(url)

func _process(_delta):
	if tcp_server.is_listening() and tcp_server.is_connection_available():
		var peer = tcp_server.take_connection()
		OS.delay_msec(100)
		var req = peer.get_string(peer.get_available_bytes())
		
		var response_html = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<html><body style='background:#111;color:#fff;text-align:center;margin-top:50px;font-family:sans-serif;'><h2>Authentication Successful!</h2><p>You can close this tab and return to Azterisk Hero Companion.</p></body></html>"
		peer.put_data(response_html.to_utf8_buffer())
		peer.disconnect_from_host()
		tcp_server.stop()
		
		var code_match = RegEx.new()
		code_match.compile("code=([^&\\s]+)")
		var match = code_match.search(req)
		if match:
			var code = match.get_string(1)
			_exchange_spotify_code_pkce(code)
		else:
			status_label.text = "Failed to get auth code from Spotify."

func _save_session(refresh_token: String, access_token: String):
	var config = ConfigFile.new()
	config.set_value("session", "refresh_token", refresh_token)
	config.set_value("session", "access_token", access_token)
	config.save("user://spotify_session.cfg")

func _check_saved_session():
	var config = ConfigFile.new()
	if config.load("user://spotify_session.cfg") == OK:
		var refresh_token = config.get_value("session", "refresh_token", "")
		if refresh_token != "":
			_refresh_spotify_token(refresh_token)

func _refresh_spotify_token(refresh_token: String):
	status_label.text = "Restoring Spotify session..."
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res, code_res, _hdrs, body):
		if code_res == 200:
			var json = JSON.parse_string(body.get_string_from_utf8())
			if json and json.has("access_token"):
				spotify_access_token = json["access_token"]
				var new_refresh = json.get("refresh_token", refresh_token)
				_save_session(new_refresh, spotify_access_token)
				status_label.text = "Logged in from saved session! Fetching playlists..."
				_fetch_spotify_playlists()
		http.queue_free()
	)
	var url = "https://accounts.spotify.com/api/token"
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var payload = "client_id=%s&grant_type=refresh_token&refresh_token=%s" % [SPOTIFY_CLIENT_ID, refresh_token]
	http.request(url, headers, HTTPClient.METHOD_POST, payload)

func _exchange_spotify_code_pkce(code: String):
	status_label.text = "Exchanging token securely via PKCE..."
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res, code_res, _hdrs, body):
		if code_res == 200:
			var json = JSON.parse_string(body.get_string_from_utf8())
			spotify_access_token = json.get("access_token", "")
			var refresh_token = json.get("refresh_token", "")
			if refresh_token != "":
				_save_session(refresh_token, spotify_access_token)
			status_label.text = "Spotify Authenticated! Fetching playlists..."
			_fetch_spotify_playlists()
		else:
			status_label.text = "Failed to authenticate with Spotify."
		http.queue_free()
	)
	
	var url = "https://accounts.spotify.com/api/token"
	var headers = ["Content-Type: application/x-www-form-urlencoded"]
	var payload = "client_id=%s&grant_type=authorization_code&code=%s&redirect_uri=http://127.0.0.1:8080/callback&code_verifier=%s" % [SPOTIFY_CLIENT_ID, code, code_verifier]
	http.request(url, headers, HTTPClient.METHOD_POST, payload)

@onready var playlist_list = $MarginContainer/Panel/VBoxContainer/TabContainer/Import/VBoxContainer/ScrollContainer/PlaylistList

func _fetch_spotify_playlists():
	# Hide login controls and show logout
	spotify_btn.visible = false
	logout_btn.visible = true
	
	for child in playlist_list.get_children():
		child.queue_free()
	
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res, code_res, _hdrs, body):
		if code_res == 200:
			var json = JSON.parse_string(body.get_string_from_utf8())
			if json and json.has("items"):
				var playlists = json["items"]
				status_label.text = "Select a playlist to view its songs:"
				for p in playlists:
					var playlist_name = p.get("name", "Untitled")
					var total_count = 0
					if p.has("tracks") and p["tracks"] is Dictionary and p["tracks"].has("total"):
						total_count = int(p["tracks"]["total"])
					
					var btn = Button.new()
					if total_count > 0:
						btn.text = "  %s  (%s songs)" % [playlist_name, total_count]
					else:
						btn.text = "  %s" % playlist_name
						
					btn.custom_minimum_size = Vector2(0, 56)
					btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
					btn.add_theme_font_override("font", custom_font)
					btn.add_theme_font_size_override("font_size", 16)
					
					var style = StyleBoxFlat.new()
					style.bg_color = Color(0.12, 0.12, 0.15, 1)
					style.corner_radius_top_left = 12
					style.corner_radius_top_right = 12
					style.corner_radius_bottom_right = 12
					style.corner_radius_bottom_left = 12
					style.content_margin_left = 18
					
					var style_hover = style.duplicate()
					style_hover.bg_color = Color(0.18, 0.22, 0.28, 1)
					style_hover.border_color = Color(0.11, 0.73, 0.33, 1)
					style_hover.border_width_left = 2
					style_hover.border_width_right = 2
					style_hover.border_width_top = 2
					style_hover.border_width_bottom = 2
					
					btn.add_theme_stylebox_override("normal", style)
					btn.add_theme_stylebox_override("hover", style_hover)
					btn.add_theme_stylebox_override("focus", style_hover)
					
					var playlist_id = p.get("id", "")
					btn.pressed.connect(func():
						_view_playlist_tracks(playlist_id, playlist_name)
					)
					playlist_list.add_child(btn)
		else:
			status_label.text = "Failed to fetch playlists (Error %s)." % code_res
		http.queue_free()
	)
	var url = "https://api.spotify.com/v1/me/playlists?limit=50"
	var headers = ["Authorization: Bearer " + spotify_access_token]
	http.request(url, headers, HTTPClient.METHOD_GET)

func _view_playlist_tracks(playlist_id: String, playlist_name: String):
	status_label.text = "Loading songs from '%s'..." % playlist_name
	for child in playlist_list.get_children():
		child.queue_free()
		
	var nav_bar = HBoxContainer.new()
	nav_bar.add_theme_constant_override("separation", 16)
	
	var back_btn = Button.new()
	back_btn.text = "← Back to All Playlists"
	back_btn.add_theme_font_override("font", custom_font)
	back_btn.custom_minimum_size = Vector2(180, 42)
	back_btn.pressed.connect(_fetch_spotify_playlists)
	nav_bar.add_child(back_btn)
	
	var scan_all_btn = Button.new()
	scan_all_btn.text = "Scan All Songs in Enchor"
	scan_all_btn.add_theme_font_override("font", custom_font)
	scan_all_btn.custom_minimum_size = Vector2(210, 42)
	scan_all_btn.add_theme_color_override("font_color", Color(0.11, 0.85, 0.35, 1))
	nav_bar.add_child(scan_all_btn)

	var add_to_library_btn = Button.new()
	add_to_library_btn.text = "Add to Library (0)"
	add_to_library_btn.add_theme_font_override("font", custom_font)
	add_to_library_btn.custom_minimum_size = Vector2(200, 42)
	add_to_library_btn.disabled = true
	
	var add_style = StyleBoxFlat.new()
	add_style.bg_color = Color(0.1, 0.32, 0.16, 1)
	add_style.corner_radius_top_left = 10
	add_style.corner_radius_top_right = 10
	add_style.corner_radius_bottom_right = 10
	add_style.corner_radius_bottom_left = 10
	add_style.border_color = Color(0.11, 0.85, 0.35, 1)
	add_style.border_width_left = 2
	add_style.border_width_top = 2
	add_style.border_width_right = 2
	add_style.border_width_bottom = 2
	add_style.content_margin_left = 16
	add_style.content_margin_right = 16
	
	var add_style_hover = add_style.duplicate()
	add_style_hover.bg_color = Color(0.14, 0.44, 0.22, 1)
	add_style_hover.border_color = Color(0.2, 1.0, 0.45, 1)
	
	var add_style_disabled = add_style.duplicate()
	add_style_disabled.bg_color = Color(0.12, 0.12, 0.15, 1)
	add_style_disabled.border_color = Color(0.25, 0.25, 0.3, 1)

	add_to_library_btn.add_theme_stylebox_override("normal", add_style)
	add_to_library_btn.add_theme_stylebox_override("hover", add_style_hover)
	add_to_library_btn.add_theme_stylebox_override("focus", add_style_hover)
	add_to_library_btn.add_theme_stylebox_override("disabled", add_style_disabled)
	add_to_library_btn.add_theme_color_override("font_color", Color(0.11, 0.95, 0.4, 1))
	add_to_library_btn.add_theme_color_override("font_disabled_color", Color(0.45, 0.45, 0.5, 1))
	nav_bar.add_child(add_to_library_btn)

	playlist_list.add_child(nav_bar)
	
	var loading_lbl = Label.new()
	loading_lbl.text = "Fetching tracks from Spotify..."
	loading_lbl.add_theme_font_override("font", custom_font)
	playlist_list.add_child(loading_lbl)
	
	var clean_id = playlist_id.replace("spotify:playlist:", "").strip_edges()
	var headers = ["Authorization: Bearer " + spotify_access_token]
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(func(_res, code_res, _hdrs, body):
		if is_instance_valid(loading_lbl):
			loading_lbl.queue_free()
			
		var body_str = body.get_string_from_utf8()
		if code_res == 200:
			var json = JSON.parse_string(body_str)
			var raw_items = []
			
			if json is Dictionary:
				if json.has("items") and json["items"] is Array:
					raw_items = json["items"]
				elif json.has("tracks") and json["tracks"] is Dictionary and json["tracks"].has("items"):
					raw_items = json["tracks"]["items"]
			
			_render_playlist_songs(raw_items, playlist_name, scan_all_btn, add_to_library_btn, back_btn)
		else:
			# If /items returns 403, fallback to querying the whole playlist resource directly
			var fallback_http = HTTPRequest.new()
			add_child(fallback_http)
			fallback_http.request_completed.connect(func(_res2, code2, _hdrs2, body2):
				var b2_str = body2.get_string_from_utf8()
				if code2 == 200:
					var j2 = JSON.parse_string(b2_str)
					if j2 is Dictionary and j2.has("tracks") and j2["tracks"].has("items"):
						_render_playlist_songs(j2["tracks"]["items"], playlist_name, scan_all_btn, add_to_library_btn, back_btn)
						fallback_http.queue_free()
						return
				status_label.text = "Error fetching songs (Spotify HTTP %s)." % code_res
				var err_lbl = Label.new()
				err_lbl.text = "Failed to load tracks from Spotify (Status %s):\nNote: In Spotify Development Mode, only playlists created by your developer account can be accessed." % [code_res]
				err_lbl.add_theme_font_override("font", custom_font)
				playlist_list.add_child(err_lbl)
				fallback_http.queue_free()
			)
			fallback_http.request("https://api.spotify.com/v1/playlists/%s" % clean_id, headers, HTTPClient.METHOD_GET)
			
		http.queue_free()
	)
	var url = "https://api.spotify.com/v1/playlists/%s/items?limit=100" % clean_id
	http.request(url, headers, HTTPClient.METHOD_GET)

func _render_playlist_songs(raw_items: Array, playlist_name: String, scan_all_btn: Button, add_to_library_btn: Button, back_btn: Button):
	if raw_items.is_empty():
		status_label.text = "'%s' (0 tracks returned)" % playlist_name
		var empty_card = Label.new()
		empty_card.text = "Spotify returned 0 tracks for this playlist."
		empty_card.add_theme_font_override("font", custom_font)
		empty_card.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85, 1))
		playlist_list.add_child(empty_card)
		return
		
	var selected_charts = []
	var row_scan_callables = []
	var row_controllers = []
	status_label.text = "'%s' (%s songs found). Click any song to check for Enchor charts:" % [playlist_name, raw_items.size()]
	
	var update_add_btn = func():
		var count = selected_charts.size()
		if count == 0:
			add_to_library_btn.text = "Add to Library (0)"
			add_to_library_btn.disabled = true
		else:
			add_to_library_btn.text = "Add to Library (%d)" % count
			add_to_library_btn.disabled = false
	
	for item in raw_items:
		var track = null
		if item is Dictionary:
			if item.has("track") and item["track"] is Dictionary:
				track = item["track"]
			elif item.has("item") and item["item"] is Dictionary:
				track = item["item"]
			elif item.has("name"):
				track = item
				
		if not track or not track.has("name"):
			continue
			
		var track_title = track.get("name", "Unknown Title")
		var artists = track.get("artists", [])
		var artist_names = []
		if artists is Array:
			for a in artists:
				if a is Dictionary:
					var a_name = a.get("name", "")
					if a_name != "":
						artist_names.append(a_name)
				elif a is String and a.strip_edges() != "":
					artist_names.append(a.strip_edges())
		if artist_names.is_empty():
			if track.has("artist") and track["artist"] is String and track["artist"].strip_edges() != "":
				artist_names.append(track["artist"].strip_edges())
			elif track.has("artists") and track["artists"] is String and track["artists"].strip_edges() != "":
				artist_names.append(track["artists"].strip_edges())
				
		var artist_str = ", ".join(artist_names)

		
		# --- SONG ROW (Status Square + Song Button) ---
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		
		var box = Button.new()
		box.custom_minimum_size = Vector2(44, 44)
		box.text = ""
		box.add_theme_font_override("font", custom_font)
		box.add_theme_font_size_override("font_size", 16)
		
		# Base Styles
		var style_empty = StyleBoxFlat.new()
		style_empty.bg_color = Color(0.12, 0.12, 0.16, 1)
		style_empty.corner_radius_top_left = 8
		style_empty.corner_radius_top_right = 8
		style_empty.corner_radius_bottom_right = 8
		style_empty.corner_radius_bottom_left = 8
		style_empty.border_color = Color(0.28, 0.28, 0.35, 1)
		style_empty.border_width_left = 1
		style_empty.border_width_top = 1
		style_empty.border_width_right = 1
		style_empty.border_width_bottom = 1
		box.add_theme_stylebox_override("normal", style_empty)
		
		var style_matched = style_empty.duplicate()
		style_matched.bg_color = Color(0.08, 0.28, 0.15, 1)
		style_matched.border_color = Color(0.11, 0.85, 0.35, 1)
		style_matched.border_width_left = 2
		style_matched.border_width_top = 2
		style_matched.border_width_right = 2
		style_matched.border_width_bottom = 2
		
		var style_nomatch = style_empty.duplicate()
		style_nomatch.bg_color = Color(0.28, 0.08, 0.08, 1)
		style_nomatch.border_color = Color(0.95, 0.25, 0.25, 1)
		style_nomatch.border_width_left = 2
		style_nomatch.border_width_top = 2
		style_nomatch.border_width_right = 2
		style_nomatch.border_width_bottom = 2
		
		var style_multiple = style_empty.duplicate()
		style_multiple.bg_color = Color(0.28, 0.22, 0.06, 1)
		style_multiple.border_color = Color(0.95, 0.75, 0.15, 1)
		style_multiple.border_width_left = 2
		style_multiple.border_width_top = 2
		style_multiple.border_width_right = 2
		style_multiple.border_width_bottom = 2
		
		var installed_folder = _find_installed_song(artist_names, track_title)
		var is_installed = (installed_folder != "")
		
		var style_installed = style_empty.duplicate()
		style_installed.bg_color = Color(0.08, 0.22, 0.32, 1)
		style_installed.border_color = Color(0.2, 0.7, 0.95, 1)
		style_installed.border_width_left = 2
		style_installed.border_width_top = 2
		style_installed.border_width_right = 2
		style_installed.border_width_bottom = 2
		
		var song_btn = Button.new()
		if is_installed:
			song_btn.text = "  %s - %s   [💾 IN LIBRARY]" % [artist_str, track_title]
			box.text = "💾"
			box.add_theme_stylebox_override("normal", style_installed)
		else:
			song_btn.text = "  %s - %s" % [artist_str, track_title]
			
		song_btn.custom_minimum_size = Vector2(0, 44)
		song_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		song_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		song_btn.add_theme_font_override("font", custom_font)
		
		var s_normal = StyleBoxFlat.new()
		s_normal.bg_color = Color(0.1, 0.1, 0.13, 1)
		s_normal.corner_radius_top_left = 8
		s_normal.corner_radius_top_right = 8
		s_normal.corner_radius_bottom_right = 8
		s_normal.corner_radius_bottom_left = 8
		s_normal.content_margin_left = 14
		if is_installed:
			s_normal.border_color = Color(0.2, 0.65, 0.85, 0.5)
			s_normal.border_width_left = 1
			s_normal.border_width_top = 1
			s_normal.border_width_right = 1
			s_normal.border_width_bottom = 1
		
		var s_hover = s_normal.duplicate()
		s_hover.bg_color = Color(0.15, 0.2, 0.26, 1)
		s_hover.border_color = Color(0.4, 0.75, 1, 1)
		s_hover.border_width_left = 2
		s_hover.border_width_top = 2
		s_hover.border_width_right = 2
		s_hover.border_width_bottom = 2
		
		song_btn.add_theme_stylebox_override("normal", s_normal)
		song_btn.add_theme_stylebox_override("hover", s_hover)
		song_btn.add_theme_stylebox_override("focus", s_hover)
		
		row.add_child(box)
		row.add_child(song_btn)
		playlist_list.add_child(row)
		
		# State variables for this row
		var row_state = {
			"status": "INSTALLED" if is_installed else "EMPTY",
			"matches": [],
			"chosen_chart": null,
			"installed_folder": installed_folder,
			"is_installed": is_installed
		}
		
		var do_enchor_search = func(open_modal_on_multi: bool):
			if row_state["status"] == "MATCHED" or row_state["status"] == "LOADING":
				return
			# If this is a background/batch scan and song is already installed, skip fetching to preserve UI and rate limits
			if not open_modal_on_multi and row_state["is_installed"]:
				row_state["status"] = "INSTALLED"
				box.text = "💾"
				box.add_theme_stylebox_override("normal", style_installed)
				song_btn.text = "  %s - %s   [💾 IN LIBRARY]" % [artist_str, track_title]
				return
				
			row_state["status"] = "LOADING"
			box.text = "⏳"
			status_label.text = "Checking Enchor for '%s'..." % track_title
			
			var clean_title = _clean_song_title(track_title)
			var queries_to_try = [track_title + " " + artist_str]
			if clean_title != track_title and clean_title.length() > 0:
				queries_to_try.append(clean_title + " " + artist_str)
			
			var found_charts = []
			var search_successful = false
			
			for query in queries_to_try:
				if row_state["status"] != "LOADING":
					return
				
				for attempt in range(3):
					if row_state["status"] != "LOADING":
						return
						
					var http_search = HTTPRequest.new()
					add_child(http_search)
					var payload = JSON.stringify({"search": query, "page": 1})
					var s_headers = ["Content-Type: application/json", "User-Agent: CloneHeroCompanion/1.0"]
					http_search.request("https://api.enchor.us/search", s_headers, HTTPClient.METHOD_POST, payload)
					
					var res = await http_search.request_completed
					http_search.queue_free()
					
					if row_state["status"] != "LOADING":
						return
						
					var code = res[1]
					if code == 200 or code == 201:
						search_successful = true
						var j = JSON.parse_string(res[3].get_string_from_utf8())
						if j is Dictionary and j.has("data") and j["data"] is Array:
							found_charts = j["data"]
						break
					elif code == 503 or code == 429:
						# Server busy or rate limited, back off and retry
						status_label.text = "Enchor busy, retrying '%s'..." % track_title
						await get_tree().create_timer(0.6 * (attempt + 1)).timeout
					else:
						# Other network error
						break
				
				if not found_charts.is_empty():
					break
			
			if row_state["status"] != "LOADING":
				return
				
			if not search_successful:
				# Network or server rate limit failure after retries
				if row_state["is_installed"]:
					row_state["status"] = "INSTALLED"
					box.text = "💾"
					box.add_theme_stylebox_override("normal", style_installed)
					song_btn.text = "  %s - %s   [💾 IN LIBRARY]" % [artist_str, track_title]
				else:
					row_state["status"] = "EMPTY"
					box.text = ""
					box.add_theme_stylebox_override("normal", style_empty)
				status_label.text = "Network error checking '%s'. Click to retry." % track_title
				return
				
			row_state["matches"] = found_charts
			
			# Cross-reference Enchor search matches against local library
			if not row_state["is_installed"] and not found_charts.is_empty():
				for fc in found_charts:
					if fc is Dictionary:
						var fc_art = str(fc.get("artist", "")).strip_edges()
						var fc_name = str(fc.get("name", "")).strip_edges()
						if fc_art != "" and fc_name != "":
							var match_inst = _find_installed_song([fc_art], fc_name)
							if match_inst != "":
								row_state["is_installed"] = true
								row_state["installed_folder"] = match_inst
								break
			
			# If the track is installed, ALWAYS keep it marked as INSTALLED and in library
			if row_state["is_installed"]:
				row_state["status"] = "INSTALLED"
				box.text = "💾"
				box.add_theme_stylebox_override("normal", style_installed)
				song_btn.text = "  %s - %s   [💾 IN LIBRARY]" % [artist_str, track_title]
				if open_modal_on_multi:
					_open_preferred_chart_modal(track_title, artist_str, found_charts, func(picked):
						if row_state["chosen_chart"] != null and selected_charts.has(row_state["chosen_chart"]):
							selected_charts.erase(row_state["chosen_chart"])
						row_state["chosen_chart"] = picked
						row_state["status"] = "MATCHED"
						box.text = "✔"
						box.add_theme_stylebox_override("normal", style_matched)
						selected_charts.append(picked)
						update_add_btn.call()
						var picked_charter = picked.get("charter", "")
						song_btn.text = "  %s - %s   [✔ %s]" % [artist_str, track_title, picked_charter] if picked_charter != "" else "  %s - %s   [✔ Selected]" % [artist_str, track_title]
					)
				else:
					status_label.text = "'%s' is in your library (%d charts on Enchor)." % [track_title, found_charts.size()]
				return
				
			# Logic for uninstalled tracks
			if found_charts.is_empty():
				row_state["status"] = "NO_MATCH"
				box.text = "✖"
				box.add_theme_stylebox_override("normal", style_nomatch)
				status_label.text = "No charts found on Enchor for '%s'." % track_title
			elif found_charts.size() == 1:
				row_state["status"] = "MATCHED"
				row_state["chosen_chart"] = found_charts[0]
				box.text = "✔"
				box.add_theme_stylebox_override("normal", style_matched)
				selected_charts.append(found_charts[0])
				update_add_btn.call()
				var charter_name = found_charts[0].get("charter", "")
				song_btn.text = "  %s - %s   [✔ %s]" % [artist_str, track_title, charter_name] if charter_name != "" else "  %s - %s   [✔ Selected]" % [artist_str, track_title]
				status_label.text = "Matched 1 chart for '%s'!" % track_title
			else:
				row_state["status"] = "MULTIPLE"
				box.text = "❓"
				box.add_theme_stylebox_override("normal", style_multiple)
				status_label.text = "Found %s matches for '%s'." % [found_charts.size(), track_title]
				if open_modal_on_multi:
					_open_preferred_chart_modal(track_title, artist_str, found_charts, func(picked):
						if row_state["chosen_chart"] != null and selected_charts.has(row_state["chosen_chart"]):
							selected_charts.erase(row_state["chosen_chart"])
						row_state["chosen_chart"] = picked
						row_state["status"] = "MATCHED"
						box.text = "✔"
						box.add_theme_stylebox_override("normal", style_matched)
						selected_charts.append(picked)
						update_add_btn.call()
						var picked_charter = picked.get("charter", "")
						song_btn.text = "  %s - %s   [✔ %s]" % [artist_str, track_title, picked_charter] if picked_charter != "" else "  %s - %s   [✔ Selected]" % [artist_str, track_title]
					)


		var reset_to_deselected = func():
			if row_state["status"] == "EMPTY":
				return
			if row_state["chosen_chart"] != null and selected_charts.has(row_state["chosen_chart"]):
				selected_charts.erase(row_state["chosen_chart"])
			row_state["chosen_chart"] = null
			if row_state["is_installed"]:
				row_state["status"] = "INSTALLED"
				box.text = "💾"
				box.add_theme_stylebox_override("normal", style_installed)
				song_btn.text = "  %s - %s   [💾 IN LIBRARY]" % [artist_str, track_title]
			else:
				row_state["status"] = "EMPTY"
				box.text = ""
				box.add_theme_stylebox_override("normal", style_empty)
				song_btn.text = "  %s - %s" % [artist_str, track_title]
			update_add_btn.call()

		var handle_gui_input = func(event: InputEvent):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				reset_to_deselected.call()

		var handle_row_click = func():
			if row_state["status"] == "MATCHED":
				# Uncheck back to empty
				reset_to_deselected.call()
			elif row_state["status"] == "MULTIPLE":
				# Re-open picker modal for multiple choices
				_open_preferred_chart_modal(track_title, artist_str, row_state["matches"], func(picked):
					if row_state["chosen_chart"] != null and selected_charts.has(row_state["chosen_chart"]):
						selected_charts.erase(row_state["chosen_chart"])
					row_state["chosen_chart"] = picked
					row_state["status"] = "MATCHED"
					box.text = "✔"
					box.add_theme_stylebox_override("normal", style_matched)
					selected_charts.append(picked)
					update_add_btn.call()
					var picked_charter = picked.get("charter", "")
					song_btn.text = "  %s - %s   [✔ %s]" % [artist_str, track_title, picked_charter] if picked_charter != "" else "  %s - %s   [✔ Selected]" % [artist_str, track_title]
				)
			elif row_state["status"] == "NO_MATCH":
				# Reset to empty on click
				reset_to_deselected.call()
			elif row_state["status"] == "INSTALLED":
				if not row_state["matches"].is_empty():
					_open_preferred_chart_modal(track_title, artist_str, row_state["matches"], func(picked):
						if row_state["chosen_chart"] != null and selected_charts.has(row_state["chosen_chart"]):
							selected_charts.erase(row_state["chosen_chart"])
						row_state["chosen_chart"] = picked
						row_state["status"] = "MATCHED"
						box.text = "✔"
						box.add_theme_stylebox_override("normal", style_matched)
						selected_charts.append(picked)
						update_add_btn.call()
						var picked_charter = picked.get("charter", "")
						song_btn.text = "  %s - %s   [✔ %s]" % [artist_str, track_title, picked_charter] if picked_charter != "" else "  %s - %s   [✔ Selected]" % [artist_str, track_title]
					)
				else:
					status_label.text = "Checking Enchor for versions of '%s'..." % track_title
					do_enchor_search.call(true)
			elif row_state["status"] == "EMPTY":
				if not row_state["matches"].is_empty():
					if row_state["matches"].size() == 1:
						row_state["status"] = "MATCHED"
						row_state["chosen_chart"] = row_state["matches"][0]
						box.text = "✔"
						box.add_theme_stylebox_override("normal", style_matched)
						selected_charts.append(row_state["chosen_chart"])
						update_add_btn.call()
					else:
						_open_preferred_chart_modal(track_title, artist_str, row_state["matches"], func(picked):
							if row_state["chosen_chart"] != null and selected_charts.has(row_state["chosen_chart"]):
								selected_charts.erase(row_state["chosen_chart"])
							row_state["chosen_chart"] = picked
							row_state["status"] = "MATCHED"
							box.text = "✔"
							box.add_theme_stylebox_override("normal", style_matched)
							selected_charts.append(picked)
							update_add_btn.call()
							var picked_charter = picked.get("charter", "")
							song_btn.text = "  %s - %s   [✔ %s]" % [artist_str, track_title, picked_charter] if picked_charter != "" else "  %s - %s   [✔ Selected]" % [artist_str, track_title]
						)
				else:
					do_enchor_search.call(true)
		
		box.pressed.connect(handle_row_click)
		song_btn.pressed.connect(handle_row_click)
		box.gui_input.connect(handle_gui_input)
		song_btn.gui_input.connect(handle_gui_input)
		row_scan_callables.append(func():
			if row_state["is_installed"] or row_state["status"] == "INSTALLED":
				return
			await do_enchor_search.call(false)
		)
		row_controllers.append({
			"row_state": row_state,
			"box": box,
			"song_btn": song_btn,
			"artist_str": artist_str,
			"track_title": track_title,
			"style_installed": style_installed
		})

	
	scan_all_btn.pressed.connect(func():
		scan_all_btn.disabled = true
		var total_scan = row_scan_callables.size()
		var cur_idx = 0
		for fn in row_scan_callables:
			cur_idx += 1
			scan_all_btn.text = "Scanning (%d/%d)..." % [cur_idx, total_scan]
			await fn.call()
			await get_tree().create_timer(0.2).timeout
		scan_all_btn.text = "Scan Complete"
		await get_tree().create_timer(2.0).timeout
		scan_all_btn.text = "Scan All Songs in Enchor"
		scan_all_btn.disabled = false
	)
	
	add_to_library_btn.pressed.connect(func():
		if selected_charts.is_empty():
			return
			
		if base_ch_path == "" or not DirAccess.dir_exists_absolute(base_ch_path):
			_find_song_directories()
			if base_ch_path == "" or not DirAccess.dir_exists_absolute(base_ch_path):
				status_label.text = "Songs folder not found! Please check Clone Hero installation."
				return
				
		add_to_library_btn.disabled = true
		back_btn.disabled = true
		scan_all_btn.disabled = true
		
		var total = selected_charts.size()
		var downloaded = 0
		var charts_to_process = selected_charts.duplicate()
		
		for i in range(total):
			var chart = charts_to_process[i]
			if not (chart is Dictionary):
				continue
			var artist = str(chart.get("artist", "Unknown")).strip_edges()
			var s_name = str(chart.get("name", "Unknown")).strip_edges()
			if artist == "" or artist == "null": artist = "Unknown"
			if s_name == "" or s_name == "null": s_name = "Unknown"
			
			status_label.text = "Downloading (%d/%d): %s - %s..." % [i + 1, total, artist, s_name]
			add_to_library_btn.text = "Adding (%d/%d)..." % [i + 1, total]
			
			var success = await _download_single_chart(chart)
			if success:
				downloaded += 1
			else:
				status_label.text = "Download failed for %s - %s" % [artist, s_name]
				await get_tree().create_timer(0.5).timeout

				
		status_label.text = "Successfully added %d songs to your Clone Hero library!" % downloaded
		add_to_library_btn.text = "Added (%d)!" % downloaded
		_populate_library()
		
		# Update playlist rows that were successfully added so they show as [💾 IN LIBRARY]
		for ctrl in row_controllers:
			if ctrl["row_state"]["chosen_chart"] != null and charts_to_process.has(ctrl["row_state"]["chosen_chart"]):
				ctrl["row_state"]["status"] = "INSTALLED"
				ctrl["row_state"]["chosen_chart"] = null
				ctrl["box"].text = "💾"
				ctrl["box"].add_theme_stylebox_override("normal", ctrl["style_installed"])
				ctrl["song_btn"].text = "  %s - %s   [💾 IN LIBRARY]" % [ctrl["artist_str"], ctrl["track_title"]]
		selected_charts.clear()
		
		await get_tree().create_timer(2.0).timeout
		add_to_library_btn.disabled = false
		back_btn.disabled = false
		scan_all_btn.disabled = false
		update_add_btn.call()
	)

func _format_difficulty_rating(chart: Dictionary) -> String:
	var diff_val = chart.get("diff_guitar")
	var diff = int(diff_val) if (diff_val != null and (diff_val is int or diff_val is float)) else -1
	var ghl_val = chart.get("diff_guitarghl")
	var ghl = int(ghl_val) if (ghl_val != null and (ghl_val is int or ghl_val is float)) else -1
	
	if diff < 0 and ghl >= 0:
		return "6-Fret GHL (Tier %d)" % ghl
	elif diff < 0:
		return "No Lead Guitar"
	elif diff == 0:
		return "★☆☆☆☆ (Warmup)"
	elif diff == 1:
		return "★★☆☆☆ (Apprentice)"
	elif diff == 2:
		return "★★★☆☆ (Solid)"
	elif diff == 3:
		return "★★★★☆ (Moderate)"
	elif diff == 4:
		return "★★★★★ (Challenging)"
	elif diff == 5:
		return "★★★★★+ (Nightmare)"
	else:
		return "😈 DEVIL TIER"

func _open_preferred_chart_modal(track_title: String, artist_str: String, matches: Array, on_selected: Callable):
	var installed_folder = _find_installed_song([artist_str], track_title)
	if installed_folder != "":
		modal_title.text = "%s - %s   (💾 In Library)" % [artist_str, track_title]
		modal_subtitle.text = "You currently have a version in your library (%s). You can select a different version below to download it anyway:" % installed_folder
	else:
		modal_title.text = "%s - %s" % [artist_str, track_title]
		modal_subtitle.text = "Select your preferred chart version to link:"
		
	for child in modal_option_list.get_children():
		child.queue_free()
		
	# Sort matches: Official releases & Custom Songs Central & top ranked at top
	matches.sort_custom(func(a, b):
		var a_c_val = a.get("charter")
		var a_charter = (a_c_val if a_c_val is String else "").to_lower()
		var b_c_val = b.get("charter")
		var b_charter = (b_c_val if b_c_val is String else "").to_lower()
		var official_list = ["harmonix", "neversoft", "redoctane", "activision", "vicarious visions"]
		var a_off = official_list.any(func(x): return a_charter.contains(x))
		var b_off = official_list.any(func(x): return b_charter.contains(x))
		if a_off != b_off:
			return a_off
			
		var a_p_val = a.get("packName")
		var a_pack = (a_p_val if a_p_val is String else "").to_lower()
		var b_p_val = b.get("packName")
		var b_pack = (b_p_val if b_p_val is String else "").to_lower()
		var a_csc = a_pack.contains("custom songs central")
		var b_csc = b_pack.contains("custom songs central")
		if a_csc != b_csc:
			return a_csc
			
		var a_ord = int(a.get("ordering", 999))
		var b_ord = int(b.get("ordering", 999))
		return a_ord < b_ord
	)
	
	for i in range(matches.size()):
		var chart = matches[i]
		var c_val = chart.get("charter")
		var charter = (c_val if c_val is String and c_val != "" else "Unknown")
		var diff_stars = _format_difficulty_rating(chart)
		var total_sec = int(chart.get("song_length", 0) / 1000)
		var length_str = "%d:%02d" % [int(total_sec / 60.0), total_sec % 60]
		var p_val = chart.get("packName")
		var pack_name = (p_val if p_val is String else "")
		var ordering = int(chart.get("ordering", 999))
		
		var charter_lower = charter.to_lower()
		var is_official = ["harmonix", "neversoft", "redoctane", "activision", "vicarious visions"].any(func(x): return charter_lower.contains(x))
		var is_top_popular = (ordering == 1)
		var is_csc = (pack_name != "" and pack_name.to_lower().contains("custom songs central"))
		var is_currently_installed = (installed_folder != "" and installed_folder.to_lower().contains(charter_lower))
		
		var nd_val = chart.get("notesData")
		var nd: Dictionary = nd_val if nd_val is Dictionary else {}
		var insts_val = nd.get("instruments")
		var insts: Array = insts_val if insts_val is Array else []
		
		# Instrument string
		var inst_icons = []
		if insts.has("guitar"): inst_icons.append("🎸 Lead")
		if insts.has("bass"): inst_icons.append("🎸 Bass")
		if insts.has("drums"): inst_icons.append("🥁 Drums")
		if insts.has("vocals"): inst_icons.append("🎤 Vocals")
		if insts.has("keys"): inst_icons.append("🎹 Keys")
		var inst_str = "  ".join(inst_icons) if not inst_icons.is_empty() else "🎸 Lead Guitar"
		
		# Difficulties
		var nc_val = nd.get("noteCounts")
		var note_counts: Array = nc_val if nc_val is Array else []
		var guitar_diffs = []
		var expert_notes = 0
		for nc in note_counts:
			if nc is Dictionary and nc.get("instrument") == "guitar":
				var d_name = nc.get("difficulty")
				if d_name is String:
					guitar_diffs.append(d_name)
				if d_name == "expert":
					expert_notes = int(nc.get("count", 0))
					
		var diff_summary = ""
		if guitar_diffs.has("easy") and guitar_diffs.has("medium") and guitar_diffs.has("hard") and guitar_diffs.has("expert"):
			diff_summary = "Full Diffs (E/M/H/X)"
		elif guitar_diffs.has("expert") and guitar_diffs.size() == 1:
			diff_summary = "Expert Only"
		elif not guitar_diffs.is_empty():
			diff_summary = "/".join(guitar_diffs)
		else:
			diff_summary = "Standard"
			
		# Features
		var feature_tags = []
		if bool(chart.get("hasVideoBackground", false)) or bool(nd.get("hasVideoBackground", false)):
			feature_tags.append("📹 Video")
		if bool(nd.get("hasLyrics", false)) or bool(nd.get("hasVocals", false)):
			feature_tags.append("🎤 Lyrics")
		if bool(nd.get("hasTapNotes", false)):
			feature_tags.append("⚡ Taps")
		if bool(nd.get("hasOpenNotes", false)):
			feature_tags.append("🟣 Opens")
		var features_str = "  ".join(feature_tags)

		var opt_btn = Button.new()
		opt_btn.custom_minimum_size = Vector2(0, 72)
		opt_btn.add_theme_font_override("font", custom_font)
		
		var st = StyleBoxFlat.new()
		st.bg_color = Color(0.13, 0.13, 0.17, 1)
		st.corner_radius_top_left = 10
		st.corner_radius_top_right = 10
		st.corner_radius_bottom_right = 10
		st.corner_radius_bottom_left = 10
		st.content_margin_left = 16
		st.content_margin_right = 16
		st.content_margin_top = 8
		st.content_margin_bottom = 8
		
		var st_h = st.duplicate()
		st_h.bg_color = Color(0.18, 0.24, 0.32, 1)
		st_h.border_color = Color(0.11, 0.85, 0.35, 1)
		st_h.border_width_left = 2
		st_h.border_width_top = 2
		st_h.border_width_right = 2
		st_h.border_width_bottom = 2
		
		if is_currently_installed:
			st.border_color = Color(0.2, 0.7, 0.9, 1)
			st.border_width_left = 2
			st.border_width_top = 2
			st.border_width_right = 2
			st.border_width_bottom = 2
		elif is_official:
			st.border_color = Color(0.2, 0.6, 1.0, 0.6)
			st.border_width_left = 1
			st.border_width_top = 1
			st.border_width_right = 1
			st.border_width_bottom = 1
		elif is_top_popular:
			st.border_color = Color(1.0, 0.75, 0.2, 0.6)
			st.border_width_left = 1
			st.border_width_top = 1
			st.border_width_right = 1
			st.border_width_bottom = 1
			
		opt_btn.add_theme_stylebox_override("normal", st)
		opt_btn.add_theme_stylebox_override("hover", st_h)
		opt_btn.add_theme_stylebox_override("focus", st_h)
		
		var vbox = VBoxContainer.new()
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_theme_constant_override("separation", 6)
		
		# Row 1: Header (Charter, Badges, Difficulty, Duration)
		var row1 = HBoxContainer.new()
		row1.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row1.add_theme_constant_override("separation", 10)
		
		var charter_lbl = Label.new()
		charter_lbl.text = charter
		charter_lbl.add_theme_font_override("font", custom_font)
		charter_lbl.add_theme_font_size_override("font_size", 16)
		charter_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row1.add_child(charter_lbl)
		
		if is_currently_installed:
			var b = Label.new()
			b.text = "[💾 CURRENT VERSION]"
			b.add_theme_font_override("font", custom_font)
			b.add_theme_font_size_override("font_size", 13)
			b.add_theme_color_override("font_color", Color(0.2, 0.9, 0.6, 1))
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row1.add_child(b)
		elif is_official:
			var b = Label.new()
			b.text = "[⭐ OFFICIAL RELEASE]"
			b.add_theme_font_override("font", custom_font)
			b.add_theme_font_size_override("font_size", 13)
			b.add_theme_color_override("font_color", Color(0.3, 0.85, 1.0, 1))
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row1.add_child(b)
		elif is_csc:
			var b = Label.new()
			b.text = "[🏆 CUSTOM SONGS CENTRAL]"
			b.add_theme_font_override("font", custom_font)
			b.add_theme_font_size_override("font_size", 13)
			b.add_theme_color_override("font_color", Color(0.85, 0.65, 1.0, 1))
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row1.add_child(b)
		elif is_top_popular:
			var b = Label.new()
			b.text = "[🔥 #1 ON ENCHOR]"
			b.add_theme_font_override("font", custom_font)
			b.add_theme_font_size_override("font_size", 13)
			b.add_theme_color_override("font_color", Color(1.0, 0.78, 0.25, 1))
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row1.add_child(b)
		elif pack_name != "" and pack_name != "None":
			var b = Label.new()
			b.text = "[📦 %s]" % pack_name
			b.add_theme_font_override("font", custom_font)
			b.add_theme_font_size_override("font_size", 13)
			b.add_theme_color_override("font_color", Color(0.7, 0.75, 0.9, 1))
			b.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row1.add_child(b)
			
		var spacer = Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row1.add_child(spacer)
		
		var diff_lbl = Label.new()
		diff_lbl.text = diff_stars
		diff_lbl.add_theme_font_override("font", custom_font)
		diff_lbl.add_theme_font_size_override("font_size", 14)
		diff_lbl.add_theme_color_override("font_color", Color(1.0, 0.88, 0.45, 1))
		diff_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row1.add_child(diff_lbl)
		
		var len_lbl = Label.new()
		len_lbl.text = length_str
		len_lbl.add_theme_font_override("font", custom_font)
		len_lbl.add_theme_font_size_override("font_size", 14)
		len_lbl.add_theme_color_override("font_color", Color(0.75, 0.8, 0.88, 1))
		len_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row1.add_child(len_lbl)
		
		vbox.add_child(row1)
		
		# Row 2: Details (Instruments, Difficulty spread, Notes, Features)
		var row2 = HBoxContainer.new()
		row2.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row2.add_theme_constant_override("separation", 10)
		
		var inst_lbl = Label.new()
		inst_lbl.text = inst_str
		inst_lbl.add_theme_font_override("font", custom_font)
		inst_lbl.add_theme_font_size_override("font_size", 13)
		inst_lbl.add_theme_color_override("font_color", Color(0.35, 0.85, 0.7, 1))
		inst_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row2.add_child(inst_lbl)
		
		var dot1 = Label.new()
		dot1.text = "•"
		dot1.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5, 1))
		dot1.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row2.add_child(dot1)
		
		var diff_sum_lbl = Label.new()
		diff_sum_lbl.text = diff_summary
		diff_sum_lbl.add_theme_font_override("font", custom_font)
		diff_sum_lbl.add_theme_font_size_override("font_size", 13)
		if diff_summary.begins_with("Full"):
			diff_sum_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5, 1))
		else:
			diff_sum_lbl.add_theme_color_override("font_color", Color(0.9, 0.75, 0.4, 1))
		diff_sum_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row2.add_child(diff_sum_lbl)
		
		if expert_notes > 0:
			var dot2 = Label.new()
			dot2.text = "•"
			dot2.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5, 1))
			dot2.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row2.add_child(dot2)
			
			var notes_lbl = Label.new()
			notes_lbl.text = "%s notes" % expert_notes
			notes_lbl.add_theme_font_override("font", custom_font)
			notes_lbl.add_theme_font_size_override("font_size", 13)
			notes_lbl.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85, 1))
			notes_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row2.add_child(notes_lbl)
			
		if features_str != "":
			var dot3 = Label.new()
			dot3.text = "•"
			dot3.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5, 1))
			dot3.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row2.add_child(dot3)
			
			var feat_lbl = Label.new()
			feat_lbl.text = features_str
			feat_lbl.add_theme_font_override("font", custom_font)
			feat_lbl.add_theme_font_size_override("font_size", 13)
			feat_lbl.add_theme_color_override("font_color", Color(0.8, 0.7, 0.95, 1))
			feat_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			row2.add_child(feat_lbl)
			
		vbox.add_child(row2)
		
		var card_margin = MarginContainer.new()
		card_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		card_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_margin.add_theme_constant_override("margin_left", 16)
		card_margin.add_theme_constant_override("margin_right", 16)
		card_margin.add_theme_constant_override("margin_top", 10)
		card_margin.add_theme_constant_override("margin_bottom", 10)
		card_margin.add_child(vbox)
		opt_btn.add_child(card_margin)
		
		opt_btn.pressed.connect(func():
			picker_modal.visible = false
			on_selected.call(chart)
		)
		modal_option_list.add_child(opt_btn)
		
	picker_modal.visible = true

func _on_logout_pressed():
	spotify_access_token = ""
	var dir = DirAccess.open("user://")
	if dir and dir.file_exists("spotify_session.cfg"):
		dir.remove("spotify_session.cfg")
		
	for child in playlist_list.get_children():
		child.queue_free()
	
	logout_btn.visible = false
	spotify_btn.visible = true
		
	status_label.text = "Logged out successfully."
