extern crate scraper;
extern crate ego_tree;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::general::{element, text};

/*
 * PARTY_MEMBER_ENO
 *  => (b > PARTY_MEMBER_ENO_MAIN)
 */
pub fn parse(cursor: &mut Traceable<Children<Node>>) -> Result<u32, String> {
   let eref = element::parse("b")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_main(&mut cursor)
}

/*
 * PARTY_MEMBER_ENO_MAIN
 *  => text
 */
fn parse_main(cursor: &mut Traceable<Children<Node>>) -> Result<u32, String> {
   text::parse(cursor)?.parse().map_err(|x| {format!("{}", x)})
}