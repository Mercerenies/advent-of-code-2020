
use std::collections::VecDeque;
use std::fmt::{self, Display};
use std::borrow::Borrow;
use std::io::{Read, BufReader, BufRead};
use std::fs::File;

type Card = i32;

struct PlayerDeck(VecDeque<Card>);

impl PlayerDeck {

  fn new() -> PlayerDeck {
    PlayerDeck(VecDeque::new())
  }

  fn draw_card(&mut self) -> Card {
    self.0.pop_front().unwrap_or(0)
  }

  fn push_card(&mut self, card: Card) {
    self.0.push_back(card)
  }

  fn is_empty(&self) -> bool {
    self.0.is_empty()
  }

  fn iter(&self) -> impl DoubleEndedIterator<Item=&Card> {
    self.0.iter()
  }

  fn score(&self) -> i32 {
    self.iter().rev().zip(1..).map(|(x, y)| x * y).sum()
  }

}

impl Display for PlayerDeck {

  fn fmt(&self, fmt: &mut fmt::Formatter) -> fmt::Result {
    write!(fmt, "{}", join(self.0.iter(), ","))
  }

}

fn join<T, B>(iter: impl Iterator<Item=T>, delim: &B) -> String
where B : Borrow<str> + ?Sized,
      T : ToString {
  let elts = iter.map(|x| x.to_string()).collect::<Vec<_>>();
  elts.join(delim.borrow())
}

fn parse_deck(src: &mut impl Iterator<Item=String>) -> PlayerDeck {
  // Skip first line (Player declaration)
  src.next().unwrap();

  let mut deck = PlayerDeck::new();
  loop {
    match src.next() {
      None => break,
      Some(s) =>
        if s == "" {
          break
        } else {
          deck.push_card(s.parse().unwrap())
        },
    }
  }
  deck
}

fn parse_decks(src: &mut impl Read) -> (PlayerDeck, PlayerDeck) {
  let mut lines = BufReader::new(src).lines().map(|x| x.unwrap());
  let deck1 = parse_deck(&mut lines);
  let deck2 = parse_deck(&mut lines);
  (deck1, deck2)
}

fn is_game_over(deck1: &PlayerDeck, deck2: &PlayerDeck) -> bool {
  deck1.is_empty() || deck2.is_empty()
}

fn winning_deck<'a>(deck1: &'a PlayerDeck, deck2: &'a PlayerDeck) -> Option<&'a PlayerDeck> {
  if deck1.is_empty() {
    Some(deck2)
  } else if deck2.is_empty() {
    Some(deck1)
  } else {
    None
  }
}

fn play_turn(deck1: &mut PlayerDeck, deck2: &mut PlayerDeck) {
  let card1 = deck1.draw_card();
  let card2 = deck2.draw_card();
  if card1 > card2 {
    deck1.push_card(card1);
    deck1.push_card(card2);
  } else {
    deck2.push_card(card2);
    deck2.push_card(card1);
  }
}

fn play_game(deck1: &mut PlayerDeck, deck2: &mut PlayerDeck) {
  loop {
    if is_game_over(deck1, deck2) {
      return;
    }
    play_turn(deck1, deck2);
  }
}

fn main() {
  let mut file = File::open("input.txt").unwrap();
  let (mut deck1, mut deck2) = parse_decks(&mut file);
  play_game(&mut deck1, &mut deck2);
  let winner = winning_deck(&mut deck1, &mut deck2).unwrap();
  println!("{}", winner.score());
}
