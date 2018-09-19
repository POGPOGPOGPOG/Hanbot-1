return {
  id = "BlinkEve",
  name = "Evelynn",
  riot = true,
  flag = {
    text = "Evelynn by dontblink",
    color = {
      text = 0xFFEDD7E6,
      background1 = 0xFFEDBBDC,
      background2 = 0x99000000
    }
  },
  load = function()
    return player.charName == "Evelynn"
  end
}