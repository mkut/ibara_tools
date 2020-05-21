pub trait DuplicateIterator: Iterator {
   type Itr;
   fn duplicate(&mut self) -> Self::Itr;
}

impl<T: Iterator + Clone> DuplicateIterator for T {
   type Itr = T;
   fn duplicate(&mut self) -> Self::Itr {
      self.clone()
   }
}