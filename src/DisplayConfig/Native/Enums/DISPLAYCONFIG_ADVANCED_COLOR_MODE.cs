namespace MartinGC94.DisplayConfig.Native.Enums
{
    internal enum DISPLAYCONFIG_ADVANCED_COLOR_MODE : uint
    {
        DISPLAYCONFIG_ADVANCED_COLOR_MODE_SDR = 0,          // RGB888 composition, display-referred color, display-referred luminance
        DISPLAYCONFIG_ADVANCED_COLOR_MODE_WCG = 1,          // Advanced color (FP16 scRGB composition), scene-referred color, display-referred luminance
        DISPLAYCONFIG_ADVANCED_COLOR_MODE_HDR = 2          // Advanced color (FP16 scRGB composition), scene-referred color, scene-referred luminance
    }
}