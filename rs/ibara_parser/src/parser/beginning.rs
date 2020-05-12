extern crate scraper;
extern crate ego_tree;

use std::iter::{Iterator, Peekable};
use scraper::Node;
use ego_tree::NodeRef;
use crate::parser::{br, text};

/*
 * BEGINNING
 *  => BR* IMG BEGINNING_MAIN IMG
 */
pub fn parse<'a, T: Iterator<Item=NodeRef<'a, Node>>>(cursor: &mut Peekable<T>) -> Option<String> {
   text::skip_text(cursor);
   is_br(br::parse(cursor));
   text::skip_text(cursor);
   is_br(br::parse(cursor));
   text::skip_text(cursor);
   is_br(br::parse(cursor));
   text::skip_text(cursor);
   is_br(br::parse(cursor));
   text::skip_text(cursor);
   is_br(br::parse(cursor));
   text::skip_text(cursor);
   is_br(br::parse(cursor));
   return Some("ok".to_string());
}

fn is_br(ret: Option<()>) -> () {
   match ret {
      Some(()) => println!("yes"),
      None => println!("no"),
   }
}