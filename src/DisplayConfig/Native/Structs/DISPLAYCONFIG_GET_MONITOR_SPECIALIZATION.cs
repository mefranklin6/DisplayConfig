using System.Runtime.InteropServices;

namespace MartinGC94.DisplayConfig.Native.Structs
{
    [StructLayout(LayoutKind.Sequential)]
    internal struct DISPLAYCONFIG_GET_MONITOR_SPECIALIZATION
    {
        public DISPLAYCONFIG_DEVICE_INFO_HEADER header;
        public uint value;
        public bool IsSpecializationEnabled => (value << 31) >> 31 == 1;
        public bool IsSpecializationAvailableForMonitor => (value << 30) >> 31 == 1;
        public bool IsSpecializationAvailableForSystem => (value << 29) >> 31 == 1;
    }
}