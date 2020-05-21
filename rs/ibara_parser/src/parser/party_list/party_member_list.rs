extern crate scraper;
extern crate ego_tree;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::general::element;
use crate::parser::combinator::repeated;
use crate::parser::party_list::party_member;
use crate::parser::party_list::models::PartyMember;

/*
 * PARTY_MEMBER_LIST
 *  => BR
 *     (table > PARTY_MEMBER_LIST_TABLE)
 */
pub fn parse(cursor: &mut Traceable<Children<Node>>) -> Result<Vec<PartyMember>, String> {
   element::ignore("br")(cursor)?;
   let eref = element::parse("table")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_table(&mut cursor)
}

/*
 * PARTY_MEMBER_LIST_TABLE
 *  => (tbody > PARTY_MEMBER_LIST_TBODY)
 */
fn parse_table(cursor: &mut Traceable<Children<Node>>) -> Result<Vec<PartyMember>, String> {
   let eref = element::parse("tbody")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_tbody(&mut cursor)
}

/*
 * PARTY_MEMBER_LIST_TBODY
 *  => PARTY_MEMBER*
 */
fn parse_tbody(cursor: &mut Traceable<Children<Node>>) -> Result<Vec<PartyMember>, String> {
   Ok(repeated(&party_member::parse)(cursor))
}