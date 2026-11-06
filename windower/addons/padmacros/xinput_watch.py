import ctypes
import msvcrt
import os
import sys
import time


class XInputGamepad(ctypes.Structure):
    _fields_ = [
        ('wButtons', ctypes.c_ushort),
        ('bLeftTrigger', ctypes.c_ubyte),
        ('bRightTrigger', ctypes.c_ubyte),
        ('sThumbLX', ctypes.c_short),
        ('sThumbLY', ctypes.c_short),
        ('sThumbRX', ctypes.c_short),
        ('sThumbRY', ctypes.c_short),
    ]


class XInputState(ctypes.Structure):
    _fields_ = [
        ('dwPacketNumber', ctypes.c_uint),
        ('Gamepad', XInputGamepad),
    ]


def load_xinput():
    for name in ('xinput1_4', 'xinput1_3', 'xinput9_1_0'):
        try:
            return ctypes.WinDLL(name)
        except OSError:
            continue
    raise OSError('XInput is not available')


def hold_lock(lock_path):
    handle = open(lock_path, 'a+b')
    handle.seek(0, os.SEEK_END)
    if handle.tell() < 1:
        handle.write(b'1')
        handle.flush()
    handle.seek(0)
    try:
        msvcrt.locking(handle.fileno(), msvcrt.LK_NBLCK, 1)
    except OSError:
        return None
    return handle


def read_pad(get_state, state):
    chosen = None
    for index in range(4):
        if get_state(index, ctypes.byref(state)) != 0:
            continue
        pad = state.Gamepad
        snap = (pad.wButtons, pad.bLeftTrigger, pad.bRightTrigger)
        if chosen is None:
            chosen = snap
        if snap[0] or snap[1] >= 80 or snap[2] >= 80:
            return snap
    return chosen


def write_state(state_path, line):
    # Overwrite in place. Replacing the file while the addon is reading it
    # raises PermissionError and used to kill this process, leaving the last
    # trigger value stuck on screen.
    data = line.encode('ascii')
    for _ in range(5):
        try:
            with open(state_path, 'r+b') as handle:
                handle.seek(0)
                handle.write(data)
                handle.flush()
            return True
        except FileNotFoundError:
            try:
                with open(state_path, 'w', encoding='ascii', newline='\n') as handle:
                    handle.write(line)
                return True
            except OSError:
                time.sleep(0.002)
        except OSError:
            time.sleep(0.002)
    return False


def main():
    state_path = sys.argv[1]
    os.makedirs(os.path.dirname(state_path), exist_ok=True)
    lock = hold_lock(state_path + '.lock')
    if lock is None:
        return
    library = load_xinput()
    get_state = library.XInputGetState
    get_state.argtypes = [ctypes.c_uint, ctypes.POINTER(XInputState)]
    get_state.restype = ctypes.c_uint
    state = XInputState()
    while True:
        snap = read_pad(get_state, state)
        buttons, lt, rt = (0, 0, 0) if snap is None else snap
        # Fixed width so a reader never sees a torn shorter line.
        line = '%05d %03d %03d %013d\n' % (buttons, lt, rt, int(time.time() * 1000))
        write_state(state_path, line)
        time.sleep(0.016)


if __name__ == '__main__':
    main()
