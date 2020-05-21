extern crate scraper;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::peekable::Peekable;
use crate::parser::{text};

/*
 * ELEMENT_NAME
 *  => element_name
 */
/*
pub fn parse(element_name: &str, cursor: &mut Peekable<Children<Node>>) -> Result<(), String> {
   text::skip_text(cursor);
   match cursor.next() {
      Some(val) => match val.value() {
         Node::Element(e) => {
            if e.name() == element_name { Ok(()) }
            else {
               Err(format!("Unexpected element '{}' is found, but element '{}' is expected.", e.name(), element_name))
            }
         },
         _ => Err(format!("Unexpected node is found, but element '{}' is expected.", element_name)),
      },
      None => Err(format!("Next node is not found, but element '{}' is expected.", element_name))
   }
}
*/

pub fn parse(element_name: &str) -> impl Fn(&mut Peekable<Children<Node>>) -> Result<(), String> + '_ {
   move |cursor| {
      text::skip_text(cursor);
      match cursor.next() {
         Some(val) => match val.value() {
            Node::Element(e) => {
               if e.name() == element_name { Ok(()) }
               else {
                  Err(format!("Unexpected element '{}' is found, but element '{}' is expected.", e.name(), element_name))
               }
            },
            _ => Err(format!("Unexpected node is found, but element '{}' is expected.", element_name)),
         },
         None => Err(format!("Next node is not found, but element '{}' is expected.", element_name))
      }
   }
}