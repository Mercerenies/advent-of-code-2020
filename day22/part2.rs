
use std::collections::{VecDeque, HashSet};
use std::fmt::{self, Display};
use std::borrow::Borrow;
use std::io::{Read, BufReader, BufRead};
use std::fs::File;

type Card = i32;

#[derive(Clone, Copy, PartialEq, Eq)]
enum Player { Player1, Player2 }

#[derive(Clone, PartialEq, Eq, Hash)]
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

  fn len(&self) -> usize {
    self.0.len()
  }

  fn clone_top(&self, n: i32) -> PlayerDeck {
    let mut iter = self.iter();
    let mut new_deck = PlayerDeck::new();
    for _ in 0..n {
      new_deck.push_card(*iter.next().unwrap());
    }
    new_deck
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

fn is_game_over(deck1: &PlayerDeck, deck2: &PlayerDeck) -> Option<Player> {
  if deck1.is_empty() {
    Some(Player::Player2)
  } else if deck2.is_empty() {
    Some(Player::Player1)
  } else {
    None
  }
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

  let winner = {
    if deck1.len() >= card1 as usize && deck2.len() >= card2 as usize {
      let mut new_deck1 = deck1.clone_top(card1);
      let mut new_deck2 = deck2.clone_top(card2);
      play_game(&mut new_deck1, &mut new_deck2)
    } else {
      if card1 > card2 { Player::Player1 } else { Player::Player2 }
    }
  };
  match winner {
    Player::Player1 => {
      deck1.push_card(card1);
      deck1.push_card(card2);
    }
    Player::Player2 => {
      deck2.push_card(card2);
      deck2.push_card(card1);
    }
  }
}

fn play_game(deck1: &mut PlayerDeck, deck2: &mut PlayerDeck) -> Player {
  let mut known_states: HashSet<(PlayerDeck, PlayerDeck)> = HashSet::new();
  loop {
    if let Some(p) = is_game_over(deck1, deck2) {
      return p;
    } else if known_states.contains(&(deck1.clone(), deck2.clone())) {
      return Player::Player1;
    }
    known_states.insert((deck1.clone(), deck2.clone()));
    play_turn(deck1, deck2);
  }
}

fn main() {
  let mut file = File::open("input.txt").unwrap();
  let (mut deck1, mut deck2) = parse_decks(&mut file);
  let winner = play_game(&mut deck1, &mut deck2);
  let winning_deck = match winner {
    Player::Player1 => deck1,
    Player::Player2 => deck2,
  };
  println!("{}", winning_deck.score());
}
