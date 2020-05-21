extern crate scraper;

use scraper::ElementRef;
use crate::data::peekable::Peekable;
use crate::parser::beginning;

/*
 * ROOT
 *  => div.MXM > BEGINNING TURN* ENDING BR*
 */
pub fn parse(eref: &ElementRef) -> Result<String, String> {
   let mut children = eref.children();
   let mut cursor = Peekable::new(&mut children);
   let result = beginning::parse(&mut cursor)?;

   return Ok(result);
}