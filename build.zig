const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{});

    const auto_start: AutoStart = .ALWAYS;

    const mconfig_h = b.addConfigHeader(.{
        .style = .{ .cmake = b.path("include/mconfig.h.in") },
        .include_path = "mconfig.h",
    }, .{
        .USE_INITGROUPS = 1,
        .SUPPORT_CGROUPS = 0,
        .SUPPORT_CAPABILITIES = 0,
        .SUPPORT_IOPRIO = 0,
        .SUPPORT_OOM_ADJ = 0,
        .DEFAULT_AUTO_RESTART = auto_start,

        .DINIT_VERSION = "0.23.0",
        .SYSCONTROLSOCKET = "/run/dinitctl",
        .BINDIR = "/bin",
        .SBINDIR = "/sbin",
        .SHUTDOWN_PREFIX = "",
        .DEFAULT_START_TIMEOUT = 60,
        .DEFAULT_STOP_TIMEOUT = 10,
    });

    const executables = [_][]const u8{
        "dinit",
        "dinitctl",
        "dinit_check",
        "dinit_monitor",
        "shutdown",
    };

    inline for (executables) |exe_name| {
        const exe = b.addExecutable(.{
            .name = exe_name,
            .root_module = b.createModule(.{
                .target = target,
                .optimize = optimize,
                .link_libcpp = true,
            }),
        });
        exe.root_module.addConfigHeader(mconfig_h);
        exe.root_module.addCSourceFiles(.{
            .root = upstream.path("src"),
            .files = &@field(@This(), exe_name ++ "_sources"),
        });
        exe.root_module.addIncludePath(upstream.path("src/includes"));
        exe.root_module.addIncludePath(upstream.path("dasynq/include"));
        b.installArtifact(exe);
    }
}

const AutoStart = enum {
    NEVER,
    ALWAYS,
    ON_FAILURE,
};

const dinit_sources = [_][]const u8{
    "dinit.cc",
    "load-service.cc",
    "service.cc",
    "proc-service.cc",
    "baseproc-service.cc",
    "control.cc",
    "dinit-log.cc",
    "dinit-main.cc",
    "run-child-proc.cc",
    "options-processing.cc",
    "dinit-env.cc",
    "settings.cc",
    "dinit-iostream.cc",
};

const dinitctl_sources = [_][]const u8{
    "dinitctl.cc",
    "options-processing.cc",
    "settings.cc",
    "dinit-iostream.cc",
    "dinit-client.cc",
};

const dinit_check_sources = [_][]const u8{
    "dinit-check.cc",
    "options-processing.cc",
    "settings.cc",
    "dinit-iostream.cc",
    "dinit-client.cc",
};

const dinit_monitor_sources = [_][]const u8{
    "dinit-monitor.cc",
};

const shutdown_sources = [_][]const u8{
    "shutdown.cc",
};
