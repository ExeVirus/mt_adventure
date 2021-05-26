local materials_by_name = {};
local materials_by_group = {};

return {
    -- Get the converted material value of the given itemstack
    --
    -- stack: The itemstack to convert
    --
    -- Returns a table with the material values
    get_stack_value = function(stack)
        local item_name = stack:get_name();
        local item_count = stack:get_count();

        for name,mats in pairs(materials_by_name) do
            if name == item_name then
                return {
                    paper = (mats.paper or 0) * item_count,
                    pigment = (mats.pigment or 0) * item_count,
                }
            end
        end

        for group,mats in pairs(materials_by_group) do
            if minetest.get_item_group(item_name, group) ~= 0 then
                return {
                    paper = (mats.paper or 0) * item_count,
                    pigment = (mats.pigment or 0) * item_count,
                }
            end
        end

        return {
            paper = 0,
            pigment = 0,
        };
    end,

    -- Register a material from an item name
    --
    -- name: The name of the item
    -- material: The material type to set
    -- value: The material value
    register_by_name = function(name, material, value)
        if materials_by_name[name] then
            materials_by_name[name][material] = value or 1;
        else
            materials_by_name[name] = {
                [material] = value or 1,
            };
        end
    end,

    -- Register a material from an item group
    --
    -- group: The name of the group
    -- material: The material type to set
    -- value: The material value
    register_by_group = function(name, material, value)
        if materials_by_group[name] then
            materials_by_group[name][material] = value or 1;
        else
            materials_by_group[name] = {
                [material] = value or 1,
            };
        end
    end,
};
