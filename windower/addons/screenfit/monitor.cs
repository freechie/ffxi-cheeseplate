using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

class MonitorQuery {
    const uint MONITOR_DEFAULTTONEAREST = 2;
    const int WS_CAPTION = 0x00C00000;
    const int GWL_STYLE = -16;

    delegate bool MonitorEnum(IntPtr monitor, IntPtr hdc, ref Rect rect, IntPtr data);

    [DllImport("user32.dll")]
    static extern bool EnumDisplayMonitors(IntPtr hdc, IntPtr clip, MonitorEnum proc, IntPtr data);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern IntPtr FindWindow(string cls, string name);

    [DllImport("user32.dll")]
    static extern IntPtr MonitorFromWindow(IntPtr hwnd, uint flags);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    static extern bool GetMonitorInfo(IntPtr monitor, ref MonitorInfo info);

    [DllImport("user32.dll")]
    static extern bool GetWindowRect(IntPtr hwnd, out Rect rect);

    [DllImport("user32.dll", EntryPoint = "GetWindowLong")]
    static extern int GetWindowLong32(IntPtr hwnd, int index);

    [DllImport("user32.dll", EntryPoint = "GetWindowLongPtr")]
    static extern IntPtr GetWindowLongPtr64(IntPtr hwnd, int index);

    [StructLayout(LayoutKind.Sequential)]
    struct Rect {
        public int Left, Top, Right, Bottom;
    }

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    struct MonitorInfo {
        public int Size;
        public Rect Monitor;
        public Rect Work;
        public int Flags;
    }

    static List<MonitorInfo> monitors = new List<MonitorInfo>();
    static MonitorEnum enumProc;

    static int GetStyle(IntPtr hwnd) {
        if (IntPtr.Size == 8) return (int)GetWindowLongPtr64(hwnd, GWL_STYLE).ToInt64();
        return GetWindowLong32(hwnd, GWL_STYLE);
    }

    static MonitorInfo Info(IntPtr monitor) {
        MonitorInfo info = new MonitorInfo();
        info.Size = Marshal.SizeOf(typeof(MonitorInfo));
        GetMonitorInfo(monitor, ref info);
        return info;
    }

    static bool Same(Rect a, Rect b) {
        return a.Left == b.Left && a.Top == b.Top && a.Right == b.Right && a.Bottom == b.Bottom;
    }

    static string Box(Rect rect) {
        return (rect.Right - rect.Left) + "x" + (rect.Bottom - rect.Top) + " " + rect.Left + " " + rect.Top;
    }

    static bool EnumOne(IntPtr monitor, IntPtr hdc, ref Rect rect, IntPtr data) {
        monitors.Add(Info(monitor));
        return true;
    }

    static int Main(string[] args) {
        string outPath = args.Length > 0 ? args[0] : null;
        IntPtr hwnd = FindWindow("FFXiClass", null);
        if (hwnd == IntPtr.Zero) return 1;

        enumProc = EnumOne;
        EnumDisplayMonitors(IntPtr.Zero, IntPtr.Zero, enumProc, IntPtr.Zero);
        if (monitors.Count == 0) return 2;

        IntPtr currentMon = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
        MonitorInfo current = Info(currentMon);
        int here = 0;
        MonitorInfo primary = monitors[0];
        for (int i = 0; i < monitors.Count; i++) {
            if ((monitors[i].Flags & 1) != 0) primary = monitors[i];
            if (Same(monitors[i].Monitor, current.Monitor)) here = i;
        }

        Rect window;
        GetWindowRect(hwnd, out window);
        bool framed = (GetStyle(hwnd) & WS_CAPTION) != 0;

        StringBuilder text = new StringBuilder();
        text.AppendLine("frame " + (framed ? 1 : 0));
        text.AppendLine("here " + here);
        text.AppendLine("primary " + Box(primary.Monitor));
        text.AppendLine("current " + Box(current.Monitor));
        text.AppendLine("window " + Box(window));
        text.AppendLine("count " + monitors.Count);
        for (int i = 0; i < monitors.Count; i++) {
            text.AppendLine("mon " + i + " " + Box(monitors[i].Monitor));
            text.AppendLine("work " + i + " " + Box(monitors[i].Work));
        }
        if (outPath != null) File.WriteAllText(outPath, text.ToString());
        else Console.Write(text.ToString());
        return 0;
    }
}
