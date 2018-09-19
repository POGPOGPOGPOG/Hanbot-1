return {
    id = "XerQDrawing",
    name = "XerQDrawing",
    riot = true,
    flag = {
      text = "Meme by dontblink",
      color = {
        text = 0xFFEDD7E6,
        background1 = 0xFFEDBBDC,
        background2 = 0x99000000
      }
    },
    load = function()
      return player.charName == "Xerath"
    end
  }