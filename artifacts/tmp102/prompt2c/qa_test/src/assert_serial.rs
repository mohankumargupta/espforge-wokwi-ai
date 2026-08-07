use std::cell::RefCell;
use std::io::{BufRead, BufReader};
use std::net::TcpStream;
use std::time::{Duration, Instant};

pub const DEFAULT_TIMEOUT: Duration = Duration::from_secs(60);
const CONNECT_RETRY_DELAY: Duration = Duration::from_millis(250);

thread_local! {
    static WOKWI_READER: RefCell<Option<BufReader<TcpStream>>> = const { RefCell::new(None) };
}

pub fn assert_serial_impl(expected: &str, timeout: Duration) {
    let start = Instant::now();
    let mut line = String::new();

    WOKWI_READER.with(|cell| {
        let mut binding = cell.borrow_mut();
        
        // 1. Lazy Initialization: If the connection doesn't exist yet, make it now!
        if binding.is_none() {
            let host = "127.0.0.1:4000";
            println!("Waiting for Wokwi simulator on {}...", host);
            // Keep retrying until we connect or run out of time, instead of
            // failing on the first attempt (the simulator may still be starting).
            let stream = loop {
                match TcpStream::connect(host) {
                    Ok(stream) => break stream,
                    Err(e) => {
                        if start.elapsed() > timeout {
                            panic!(
                                "Timeout: Could not connect to Wokwi on port 4000 after {:?}. Did you start the simulator? ({})",
                                timeout, e
                            );
                        }
                        std::thread::sleep(CONNECT_RETRY_DELAY);
                    }
                }
            };
            stream.set_read_timeout(Some(Duration::from_secs(5))).unwrap();
            eprintln!("QA_HARNESS_READY: connected to rfc2217 stream");

            *binding = Some(BufReader::new(stream));
        }

        // Safely unwrap since we guaranteed it exists above
        let reader = binding.as_mut().unwrap();

        // 2. Stream Reading Logic
        loop {
            // The connect wait above may have consumed part of the budget, so
            // report the actual time remaining for reading.
            let remaining = timeout.saturating_sub(start.elapsed());
            if remaining.is_zero() {
                panic!(
                    "Timeout: Did not find serial output '{}' within the remaining {:?} (original budget {:?})",
                    expected, remaining, timeout
                );
            }

            line.clear();
            match reader.read_line(&mut line) {
                Ok(0) => panic!("Wokwi closed connection prematurely."),
                Ok(_) => {
                    let cleaned = line.trim();
                    println!("Wokwi: {}", cleaned);
                    if cleaned.contains(expected) {
                        println!("✅ Found: '{}'", expected);
                        break; 
                    }
                }
                Err(e) => panic!("Error reading stream: {}", e),
            }
        }
    });
}

#[macro_export]
macro_rules! assert_serial {
    ($expected:expr) => {
        $crate::assert_serial::assert_serial_impl($expected, $crate::assert_serial::DEFAULT_TIMEOUT);
    };
    ($expected:expr, $timeout:expr) => {
        $crate::assert_serial::assert_serial_impl($expected, $timeout);
    };
}
