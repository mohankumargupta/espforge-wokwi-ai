use qa_test::assert_serial;

// Run sequentially with `cargo test -- --test-threads=1` to prevent
// Wokwi TCP stream overlap between tests.

#[test]
fn test_01_tmp102_boot() {
    // Firmware boots, ESPHome starts. Device comes up on the I2C bus.
    assert_serial!("boot");
}

#[test]
fn test_02_tmp102_reads_temperature() {
    // on_boot triggers a tmp102 sensor update; the spec's canonical default
    // ambient temperature is 21.0 C, presented as "Temperature = {:.1f} C".
    assert_serial!("Temperature = 21.0 C");
}