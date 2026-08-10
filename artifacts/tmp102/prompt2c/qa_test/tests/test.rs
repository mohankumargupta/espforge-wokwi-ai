use qa_test::assert_serial;

// Note: Ensure tests run sequentially using `cargo test -- --test-threads=1`
// to prevent Wokwi TCP stream overlap.

#[test]
fn test_01_tmp102_temperature_observable() {
    // Canonical observable `temperature` (spec default 25.0, precision 1).
    // The value is printed by the tmp102 sensor's on_value lambda in tmp102.yaml,
    // not reconstructed here: "Temperature = %.1f C" -> "Temperature = 25.0 C".
    assert_serial!("Temperature = 25.0 C");
}