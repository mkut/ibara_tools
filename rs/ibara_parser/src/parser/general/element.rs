extern crate scraper;

use scraper::{ElementRef, Node};
use ego_tree::iter::Children;
use crate::data::traceable::Traceable;
use crate::parser::general::{text};

/*
 * ELEMENT
 *  => element
 */
pub fn parse<'a>(element_name: &'a str) -> impl Fn(&mut Traceable<Children<'a, Node>>) -> Result<ElementRef<'a>, String> + 'a {
   move |cursor| {
      text::skip_text(cursor);
      match cursor.next() {
         Some(nref) => match nref.value() {
            Node::Element(e) => {
               if e.name() == element_name { Ok(ElementRef::wrap(nref).unwrap()) }
               else {
                  Err(format!("Unexpected element '{}' is found, but element '{}' is expected.", e.name(), element_name))
               }
            },
            _ => Err(format!("Unexpected node is found, but element '{}' is expected.", element_name)),
         },
         None => Err(format!("Next node is not found, but element '{}' is expected.", element_name))
      }
   }
}

pub fn _parse_any<'a>(cursor: &mut Traceable<Children<'a, Node>>) -> Result<ElementRef<'a>, String> {
   text::skip_text(cursor);
   match cursor.next() {
      None => Err("Next node is not found, but element is expected.".to_string()),
      Some(nref) => match ElementRef::wrap(nref) {
         None => Err ("Next node is not element.".to_string()),
         Some (eref) => Ok(eref),
      }
   }
}

pub fn ignore(element_name: &str) -> impl Fn(&mut Traceable<Children<Node>>) -> Result<(), String> + '_ {
   move |cursor| {
      text::skip_text(cursor);
      match cursor.next() {
         Some(nref) => match nref.value() {
            Node::Element(e) => {
               if e.name() == element_name { Ok(()) }
               else {
                  Err(format!("Unexpected element '{}' is found, but element '{}' is expected.", e.name(), element_name))
               }
            },
            _ => Err(format!("Unexpected node is found, but element '{}' is expected.", element_name)),
         },
         None => Err(format!("Next node is not found, but element '{}' is expected.", element_name))
      }
   }
}