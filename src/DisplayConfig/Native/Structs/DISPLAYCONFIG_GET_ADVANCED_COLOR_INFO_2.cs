using MartinGC94.DisplayConfig.Native.Enums;
using System.Runtime.InteropServices;

namespace MartinGC94.DisplayConfig.Native.Structs
{
    [StructLayout(LayoutKind.Sequential)]
    internal struct DISPLAYCONFIG_GET_ADVANCED_COLOR_INFO_2
    {
        public DISPLAYCONFIG_DEVICE_INFO_HEADER header;
        public uint value;
        public bool AdvancedColorSupported => (value << 31) >> 31 == 1;
        public bool AdvancedColorActive => (value << 30) >> 31 == 1;
        public bool Reserved1 => (value << 29) >> 31 == 1;
        public bool AdvancedColorLimitedByPolicy => (value << 28) >> 31 == 1;
        public bool HighDynamicRangeSupported => (value << 27) >> 31 == 1;
        public bool HighDynamicRangeUserEnabled => (value << 26) >> 31 == 1;
        public bool WideColorSupported => (value << 25) >> 31 == 1;
        public bool WideColorUserEnabled => (value << 24) >> 31 == 1;
        public DISPLAYCONFIG_COLOR_ENCODING colorEncoding;
        public uint bitsPerColorChannel;
        public DISPLAYCONFIG_ADVANCED_COLOR_MODE activeColorMode;
    }
}