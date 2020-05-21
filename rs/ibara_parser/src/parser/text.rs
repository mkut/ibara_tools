extern crate scraper;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::peekable::Peekable;
use crate::parser::combinator::repeated::repeated;

pub fn parse(cursor: &mut Peekable<Children<Node>>) -> Result<String, String> {
   match cursor.next() {
      Some(val) => match val.value() {
         Node::Text(t) => Ok(format!("{}", t.text)),
         _ => Err("Unexpected node is found, but text node is expected.".to_string())
      },
      None => Err("Next node is not found, but text node is expected.".to_string()),
   }
}

pub fn skip_text(cursor: &mut Peekable<Children<Node>>) -> () {
   repeated(&parse, cursor);
}