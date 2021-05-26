-- Table used for skinning cartographer's look and feel
return {
    -- The textures to use in maps for the sides of tiles
    cliff_textures = {
        "cartographer_simple_cliff",
        "cartographer_cliff",
    };

    -- The textures to use in maps for uncovered/unknown tiles
    unknown_biome_textures = {
        "cartographer_unknown_biome",
    };

    -- The animated texture data to use for the player icon
    player_icons = {
        {
            frame_count = 2,
            frame_duration = 500,
            texture = "cartographer_simple_player_icon",
        },
        {
            frame_count = 2,
            frame_duration = 500,
            texture = "cartographer_player_icon",
        },
    },

    -- The skinning data for the cartographer's tables
    table_skins = {
        simple_table = {
            node_mesh = "cartographer_simple_table.obj",
            node_texture = "cartographer_simple_table.png",

            background = {
                texture = "cartographer_simple_table_bg",
                radius = 16,
            },
            inner_background = {
                texture = "cartographer_simple_table_bg_2",
                radius = 4,
            },
            button = {
                font_color = "#694a3a",
                disabled_font_color = "#606060",
                texture = "cartographer_simple_table_button",
                selected_texture = "cartographer_simple_table_button_pressed",
                hovered_texture = "cartographer_simple_table_button_hovered",
                pressed_texture = "cartographer_simple_table_button_pressed",
                radius = 8,
            },
            slot = {
                texture = "cartographer_simple_table_slot",
                radius = 8,
            },
            separator = {
                texture = "cartographer_simple_table_separator",
                radius = "9,1",
            },
            label = {
                font_color = "#694a3a",
                texture = "cartographer_simple_table_slot",
                radius = 8,
            },
            tab = {
                font_color = "#694a3a",
                texture = "cartographer_simple_table_tab",
                selected_texture = "cartographer_simple_table_tab_selected",
                hovered_texture = "cartographer_simple_table_tab_hovered",
                pressed_texture = "cartographer_simple_table_tab_hovered",
                radius = 10,
            },
            paper_texture = "cartographer_paper";
            pigment_texture = "cartographer_pigment";
        },
        standard_table = {
            node_mesh = "cartographer_standard_table.obj",
            node_texture = "cartographer_standard_table.png",
            background = {
                texture = "cartographer_standard_table_bg",
                radius = 16,
            },
            inner_background = {
                texture = "cartographer_standard_table_bg_2",
                radius = 4,
            },
            button = {
                font_color = "#694a3a",
                disabled_font_color = "#606060",
                texture = "cartographer_simple_table_button",
                selected_texture = "cartographer_simple_table_button_pressed",
                hovered_texture = "cartographer_simple_table_button_hovered",
                pressed_texture = "cartographer_simple_table_button_pressed",
                radius = 8,
            },
            slot = {
                texture = "cartographer_standard_table_slot",
                radius = 8,
            },
            separator = {
                texture = "cartographer_standard_table_separator",
                radius = "9,1",
            },
            label = {
                font_color = "#694a3a",
                texture = "cartographer_standard_table_slot",
                radius = 8,
            },
            tab = {
                font_color = "#694a3a",
                texture = "cartographer_standard_table_tab",
                selected_texture = "cartographer_standard_table_tab_selected",
                hovered_texture = "cartographer_standard_table_tab_hovered",
                pressed_texture = "cartographer_standard_table_tab_hovered",
                radius = 10,
            },
            paper_texture = "cartographer_paper";
            pigment_texture = "cartographer_pigment";
        },
        advanced_table = {
            node_mesh = "cartographer_advanced_table.obj",
            node_texture = "cartographer_advanced_table.png",
            background = {
                texture = "cartographer_advanced_table_bg",
                radius = 16,
            },
            inner_background = {
                texture = "cartographer_advanced_table_bg_2",
                radius = 2,
            },
            button = {
                font_color = "#1f2533",
                disabled_font_color = "#606060",
                texture = "cartographer_advanced_table_button",
                selected_texture = "cartographer_advanced_table_button_pressed",
                hovered_texture = "cartographer_advanced_table_button_hovered",
                pressed_texture = "cartographer_advanced_table_button_pressed",
                radius = 8,
            },
            slot = {
                texture = "cartographer_advanced_table_slot",
                radius = 8,
            },
            separator = {
                texture = "cartographer_advanced_table_separator",
                radius = "9,1",
            },
            label = {
                font_color = "#1f2533",
                texture = "cartographer_advanced_table_slot",
                radius = 8,
            },
            tab = {
                font_color = "#1f2533",
                texture = "cartographer_advanced_table_tab",
                selected_texture = "cartographer_advanced_table_tab_selected",
                hovered_texture = "cartographer_advanced_table_tab_hovered",
                pressed_texture = "cartographer_advanced_table_tab_hovered",
                radius = 10,
            },
            paper_texture = "cartographer_paper";
            pigment_texture = "cartographer_pigment";
        },
    },

    -- The skinning data for the marker editor's background
    marker_bg = {
        texture = "cartographer_markers_bg",
        radius = 6,
    },

    -- The skinning data for the marker editor's buttons
    marker_button = {
        font_color = "#694a3a",
        texture = "cartographer_simple_table_button",
        selected_texture = "cartographer_simple_table_button_pressed",
        hovered_texture = "cartographer_simple_table_button_hovered",
        pressed_texture = "cartographer_simple_table_button_pressed",
        radius = 8,
    },

    -- The texture of the height toggle button when active
    height_button_texture = "cartographer_height_button",

    -- The texture of the height toggle button when inactive
    flat_button_texture = "cartographer_flat_button",
};
