-- Buttons table explanation
--{text = "Test Button 1",   event = "testevent",                server = false,                   args1 = "testarg",                                          icon = "fas fa-pills"}, 
-- Label of button            -- Event to trigger When you click  --Server event or client event?  -- parameter of event you can pass arguments up to 4           -- Icon the display on button
                                                                                                -- If event takes no parameter you don't need to write this    -- You can check font awesome for icons        



Config = {}

Config.Dialogs = {

    -- Example 
    {
        peds = { 
            {
                name = "Test Ped",-- Display name of the ped on the screen
                model =  GetHashKey('s_m_y_airworker'),-- Ped model / https://wiki.rage.mp/index.php?title=Peds
                ped_handler = nil, -- Don't touch
                coords = vector3(1093.0081787109375, -3112.29052734375, 5.80089569091796),
                heading = 0,
                draw_text3d_enable = true,
                draw_text3d_label = "E - Talk With Ped",
                questionLabel = "What do you want", -- This will display as ped question                    
            },
            {
                name = "Test Ped 2",-- Display name of the ped on the screen
                model =  GetHashKey('a_m_y_beach_01'),-- Ped model / https://wiki.rage.mp/index.php?title=Peds
                ped_handler = nil, -- Don't touch
                coords = vector3(1083.6611328125, -3114.05517578125, 5.8719458580017),
                heading = 0,
                draw_text3d_enable = false,
                draw_text3d_label = "E - Talk With Ped 2",
                questionLabel = "What do you want 2", -- This will display as ped question                    
            },
        },
        buttons = { -- Buttons to will display on screen
            {
                text = "Test Button 1", value = "test-btn1", icon = "fas fa-pills"
            }, 

            {
                text = "Test Button 2", value = "test-btn2", icon = "fas fa-pills" 
            },  
        },

        onClicked = function(value) 
            if(value == "test-btn1") then
                print('Pressed Test Button 1 do something')
            elseif(value == "test-btn2") then
                print('Pressed Test Button 2 do something')
            end
        end
     }

}