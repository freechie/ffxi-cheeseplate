using System;
using System.IO;
using System.Runtime.InteropServices;

class MonitorQuery {
    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern IntPtr FindWindow(string cls, string name);

    [DllImport("user32.dll")]
    static extern IntPtr MonitorFromWindow(IntPtr hwnd, uint flags);

    [StructLayout(LayoutKind.Sequential)]
    struct Rect {
        public int Left, Top, Right, Bottom;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct MonitorInfo {
        public int Size;
        public Rect Monitor;
        public Rect Work;
        public int Flags;
    }

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern bool GetMonitorInfo(IntPtr monitor, ref MonitorInfo info);

    static int Main(string[] args) {
        IntPtr hwnd = FindWindow("FFXiClass", null);
        if (hwnd == IntPtr.Zero) return 1;
        IntPtr monitor = MonitorFromWindow(hwnd, 2);
        MonitorInfo info = new MonitorInfo();
        info.Size = Marshal.SizeOf(typeof(MonitorInfo));
        if (!GetMonitorInfo(monitor, ref info)) return 2;
        int w = info.Monitor.Right - info.Monitor.Left;
        int h = info.Monitor.Bottom - info.Monitor.Top;
        string text = w.ToString() + "x" + h.ToString();
        if (args.Length > 0) File.WriteAllText(args[0], text);
        return 0;
    }
}

