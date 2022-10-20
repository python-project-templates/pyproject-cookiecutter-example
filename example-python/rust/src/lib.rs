use pyo3::prelude::*;

#[pyfunction]
fn double(x: usize) -> usize {
    let counter: RelaxedCounter = RelaxedCounter::new(x);
    counter.inc()
}


#[pymodule]
fn atomic_counter(_py: Python, m: &PyModule) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(double, m)?)?;
    Ok(())
}


#[cfg(test)]
mod tests {
    #[test]
    fn test_new() {
    }
}