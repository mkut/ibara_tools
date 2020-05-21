pub struct Traceable<T> {
   working: T,
   steps_ahead: u32,
}

impl<T: Iterator + Clone> Iterator for Traceable<T> {
   type Item = T::Item;
   fn next(&mut self) -> Option<T::Item> {
      self.steps_ahead += 1;
      self.working.next()
   }
}

impl<T: Iterator + Clone> Traceable<T> {
   pub fn new(original: &mut T) -> Traceable<T> {
      let working = original.clone();
      let steps_ahead = 0;
      Traceable {working, steps_ahead}
   }

   pub fn commit<I: Iterator>(&mut self, original: &mut I) -> () {
      for _ in (0..self.steps_ahead).enumerate() {
         original.next();
      }
   }

   pub fn borrow_working(&mut self) -> &mut T {
      &mut self.working
   }
}