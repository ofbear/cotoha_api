mod cotoha;
use cotoha::Cotoha;

fn main() {
    let c = Cotoha::new("clientId", "clientSecret");

    let result = c.similarity("test", "test", "", "");
    if result.is_ok() {
        println!("{}", result.ok().unwrap());
    } else {
        println!("{}", result.err().unwrap());
    }
}

