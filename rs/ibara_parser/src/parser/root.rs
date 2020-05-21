extern crate scraper;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::beginning;

/*
 * ROOT
 *  => BEGINNING
 *     TURN*
 *     ENDING
 *     BR*
 */
pub fn parse(cursor: &mut Traceable<Children<Node>>) -> Result<String, String> {
   let result = beginning::parse(cursor)?;

   return Ok(result);
}