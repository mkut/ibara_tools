extern crate scraper;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::combinator::maybe::maybe;

pub fn repeated<P, R>(parser: &P) -> impl Fn(&mut Traceable<Children<Node>>) -> Vec<R> + '_
      where P: Fn(&mut Traceable<Children<Node>>) -> Result<R, String> {
   move |cursor| {
      loop {
         let mut ret = Vec::new();
         match maybe(parser)(cursor) {
            None => { return ret; }
            Some(r) => { ret.push(r); }
         }
      }
   }
}