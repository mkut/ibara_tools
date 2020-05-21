extern crate scraper;
extern crate ego_tree;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::general::element;
use crate::parser::party_list::{party_member_eno, party_member_name};
use crate::parser::party_list::models::PartyMember;

/*
 * PARTY_MEMBER
 *  => (tr > PARTY_MEMBER_MAIN)
 */
pub fn parse(cursor: &mut Traceable<Children<Node>>) -> Result<PartyMember, String> {
   let eref = element::parse("tr")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_main(&mut cursor)
}

/*
 * PARTY_MEMBER_MAIN
 *  => PARTY_MEMBER_INFO PARTY_MEMBRE_ICON
 */
fn parse_main(cursor: &mut Traceable<Children<Node>>) -> Result<PartyMember, String> {
   let party_member = parse_info(cursor)?;
   parse_icon(cursor)?;
   Ok(party_member)
}

/*
 * PARTY_MEMBER_INFO
 *  => (td > PARTY_MEMBER_INFO_MAIN)
 */
fn parse_info(cursor: &mut Traceable<Children<Node>>) -> Result<PartyMember, String> {
   let eref = element::parse("td")(cursor)?;
   let mut children = eref.children();
   let mut cursor = Traceable::new(&mut children);
   parse_info_main(&mut cursor)
}

/*
 * PARTY_MEMBER_INFO_MAIN
 *  => PARTY_MEMBER_ENO PARTY_MEMBER_NAME
 */
fn parse_info_main(cursor: &mut Traceable<Children<Node>>) -> Result<PartyMember, String> {
   let eno = party_member_eno::parse(cursor)?;
   let name = party_member_name::parse(cursor)?;
   Ok(PartyMember {eno, name})
}

/*
 * PARTY_MEMBER_ICON
 *  => (td > PARTY_MEMBER_ICON_MAIN)
 */
fn parse_icon(cursor: &mut Traceable<Children<Node>>) -> Result<(), String> {
   element::ignore("td")(cursor)?;
   Ok(())
}


