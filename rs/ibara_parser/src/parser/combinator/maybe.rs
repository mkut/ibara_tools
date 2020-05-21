extern crate scraper;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::peekable::Peekable;

pub fn maybe<P, R>(parser: &P, original: &mut Peekable<Children<Node>>) -> Option<R>
   where P: Fn(&mut Peekable<Children<Node>>) -> Result<R, String> {
   let mut cursor = Peekable::new(original.borrow_working());
   match parser(&mut cursor) {
      Ok(ret) => {
         cursor.commit(original.borrow_working());
         Some(ret)
      },
      Err(_) => None,
   }
}