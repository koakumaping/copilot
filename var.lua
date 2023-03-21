local module = {}

module.MAX = 1024
module.MIN = -1024

module.padding = 8

module.fontWidth = 48
module.dotWidth = 22

module.modelBitmapWidth = 280
module.modelBitmapHeight = 134

module.whiteColor = lcd.RGB(255, 255, 255)
module.blackColor = lcd.RGB(0, 0, 0, 0.8)
module.greenColor = lcd.RGB(110, 208, 102)
module.greyColor = lcd.RGB(64, 64, 64)
module.bgColor = lcd.RGB(0xC8, 0xDC, 0xF8)
module.textColor = lcd.GREY(80)
module.themeBgColor = lcd.themeColor(THEME_DEFAULT_BGCOLOR)

return module