extern crate scraper;
extern crate ego_tree;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::general::element;
use crate::parser::combinator::repeated::repeated;
use crate::parser::party_list::party;
use crate::parser::party_list::models::PartyList;

/*
 * PARTY_LIST
 *  => BR*
 *     (div > PARTY_LIST_MAIN)
 */
pub fn parse(cursor: &mut Traceable<Children<Node>>) -> Result<PartyList, String> {
   repeated(&element::ignore("br"))(cursor);

   let eref = element::parse("div")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_main(&mut cursor)
}

/*
 * PARTY_LIST_MAIN
 *  => (table > PARTY_LIST_TABLE)
 */
fn parse_main(cursor: &mut Traceable<Children<Node>>) -> Result<PartyList, String> {
   let eref = element::parse("table")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_table(&mut cursor)
}

/*
 * PARTY_LIST_TABLE
 *  => (tbody > PARTY_LIST_TBODY)
 */
fn parse_table(cursor: &mut Traceable<Children<Node>>) -> Result<PartyList, String> {
   let eref = element::parse("tbody")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_tbody(&mut cursor)
}

/*
 * PARTY_LIST_TBODY
 *  => (tr > PARTY_LIST_TR)
 */
fn parse_tbody(cursor: &mut Traceable<Children<Node>>) -> Result<PartyList, String> {
   let eref = element::parse("tr")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_tr(&mut cursor)
}

/*
 * PARTY_LIST_TR
 *  => PARTY _VS_IMG PARTY
 */
fn parse_tr(cursor: &mut Traceable<Children<Node>>) -> Result<PartyList, String> {
   let alpha_party = party::parse(cursor)?;
   parse_vs_img(cursor)?;
   let bravo_party = party::parse(cursor)?;
   Ok(PartyList {alpha_party, bravo_party})
}

/*
 * _VS_IMG
 *  => td
 */
fn parse_vs_img(cursor: &mut Traceable<Children<Node>>) -> Result<(), String> {
   element::ignore("td")(cursor)?;
   Ok(())
}
