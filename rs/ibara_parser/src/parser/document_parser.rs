extern crate html5ever;
extern crate markup5ever_rcdom as rcdom;

use rcdom::{NodeData, Handle};

pub fn parse_document(node: &Handle) -> String {
   let document = node.children.borrow();
   let html = document[0].children.borrow();
   let body = html[2].children.borrow();
   let al = body[1].children.borrow();
   let mxm = al[3].children.borrow();
   let r870 = mxm[10].children.borrow();
   let center = r870[11].children.borrow();
   let table = center[1].children.borrow();
   let tbody = table[0].children.borrow();
   let tr = tbody[0].children.borrow();
   let td = tr[1].children.borrow();
   let b = td[1].children.borrow();

   if let NodeData::Text { ref contents } = b[0].data {
      let text = contents.borrow();
      let ret = format!("{}", text);
      return ret
   }
   return "".to_string();
}