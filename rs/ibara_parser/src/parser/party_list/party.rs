extern crate scraper;
extern crate ego_tree;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::general::element;
use crate::parser::party_list::{party_name, party_member_list};
use crate::parser::party_list::models::Party;

/*
 * PARTY
 *  => (td > PARTY_MAIN)
 */
pub fn parse(cursor: &mut Traceable<Children<Node>>) -> Result<Party, String> {
   let eref = element::parse("td")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_main(&mut cursor)
}

/*
 * PARTY_MAIN
 *  => PARTY_NAME MEMBER_LIST
 */
fn parse_main(cursor: &mut Traceable<Children<Node>>) -> Result<Party, String> {
   let name = party_name::parse(cursor)?;
   let members = party_member_list::parse(cursor)?;
   Ok(Party {name, members})
}


