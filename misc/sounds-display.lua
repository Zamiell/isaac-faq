local mod = RegisterMod("Sounds Display", 1)

-- Constants
local TEXT_X = 60
local TEXT_Y = 90
local WHITE = KColor(1, 1, 1, 1)

-- Mod variables
local messageArray = {}
local font = Font()
font:Load("font/pftempestasevencondensed.fnt") -- A vanilla font good for this kind of text
local lineHeight = font:GetLineHeight()
local sfxManager = SFXManager()

local function pushMessageArray(msg)
  messageArray[#messageArray + 1] = msg
  if #messageArray > 10 then
    -- We only want to show 10 messages at a time
    -- Remove the first elemenent
    table.remove(messageArray, 1)
  end
end

-- ModCallbacks.MC_POST_RENDER (2)
function mod:PostRender()
  mod:RecordPlayingSounds()
  mod:RenderText()
end

function mod:RecordPlayingSounds()
  messageArray = {}
  for soundEffectName, soundEffect in pairs(SoundEffect) do
    if sfxManager:IsPlaying(soundEffect) then
      pushMessageArray(tostring(soundEffect) .. " - " .. soundEffectName)
    end
  end
end

function mod:RenderText()
  for i, msg in ipairs(messageArray) do
    font:DrawStringUTF8(
      msg,
      TEXT_X,
      TEXT_Y + ((i - 1) * lineHeight),
      WHITE,
      0,
      true
    )
  end
end

mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.PostRender)
