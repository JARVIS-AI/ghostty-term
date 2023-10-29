const std = @import("std");
const windows = std.os.windows;

pub usingnamespace std.os.windows;

pub const exp = struct {
    pub const HPCON = windows.LPVOID;

    pub const CREATE_UNICODE_ENVIRONMENT = 0x00000400;
    pub const EXTENDED_STARTUPINFO_PRESENT = 0x00080000;
    pub const LPPROC_THREAD_ATTRIBUTE_LIST = ?*anyopaque;
    pub const FILE_FLAG_FIRST_PIPE_INSTANCE = 0x00080000;

    pub const STATUS_PENDING = 0x00000103;
    pub const STILL_ACTIVE = STATUS_PENDING;

    pub const STARTUPINFOEX = extern struct {
        StartupInfo: windows.STARTUPINFOW,
        lpAttributeList: LPPROC_THREAD_ATTRIBUTE_LIST,
    };

    pub const kernel32 = struct {
        pub extern "kernel32" fn CreatePipe(
            hReadPipe: *windows.HANDLE,
            hWritePipe: *windows.HANDLE,
            lpPipeAttributes: ?*const windows.SECURITY_ATTRIBUTES,
            nSize: windows.DWORD,
        ) callconv(windows.WINAPI) windows.BOOL;
        pub extern "kernel32" fn CreatePseudoConsole(
            size: windows.COORD,
            hInput: windows.HANDLE,
            hOutput: windows.HANDLE,
            dwFlags: windows.DWORD,
            phPC: *HPCON,
        ) callconv(windows.WINAPI) windows.HRESULT;
        pub extern "kernel32" fn ResizePseudoConsole(hPC: HPCON, size: windows.COORD) callconv(windows.WINAPI) windows.HRESULT;
        pub extern "kernel32" fn ClosePseudoConsole(hPC: HPCON) callconv(windows.WINAPI) void;
        pub extern "kernel32" fn InitializeProcThreadAttributeList(
            lpAttributeList: LPPROC_THREAD_ATTRIBUTE_LIST,
            dwAttributeCount: windows.DWORD,
            dwFlags: windows.DWORD,
            lpSize: *windows.SIZE_T,
        ) callconv(windows.WINAPI) windows.BOOL;
        pub extern "kernel32" fn UpdateProcThreadAttribute(
            lpAttributeList: LPPROC_THREAD_ATTRIBUTE_LIST,
            dwFlags: windows.DWORD,
            Attribute: windows.DWORD_PTR,
            lpValue: windows.PVOID,
            cbSize: windows.SIZE_T,
            lpPreviousValue: ?windows.PVOID,
            lpReturnSize: ?*windows.SIZE_T,
        ) callconv(windows.WINAPI) windows.BOOL;
        pub extern "kernel32" fn PeekNamedPipe(
            hNamedPipe: windows.HANDLE,
            lpBuffer: ?windows.LPVOID,
            nBufferSize: windows.DWORD,
            lpBytesRead: ?*windows.DWORD,
            lpTotalBytesAvail: ?*windows.DWORD,
            lpBytesLeftThisMessage: ?*windows.DWORD,
        ) callconv(windows.WINAPI) windows.BOOL;
        // Duplicated here because lpCommandLine is not marked optional in zig std
        pub extern "kernel32" fn CreateProcessW(
            lpApplicationName: ?windows.LPWSTR,
            lpCommandLine: ?windows.LPWSTR,
            lpProcessAttributes: ?*windows.SECURITY_ATTRIBUTES,
            lpThreadAttributes: ?*windows.SECURITY_ATTRIBUTES,
            bInheritHandles: windows.BOOL,
            dwCreationFlags: windows.DWORD,
            lpEnvironment: ?*anyopaque,
            lpCurrentDirectory: ?windows.LPWSTR,
            lpStartupInfo: *windows.STARTUPINFOW,
            lpProcessInformation: *windows.PROCESS_INFORMATION,
        ) callconv(windows.WINAPI) windows.BOOL;
    };

    pub const PROC_THREAD_ATTRIBUTE_NUMBER = 0x0000FFFF;
    pub const PROC_THREAD_ATTRIBUTE_THREAD = 0x00010000;
    pub const PROC_THREAD_ATTRIBUTE_INPUT = 0x00020000;
    pub const PROC_THREAD_ATTRIBUTE_ADDITIVE = 0x00040000;

    pub const ProcThreadAttributeNumber = enum(windows.DWORD) {
        ProcThreadAttributePseudoConsole = 22,
        _,
    };

    /// Corresponds to the ProcThreadAttributeValue define in WinBase.h
    pub fn ProcThreadAttributeValue(
        comptime attribute: ProcThreadAttributeNumber,
        comptime thread: bool,
        comptime input: bool,
        comptime additive: bool,
    ) windows.DWORD {
        return (@intFromEnum(attribute) & PROC_THREAD_ATTRIBUTE_NUMBER) |
            (if (thread) PROC_THREAD_ATTRIBUTE_THREAD else 0) |
            (if (input) PROC_THREAD_ATTRIBUTE_INPUT else 0) |
            (if (additive) PROC_THREAD_ATTRIBUTE_ADDITIVE else 0);
    }

    pub const PROC_THREAD_ATTRIBUTE_PSEUDOCONSOLE = ProcThreadAttributeValue(.ProcThreadAttributePseudoConsole, false, true, false);
};
