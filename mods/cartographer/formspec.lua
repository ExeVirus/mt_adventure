-- Gui API (Internal)
--
-- Contains functions for building formspec-based uis
local gui = {
};

-- Create a formspec
--
-- w: The width of the window
-- h: The height of the window
-- (Optional) version: The formspec version. Defaults to 3.
-- (Optional) bg: A 9-slice background skin object
-- Additional arguments are added as additional formspec elements
--
-- Returns a table. Calling table.concat on the result will produce
-- a usable formspec string.
function gui.formspec(args)
    local data = string.format("formspec_version[%d] size[%f,%f] no_prepend[] bgcolor[#00000000;false]",
                               args.version or 3,
                               args.w, args.h);

    if args.bg then
        data = data .. gui.bg9 {
            skin = args.bg,
            fullsize = true,
        };
    end

    for _,element in ipairs(args) do
        data = data .. element;
    end

    return data;
end

-- Create an animated image formspec element
--
-- animation: An animation skin object
-- (Optional) x: The x position of the element. Defaults to 0.
-- (Optional) y: The y position of the element. Defaults to 0.
-- (Optional) w: The width of the element. Defaults to 1.
-- (Optional) h: The height of the element. Defaults to 1.
-- (Optional) size: Multiplies the width and height. Defaults to 1.
-- (Optional) id: The element id
--
-- Returns a formspec string
function gui.animated_image(args)
    local x = args.x or 0;
    local y = args.y or 0;
    local w = args.w or 1 * (args.size or 1);
    local h = args.h or 1 * (args.size or 1);

    return string.format("animated_image[%f,%f;%f,%f;%s;%s;%d;%d]",
                         x, y,
                         w, h,
                         args.id or "",
                         args.animation.texture .. ".png",
                         args.animation.frame_count,
                         args.animation.frame_duration);
end

-- Create a 9-slice background formspec element
--
-- skin: A 9-slice background skin object
-- (Optional) x: The x position of the element. Defaults to 0.
-- (Optional) y: The y position of the element. Defaults to 0.
-- (Optional) w: The width of the element. Defaults to 1.
-- (Optional) h: The height of the element. Defaults to 1.
-- (Optional) size: Multiplies the width and height. Defaults to 1.
-- (Optional) fullsize: Whether or not to fill the parent formspec. Defaults to false.
--
-- Returns a formspec string
function gui.bg9(args)
    local x = args.x or 0;
    local y = args.y or 0;
    local w = args.w or 1 * (args.size or 1);
    local h = args.h or 1 * (args.size or 1);

    return string.format("background9[%f,%f;%f,%f;%s;%s;%s]",
                          x, y,
                          w, h,
                          args.skin.texture .. ".png",
                          args.fullsize or false,
                          tostring(args.skin.radius));
end

-- Create a button formspec element
--
-- (Optional) text: The text to display on the button
-- (Optional) x: The x position of the element. Defaults to 0.
-- (Optional) y: The y position of the element. Defaults to 0.
-- (Optional) w: The width of the element. Defaults to 1.
-- (Optional) h: The height of the element. Defaults to 1.
-- (Optional) size: Multiplies the width and height. Defaults to 1.
-- (Optional) id: The element id
-- (Optional) tooltip: The tooltip to display when hovering this element.
-- (Optional) disabled: Replaces the id with "disabled_button", allowing it to
--                      receive a specific style
--
-- Returns a formspec string
function gui.button(args)
    local x = args.x or 0;
    local y = args.y or 0;
    local w = args.w or 1 * (args.size or 1);
    local h = args.h or 1 * (args.size or 1);

    if args.disabled then
        return string.format("button[%f,%f;%f,%f;disabled_button;%s]", x, y, w, h, args.text or "");
    end

    local data = string.format("button[%f,%f;%f,%f;%s;%s]", x, y, w, h, args.id or "", args.text or "");

    if args.tooltip then
        if args.id and not args.disabled then
            data = data .. gui.tooltip {
                id = args.id,
                text = args.tooltip
            };
        else
            data = data .. gui.tooltip {
                x = x,
                y = y,
                w = w,
                h = h,
                text = args.tooltip
            };
        end
    end

    return data;
end

-- Create a formspec container
--
-- (Optional) x: The x offset of the container. Defaults to 0.
-- (Optional) y: The y offset of the container. Defaults to 0.
-- (Optional) w: The width of the container (for drawing a background). Defaults to 1.
-- (Optional) h: The height of the container (for drawing a background). Defaults to 1.
-- (Optional) size: Multiplies the width and height. Defaults to 1.
-- (Optional) bg: A 9-slice background skin object
--
-- Additional arguments are added as the container's child elements
--
-- Returns a formspec string
function gui.container(args)
    local x = args.x or 0;
    local y = args.y or 0;
    local w = args.w or 1 * (args.size or 1);
    local h = args.h or 1 * (args.size or 1);

    local data = string.format("container[%f,%f]", x, y);

    if args.bg then
        data = data .. gui.bg9 {
            x = 0,
            y = 0,
            w = w,
            h = h,

            skin = args.bg,
        };
    end

    for _,element in ipairs(args) do
        data = data .. element;
    end

    return data .. "container_end[]";
end

-- Create an image formspec element
--
-- image: The image to display.
-- (Optional) x: The x offset of the container. Defaults to 0.
-- (Optional) y: The y offset of the container. Defaults to 0.
-- (Optional) w: The width of the container (for drawing a background). Defaults to 1.
-- (Optional) h: The height of the container (for drawing a background). Defaults to 1.
-- (Optional) size: Multiplies the width and height. Defaults to 1.
--
-- Returns a formspec string
function gui.image(args)
    local x = args.x or 0;
    local y = args.y or 0;
    local w = args.w or 1 * (args.size or 1);
    local h = args.h or 1 * (args.size or 1);

    return string.format("image[%f,%f;%f,%f;%s]", x, y, w, h, args.image);
end

-- Create an image button formspec element
--
-- image: The image to display on the button
-- (Optional) text: The text to display on the button
-- (Optional) x: The x position of the element. Defaults to 0.
-- (Optional) y: The y position of the element. Defaults to 0.
-- (Optional) w: The width of the element. Defaults to 1.
-- (Optional) h: The height of the element. Defaults to 1.
-- (Optional) size: Multiplies the width and height. Defaults to 1.
-- (Optional) id: The element id
-- (Optional) tooltip: The tooltip to display when hovering this element.
-- (Optional) disabled: Replaces the id with "disabled_button", allowing it to
--                      receive a specific style
--
-- Returns a formspec string
function gui.image_button(args)
    local x = args.x or 0;
    local y = args.y or 0;
    local w = args.w or 1 * (args.size or 1);
    local h = args.h or 1 * (args.size or 1);

    if args.disabled then
        return string.format("image_button[%f,%f;%f,%f;%s;disabled_button;%s]",
                              x, y,
                              w, h,
                              args.image,
                              args.text or "");
    end

    local data = string.format("image_button[%f,%f;%f,%f;%s;%s;%s]",
                                x, y,
                                w, h,
                                args.image,
                                args.id or "",
                                args.text or "");

    if args.tooltip then
        if args.id and not args.disabled then
            data = data .. gui.tooltip {
                id = args.id,
                text = args.tooltip
            };
        else
            data = data .. gui.tooltip {
                x = x,
                y = y,
                w = w,
                h = h,
                text = args.tooltip
            };
        end
    end

    return data;
end

-- Create an inventory list formspec element
--
-- location: The location of the inventory
-- id: The id of the inventory list
-- w: The number of columns in the inventory list
-- h: The number of rows in the inventory list
-- (Optional) x: The x position of the element. Defaults to 0.
-- (Optional) y: The y position of the element. Defaults to 0.
-- (Optional) bg: A 9-slice background skin object (To display under each slot)
-- (Optional) tooltip: The tooltip to display when hovering this element.
--
-- Returns a formspec string
function gui.inventory(args)
    local data = "";

    if args.bg then
        for i = 0,args.w - 1 do
            for j = 0,args.h - 1 do
                data = data .. gui.bg9 {
                    x = args.x + (i * 1.25),
                    y = args.y + (j * 1.25),

                    skin = args.bg,
                };
            end
        end
    end

    data = data .. string.format("listcolors[#00000000;#00000022] list[%s;%s;%f,%f;%f,%f;]",
                                  args.location, args.id,
                                  args.x or 0, args.y or 0,
                                  args.w, args.h);

    if args.tooltip then
        data = data .. gui.tooltip {
            x = args.x,
            y = args.y,
            w = args.w,
            h = args.h,
            text = args.tooltip,
        };
    end

    return data;
end

-- Create a label formspec element
--
-- text: The text of the label
-- (Optional) textcolor: The color of the label
-- (Optional) x: The x position of the element. Defaults to 0.
-- (Optional) y: The y position of the element. Defaults to 0.
--
-- Returns a formspec string
function gui.label(args)
    if args.textcolor then
        return string.format("label[%f,%f;%s%s]",
                             args.x or 0,
                             args.y or 0,
                             minetest.get_color_escape_sequence(args.textcolor),
                             args.text);
    end

    return string.format("label[%f,%f;%s]", args.x or 0, args.y or 0, args.text);
end

local function style_internal(selector, properties)
    local data = "[" .. selector;
    for name,value in pairs(properties) do
        data = data .. string.format(";%s=%s", name, tostring(value));
    end
    return data .. "]";
end

-- Create a formspec style
--
-- selector: A valid comma-separated list of id-based style selectors
-- properties: A table of property names and values
--
-- Returns a formspec string
function gui.style(args)
    return "style" .. style_internal(args.selector, args.properties);
end

-- Create a formspec style
--
-- selector: A valid comma-separated list of type-based style selectors
-- properties: A table of property names and values
--
-- Returns a formspec string
function gui.style_type(args)
    return "style_type" .. style_internal(args.selector, args.properties);
end

-- Create a formspec tooltip element
--
-- text: The text of the tooltip
-- (Optional) id: The ID of the element to display on
--
-- (Required when id == nil) x: The x position of the element
-- (Required when id == nil) y: The y position of the element
-- (Required when id == nil) w: The width of the element
-- (Required when id == nil) h: The height of the element
--
-- Returns a formspec string
function gui.tooltip(args)
    if args.id then
        return string.format("tooltip[%s;%s]", args.id, args.text);
    else
        return string.format("tooltip[%f,%f;%f,%f;%s]", args.x, args.y, args.w, args.h, args.text);
    end
end

return gui;
