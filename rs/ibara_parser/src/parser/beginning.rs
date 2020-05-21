extern crate scraper;
extern crate ego_tree;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::general::element;
use crate::parser::party_list::party_list;
use crate::parser::combinator::repeated::repeated;

/*
 * BEGINNING
 *  => BR*
 *     IMG
 *     (div.R870 > BEGINNING_MAIN)
 *     IMG
 */
pub fn parse(cursor: &mut Traceable<Children<Node>>) -> Result<String, String> {
   repeated(&element::ignore("br"))(cursor);
   element::ignore("img")(cursor)?;
   {
      let eref = element::parse("div")(cursor)?;
      let mut children = eref.children();
      let mut cursor = Traceable::new(&mut children);
      let _ = parse_main(&mut cursor)?;
   }
   element::ignore("img")(cursor)?;
   Ok("ok".to_string())
}

/*
 * BEGINNING_MAIN
 *  => IMG
 *     PARTY_LIST
 *     INITIATIVE_CHECK
 *     PLAYER_ENTRY
 *     PASSIVE_TRIGGER*
 */
fn parse_main(cursor: &mut Traceable<Children<Node>>) -> Result<(), String> {
   element::ignore("img")(cursor)?;
   let party_list = party_list::parse(cursor)?;
   println!("{}", party_list.alpha_party.name);
   println!("{}", party_list.bravo_party.name);
   return Ok(());
}
