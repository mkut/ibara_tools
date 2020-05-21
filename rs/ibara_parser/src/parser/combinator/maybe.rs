extern crate scraper;

use scraper::Node;
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;

pub fn maybe<P, R>(parser: &P) -> impl Fn(&mut Traceable<Children<Node>>) -> Option<R> + '_
      where P: Fn(&mut Traceable<Children<Node>>) -> Result<R, String> {
   move |original| {
      let mut cursor = Traceable::new(original.borrow_working());
      match parser(&mut cursor) {
         Ok(ret) => {
            cursor.commit(original);
            Some(ret)
         },
         Err(_) => None,
      }
   }
}