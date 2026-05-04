using System.Runtime.InteropServices;

namespace MartinGC94.DisplayConfig.Native.Structs
{
    [StructLayout(LayoutKind.Sequential)]
    internal struct DISPLAYCONFIG_SET_HDR_STATE
    {
        public DISPLAYCONFIG_DEVICE_INFO_HEADER header;
        public uint value;
        public bool EnableHdr => (value << 31) >> 31 == 1;
    }
}