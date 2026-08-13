use qa_test::assert_serial;

// Note: Ensure tests run sequentially using `cargo test -- --test-threads=1`
// to prevent Wokwi TCP stream overlap.

#[test]
fn test_01_dht22_measurement() {
    // on_boot issues component.update on the DHT22; the sensor's
    // on_value triggers log the canonical spec defaults (test_spec_dht22.md:
    // temperature default 25.0 C, humidity default 50.4 %).
    assert_serial!("Temperature = 25.0 C");
    assert_serial!("Humidity = 50.4 %");
}