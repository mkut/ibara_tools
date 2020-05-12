extern crate scraper;

use std::iter::{Iterator, Peekable};
use scraper::Node;
use ego_tree::NodeRef;

/*
 * BR
 *  => br
 */
pub fn parse<'a, T: Iterator<Item=NodeRef<'a, Node>>>(cursor: &mut Peekable<T>) -> Option<()> {
   return match cursor.next()?.value() {
      Node::Element(e) => {
         if e.name() == "br" { return Some(()); }
         return None;
      },
      _ => None,
   };
}

