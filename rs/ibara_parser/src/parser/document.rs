extern crate scraper;

use scraper::{Html, Selector};
use crate::data::traceable::Traceable;
use crate::parser::root;

pub fn parse(document: &Html) -> Result<String, String> {
   let root_selector = Selector::parse("div.MXM").unwrap();
   let root = document.select(&root_selector).next().unwrap();
   let mut children = root.children();
   let mut cursor = Traceable::new(&mut children);

   return root::parse(&mut cursor);
}

/*
 * ROOT
 *  => div.MXM > BEGINNING TURN* ENDING BR*
 */