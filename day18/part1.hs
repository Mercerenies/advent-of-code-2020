{-# LANGUAGE LambdaCase #-}

module Main where

import Data.Char
import Data.List(foldl')
import Data.Functor.Identity
import Control.Applicative
import Control.Monad

-- To make this thing self-contained, I won't be importing parsec or
-- the like. Instead, we'll make our own bootleg parsing monad here.

newtype ParserT s m a = ParserT { runParserT :: s -> m (Maybe (a, s)) }

type Parser = ParserT String Identity

instance Functor m => Functor (ParserT s m) where
    fmap f (ParserT p) = ParserT (\s -> fmap (fmap (\(a, s) -> (f a, s))) $ p s)

instance Monad m => Applicative (ParserT s m) where
    pure a = ParserT (\s -> pure (Just (a, s)))
    (<*>) = ap

instance Monad m => Alternative (ParserT s m) where
    empty = ParserT (\_ -> pure Nothing)
    ParserT xx <|> ParserT yy =
        ParserT (\s -> xx s >>= \case
                       Nothing -> yy s
                       Just (a, s') -> pure (Just (a, s')))

instance Monad m => Monad (ParserT s m) where
    return = pure
    ParserT xx >>= f =
        ParserT $ \s ->
            xx s >>= \case
               Nothing -> return Nothing
               Just (a, s') ->
                   let ParserT y = f a in
                   y s'

instance Monad m => MonadPlus (ParserT s m) where
    mzero = empty
    mplus = (<|>)

instance Monad m => MonadFail (ParserT s m) where
    fail _ = ParserT (\_ -> pure Nothing)

runParser :: Parser a -> String -> Maybe a
runParser p = fmap fst . runIdentity . runParserT p

zeroLengthM :: Functor m => (s -> m (Maybe a)) -> ParserT s m a
zeroLengthM f = ParserT $ \s -> fmap (fmap (\a -> (a, s))) (f s)

zeroLength :: Applicative m => (s -> Maybe a) -> ParserT s m a
zeroLength f = zeroLengthM (pure . f)

eos :: Applicative m => ParserT [c] m ()
eos = zeroLengthM (pure . guard . null)

satisfyM :: Monad m => (c -> m (Maybe a)) -> ParserT [c] m a
satisfyM f = ParserT $ \case
             [] -> pure Nothing
             (c : cs) -> f c >>= \case
                         Nothing -> pure Nothing
                         Just a -> pure (Just (a, cs))

satisfy :: Monad m => (c -> Maybe a) -> ParserT [c] m a
satisfy f = satisfyM (pure . f)

char :: (Eq c, Monad m) => c -> ParserT [c] m c
char c = satisfy (\c' -> c' <$ guard (c == c'))

-- End of bootleg parser

data Op = Plus | Times
          deriving (Show, Read, Eq, Ord, Enum, Bounded)

data AST a = Term a | Binary Op (AST a) (AST a)
             deriving (Show, Read, Eq)

digit :: Parser Char
digit = satisfy (\x -> x <$ guard (isDigit x))

term :: Parser Int
term = read <$> some digit

termOrParen :: Parser (AST Int)
termOrParen = (char '(' *> ast <* char ')') <|>
              (Term <$> term)

op :: Parser Op
op = Plus <$ char '+' <|>
     Times <$ char '*'

ast :: Parser (AST Int)
ast = do
  initial <- termOrParen
  rest <- many (liftA2 (,) op termOrParen)
  return $ foldl' (\a (op, b) -> Binary op a b) initial rest

parseAST :: String -> Maybe (AST Int)
parseAST = runParser (ast <* eos) . filter (/= ' ')

parseASTUnchecked :: String -> AST Int
parseASTUnchecked = maybe (error "bad parse") id . parseAST

eval :: Num a => AST a -> a
eval (Term a) = a
eval (Binary Plus a b) = eval a + eval b
eval (Binary Times a b) = eval a * eval b

main :: IO ()
main = do
  dat <- lines <$> readFile "input.txt"
  let asts = fmap parseASTUnchecked dat
  let answers = fmap eval asts
  print (sum answers)
