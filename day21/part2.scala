
import scala.io.Source
import scala.collection.immutable.{Vector, Set}

case class Food(ingredients: Set[String], allergens: Set[String])

object Food {

  private val lineRegexp = """([a-z ]+) \(contains ([a-z, ]+)\)""".r

  def parse(line: String): Food = {
    line match {
      case lineRegexp(ingredients, allergens) => {
        Food(ingredients.split(" ").toSet, allergens.split(", ").toSet)
      }
      case _ => {
        throw new Exception(f"Invalid line $line")
      }
    }
  }

}

def allAllergens(foods: Iterable[Food]): Set[String] =
  foods.map { _.allergens }.fold (Set()) { _ | _ }

def allIngredients(foods: Iterable[Food]): Set[String] =
  foods.map { _.ingredients }.fold (Set()) { _ | _ }

def binaryFold[A](bin: (A, A) => A)(a: Option[A], b: Option[A]): Option[A] =
  (a, b) match {
    case (None, None) => None
    case (None, Some(b)) => Some(b)
    case (Some(a), None) => Some(a)
    case (Some(a), Some(b)) => Some(bin(a, b))
  }

def assign(constraints: Map[String, Set[String]]): Option[Map[String, String]] =
  assignImpl(constraints.toList, Map(), Set())

def assignImpl(constraints: List[(String, Set[String])], acc: Map[String, String], used: Set[String]):
    Option[Map[String, String]] =
  constraints match {
    case Nil => Some(acc)
    case ((alg, ingrs) :: cs) =>
      (
        for (ingr <- ingrs &~ used) yield assignImpl(cs, acc + (alg -> ingr), used + ingr)
      ).fold(None) { _ orElse _ }
  }

val lines = Source.fromFile("input.txt").getLines()
val foods = lines.map(Food.parse _).to[Vector]
val allergens = allAllergens(foods)
val constraints = (
  for (allergen <- allergens)
  yield (allergen, foods
    .map { f => if (f.allergens.contains(allergen)) Some(f.ingredients) else None }
    .fold(None)(binaryFold { _ & _ })
    .get) // We're only using allergens that actually appear, so this will always be Some at the end
).toMap
val assignments = assign(constraints).get // If there's no solution, then go ahead and throw
                                          // because the puzzle is flawed
val canonical = assignments.toVector.sortBy(_._1).map(_._2).mkString(",")

println(canonical)
