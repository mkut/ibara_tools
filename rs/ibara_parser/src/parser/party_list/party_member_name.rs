extern crate scraper;
extern crate ego_tree;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::general::{element, text};

/*
 * PARTY_MEMBER_NAME
 *  => BR
 *     (b > PARTY_MEMBER_NAME_MAIN)
 */
pub fn parse(cursor: &mut Traceable<Children<Node>>) -> Result<String, String> {
   element::ignore("br")(cursor)?;
   let eref = element::parse("b")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_main(&mut cursor)
}

/*
 * PARTY_MEMBER_NAME_MAIN
 *  => text
 */
fn parse_main(cursor: &mut Traceable<Children<Node>>) -> Result<String, String> {
   text::parse(cursor)
}