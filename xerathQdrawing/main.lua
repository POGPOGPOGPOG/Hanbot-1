local version = "0.1"

local menu = menu("XerQDrawing", "Meme By dontblink")
menu:menu("draws", "Draw Settings")
menu.draws:boolean("drawq", "Draw Q Range", true)
menu.draws:color("colorq", "  ^- Color", 255, 255, 255, 255)

local function OnDraw()
    if player.isOnScreen then 
       if menu.draws.drawq:get() then
          graphics.draw_circle(player.pos, 1400, 2, menu.draws.colorq:get(), 50)
       end
    end
end

cb.add(cb.draw, OnDraw)