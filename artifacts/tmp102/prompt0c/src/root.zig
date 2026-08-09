//! Package root: re-exports the TMP102 data-conversion module.
//!
//! Downstream consumers import this package and use the functions from the
//! `tmp102` namespace; they are the canonical, single source of truth for
//! TMP102 register-level bit layout (see src/main.zig).
pub const tmp102 = @import("main.zig");