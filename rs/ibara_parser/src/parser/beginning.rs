extern crate scraper;
extern crate ego_tree;

use scraper::{Node, ElementRef};
use ego_tree::iter::Children;
use crate::data::peekable::Peekable;
use crate::parser::{ignored, text};
use crate::parser::combinator::repeated::repeated;

/*
 * BEGINNING
 *  => BR*6 IMG BEGINNING_MAIN IMG
 */
pub fn parse(cursor: &mut Peekable<Children<Node>>) -> Result<String, String> {
   repeated(&ignored::parse("br"), cursor);
   ignored::parse("img")(cursor)?;

   text::skip_text(cursor);
   let main_eref = ElementRef::wrap(cursor.next().unwrap()).unwrap();
   let _result = parse_main(&main_eref);
   return Ok("ok".to_string());
}
/*
 * BEGINNING_MAIN
 *  => div.R870 > IMG PARTY_LIST INITIATIVE_CHECK PLAYER_ENTRY PASSIVE_TRIGGER*
 */
fn parse_main(_eref: &ElementRef) -> Option<()> {
   return Some(());
}
