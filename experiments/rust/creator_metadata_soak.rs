//! Repeated asset inspections through the safe API, sampling resident memory.
//! Usage: creator_metadata_soak ASSET COUNT; prints one JSON object. COUNT 0
//! reports a single inspection, including its error, for edge-case assets.
use corsairs::Runtime;
use std::process::Command;

fn rss_kib() -> u64 {
    let pid = std::process::id().to_string();
    let output = Command::new("/bin/ps")
        .args(["-o", "rss=", "-p", &pid])
        .output()
        .expect("ps");
    String::from_utf8(output.stdout)
        .unwrap()
        .trim()
        .parse()
        .expect("rss")
}

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let [path, count] = &args[..] else {
        panic!("usage: creator_metadata_soak ASSET COUNT")
    };
    let count: usize = count.parse().unwrap();
    let runtime = Runtime::new().unwrap();
    // COUNT 0 reports one inspection's outcome without loading a model.
    let first = match runtime.inspect_asset(path, true).wait() {
        Ok(first) => first,
        Err(error) if count == 0 => {
            println!("{{\"error\":{:?}}}", error.to_string());
            return;
        }
        Err(error) => panic!("{error}"),
    };
    let mut samples = vec![(0, rss_kib())];
    for index in 1..=count {
        let info = runtime.inspect_asset(path, true).wait().unwrap();
        assert!(info == first, "inspection {index} differs");
        if index % 1000 == 0 {
            samples.push((index, rss_kib()));
        }
    }
    let rows: Vec<_> = samples
        .iter()
        .map(|(index, kib)| format!("[{index},{kib}]"))
        .collect();
    println!(
        "{{\"inspections\":{count},\"creator_entries\":{},\"rss_kib\":[{}]}}",
        first.metadata.creator_defined.len(),
        rows.join(",")
    );
}
