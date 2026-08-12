use qa_test::assert_serial;

// Note: This test reads the Wokwi rfc2217 TCP serial stream (127.0.0.1:4000)
// produced by the ESPHome dut firmware. Assertions are ordered to match the
// order the apds9960 on_value lambdas print the observables:
// read_color_data_() publishes clear, red, green, blue; read_proximity_data_()
// publishes proximity (apds9960.cpp update()).
//
// Ground truth values come from the Canonical Test Specification (test_spec_apds9960.md)
// observables.*.default — never recomputed.

#[test]
fn test_01_apds9960_canonical_observables() {
    // Clear channel: default 20.0 (%)
    assert_serial!("Clear channel = 20.0 %");

    // Red channel: default 15.0 (%)
    assert_serial!("Red channel = 15.0 %");

    // Green channel: default 12.0 (%)
    assert_serial!("Green channel = 12.0 %");

    // Blue channel: default 9.0 (%)
    assert_serial!("Blue channel = 9.0 %");

    // Proximity: default 7.1 (%)
    assert_serial!("Proximity = 7.1 %");
}
