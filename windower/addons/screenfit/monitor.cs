using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

class MonitorQuery {
    const uint MONITOR_DEFAULTTONEAREST = 2;
    const int MONITORINFOF_PRIMARY = 1;
    const int SW_RESTORE = 9;
    const uint SWP_NOZORDER = 0x0004;
    const uint SWP_SHOWWINDOW = 0x0040;

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
    static extern bool SetWindowPos(IntPtr hwnd, IntPtr after, int x, int y, int cx, int cy, uint flags);

    [DllImport("user32.dll")]
    static extern bool ShowWindow(IntPtr hwnd, int cmd);

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

    static IntPtr primaryMon;
    static MonitorEnum enumProc;

    static MonitorInfo Info(IntPtr monitor) {
        MonitorInfo info = new MonitorInfo();
        info.Size = Marshal.SizeOf(typeof(MonitorInfo));
        GetMonitorInfo(monitor, ref info);
        return info;
    }

    static bool Same(Rect a, Rect b) {
        return a.Left == b.Left && a.Top == b.Top && a.Right == b.Right && a.Bottom == b.Bottom;
    }

    static string Line(string key, MonitorInfo info) {
        int w = info.Monitor.Right - info.Monitor.Left;
        int h = info.Monitor.Bottom - info.Monitor.Top;
        return key + " " + w + "x" + h + " " + info.Monitor.Left + " " + info.Monitor.Top;
    }

    static bool EnumOne(IntPtr monitor, IntPtr hdc, ref Rect rect, IntPtr data) {
        MonitorInfo info = Info(monitor);
        if ((info.Flags & MONITORINFOF_PRIMARY) != 0) primaryMon = monitor;
        return true;
    }

    static int Main(string[] args) {
        bool move = false;
        string outPath = null;
        foreach (string arg in args) {
            if (arg == "move") move = true;
            else outPath = arg;
        }

        IntPtr hwnd = FindWindow("FFXiClass", null);
        if (hwnd == IntPtr.Zero) return 1;

        primaryMon = IntPtr.Zero;
        enumProc = EnumOne;
        EnumDisplayMonitors(IntPtr.Zero, IntPtr.Zero, enumProc, IntPtr.Zero);
        if (primaryMon == IntPtr.Zero) return 2;
        MonitorInfo primary = Info(primaryMon);

        int moved = 0;
        if (move) {
            IntPtr currentMon = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
            MonitorInfo current = Info(currentMon);
            if (!Same(current.Monitor, primary.Monitor)) {
                int w = primary.Monitor.Right - primary.Monitor.Left;
                int h = primary.Monitor.Bottom - primary.Monitor.Top;
                ShowWindow(hwnd, SW_RESTORE);
                if (SetWindowPos(hwnd, IntPtr.Zero, primary.Monitor.Left, primary.Monitor.Top, w, h, SWP_NOZORDER | SWP_SHOWWINDOW))
                    moved = 1;
            }
        }

        IntPtr nowMon = MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST);
        MonitorInfo now = Info(nowMon);
        StringBuilder text = new StringBuilder();
        text.AppendLine(Line("primary", primary));
        text.AppendLine(Line("current", now));
        text.AppendLine("moved " + moved);
        if (outPath != null) File.WriteAllText(outPath, text.ToString());
        else Console.Write(text.ToString());
        return 0;
    }
}
