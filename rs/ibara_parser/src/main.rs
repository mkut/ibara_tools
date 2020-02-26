extern crate html5ever;
extern crate markup5ever_rcdom as rcdom;
extern crate ibara_parser;

use std::error::Error;
use std::fs::File;
use std::default::Default;

use html5ever::driver::ParseOpts;
use html5ever::tendril::TendrilSink;
use html5ever::tree_builder::TreeBuilderOpts;
use html5ever::{parse_document};
use rcdom::{RcDom};
use ibara_parser::parser::document_parser::{parse_document as pd};

fn main() -> Result<(), Box<dyn Error>> {
    let root_dir = "../../../release/result04/result/k/now";
    let fname = format!("{}{}", root_dir, "/r106b1.html");
    let opts = ParseOpts {
        tree_builder: TreeBuilderOpts {
            drop_doctype: true,
            ..Default::default()
        },
        ..Default::default()
    };
    let mut fin = File::open(fname)?;
    let dom = parse_document(RcDom::default(), opts)
        .from_utf8()
        .read_from(&mut fin)?;

    let text = pd(&dom.document);
    println!("{}", text);

    return Ok(());
}
