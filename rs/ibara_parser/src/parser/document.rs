extern crate scraper;

use scraper::{Html, Selector};
use crate::parser::root;

pub fn parse(document: &Html) -> Result<String, String> {
   let root_selector = Selector::parse("div.MXM").unwrap();
   let root = document.select(&root_selector).next().unwrap();

   return root::parse(&root);
}

/*
 * ROOT
 *  => div.MXM > BEGINNING TURN* ENDING BR*
 */