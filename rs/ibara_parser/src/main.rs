extern crate scraper;
extern crate ibara_parser;

use std::error::Error;
use std::fs;

use scraper::Html;
use ibara_parser::parser::document::parse;

fn main() -> Result<(), Box<dyn Error>> {
    let root_dir = "../../../release/result04/result/k/now";
    let fname = format!("{}{}", root_dir, "/r106b1.html");
    let content = fs::read_to_string(fname)?;
    let document = Html::parse_document(&content);

    let text = parse(&document).unwrap();
    println!("{}", text);

    return Ok(());
}
