pub struct Peekable<T> {
   working: T,
   steps_ahead: u32,
}

impl<T: Iterator + Clone> Peekable<T> {
   pub fn new(original: &mut T) -> Peekable<T> {
      let working = original.clone();
      let steps_ahead = 0;
      Peekable {working, steps_ahead}
   }

   pub fn next(&mut self) -> Option<T::Item> {
      self.steps_ahead += 1;
      self.working.next()
   }

   pub fn commit(&mut self, original: &mut T) -> () {
      for _ in (0..self.steps_ahead).enumerate() {
         original.next();
      }
   }

   pub fn borrow_working(&mut self) -> &mut T {
      &mut self.working
   }
}