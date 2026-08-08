use qa_test::assert_serial;

// Note: Ensure tests run sequentially using `cargo test -- --test-threads=1`
// to prevent Wokwi TCP stream overlap.

#[test]
fn test_01_tmp102_i2c_discovery() {
    // 1. Verify the I2C bus scan discovers the TMP102 at its default address 0x48
    assert_serial!("Probing I2C bus");
    assert_serial!("Found i2c device at address 0x48");
}

#[test]
fn test_02_tmp102_temperature_reading() {
    // 1. Verify the sensor publishes the canonical observable (default 21.0 °C)
    //    using the Canonical Test Specification's presentation template
    //    "Temperature = {:.1f} C".
    assert_serial!("Temperature = 21.0 C");
}
