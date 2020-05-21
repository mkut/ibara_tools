extern crate scraper;
extern crate ego_tree;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::general::{element, text};

/*
 * PARTY_NAME
 *  => (b > PARTY_NAME_MAIN)
 */
pub fn parse(cursor: &mut Traceable<Children<Node>>) -> Result<String, String> {
   let eref = element::parse("b")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_main(&mut cursor)
}

/*
 * PARTY_NAME_MAIN
 *  => text
 */
fn parse_main(cursor: &mut Traceable<Children<Node>>) -> Result<String, String> {
   text::parse(cursor)
}