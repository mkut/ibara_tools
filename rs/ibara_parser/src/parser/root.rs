extern crate scraper;

use scraper::ElementRef;
use crate::parser::beginning;

/*
 * ROOT
 *  => div.MXM > BEGINNING TURN* ENDING BR*
 */
pub fn parse(eref: &ElementRef) -> Option<String> {
   let mut children = eref.children().peekable();
   beginning::parse(&mut children);

   return Some("ok".to_string());
}