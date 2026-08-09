use qa_test::assert_serial;
use std::time::Duration;

// Note: Ensure tests run sequentially using `cargo test -- --test-threads=1`
// to prevent Wokwi TCP stream overlap.

const TEST_TIMEOUT: Duration = Duration::from_secs(90);

#[test]
fn test_01_tmp102_temperature_reading() {
    // The on_boot automation forces a first `component.update: temperature`.
    // The tmp102 driver issues the temperature-register read and, once a
    // non-NaN value is published, the sensor's on_value lambda logs:
    //     Temperature = 21.0 C
    // (21.0 is the canonical ground-truth default from the Canonical Test Spec;
    //  %.1f formats it with one decimal digit.)
    assert_serial!("Temperature = 21.0 C", TEST_TIMEOUT);
}