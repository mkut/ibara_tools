extern crate scraper;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::peekable::Peekable;
use crate::parser::combinator::maybe::maybe;

pub fn repeated<P, R>(parser: &P, cursor: &mut Peekable<Children<Node>>) -> ()
   where P: Fn(&mut Peekable<Children<Node>>) -> Result<R, String> {
   loop {
      match maybe(parser, cursor) {
         None => { break; }
         _ => {}
      }
   }
}