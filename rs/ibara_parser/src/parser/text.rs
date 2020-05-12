extern crate scraper;

use std::iter::{Iterator, Peekable};
use scraper::Node;
use ego_tree::NodeRef;

pub fn try_parse<'a, T: Iterator<Item=NodeRef<'a, Node>>>(cursor: &mut Peekable<T>) -> Option<String> {
   return match cursor.peek()?.value() {
      Node::Text(t) => {
         cursor.next();
         return Some(format!("<{}>", t.text));
      },
      _ => None,
   };
}

pub fn skip_text<'a, T: Iterator<Item=NodeRef<'a, Node>>>(cursor: &mut Peekable<T>) -> Option<()> {
   loop {
      let done = try_parse(cursor);
      match done {
         None => break,
         Some(text) => println!("{}", text),
      }
   }
   return Some(());
}