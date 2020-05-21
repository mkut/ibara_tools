pub struct PartyList {
   pub alpha_party: Party,
   pub bravo_party: Party,
}

pub struct Party {
   pub name: String,
   pub members: Vec<PartyMember>,
}

pub struct PartyMember {
   pub eno: u32,
   pub name: String,
}