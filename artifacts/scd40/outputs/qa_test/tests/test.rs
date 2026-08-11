use qa_test::assert_serial;

// Note: Ensure tests run sequentially using `cargo test -- --test-threads=1`
// to prevent Wokwi TCP stream overlap.

#[test]
fn test_01_scd40_single_measurement_cycle() {
    // 1. Verify periodic measurement mode reads a data-ready chip and the
    //    canonical read_measurement result stream (CO2 = 500 ppm, Temp. = 25 C,
    //    RH = 37%).
    //
    // These exact strings are printed by the on_value automations in
    // scd40.yaml, which fire after the driver publishes a non-NaN value.
    assert_serial!("CO2 = 500 ppm");
    assert_serial!("Temperature = 25.00 C");
    assert_serial!("Humidity = 37.00 %");
}