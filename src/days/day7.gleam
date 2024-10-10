import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type Amount {
  Amount(name: String, amount: Int)
}

type Rule {
  Rule(name: String, contains: List(Amount))
}

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day7.txt")
  let data = parse(content)

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

fn process_name_and_count(str: String) {
  let assert Ok(item) =
    str
    |> string.split_once(" ")

  item
  |> fn(x) {
    #(
      x.1 |> string.split(" bag") |> list.first() |> result.unwrap(""),
      int.parse(x.0) |> result.unwrap(0),
    )
  }
  |> fn(x) { Amount(x.0, x.1) }
}

fn process_rule(rule: String) -> Rule {
  let assert [name, includes] =
    rule
    |> string.split(" bags contain ")

  let amounts = case string.starts_with(includes, "no ") {
    True -> []
    False -> {
      includes
      |> string.drop_right(1)
      |> string.split(", ")
      |> list.map(process_name_and_count)
    }
  }

  Rule(name, amounts)
}

fn parse(data: String) {
  data
  |> string.split("\n")
  |> list.map(process_rule)
}

fn propagate_rule(rule_amount: #(Int, Rule), rules: List(Rule)) -> List(Amount) {
  { rule_amount.1 }.contains
  |> list.map(fn(x) {
    list.find(rules, fn(y) { y.name == x.name })
    |> result.unwrap(Rule("", []))
    |> fn(y) { #(x.amount, y) }
  })
  |> list.map(propagate_rule(_, rules))
  |> list.concat()
  |> list.append({ rule_amount.1 }.contains)
  |> list.map(fn(x) { Amount(x.name, x.amount * rule_amount.0) })
}

fn part1(data: List(Rule)) {
  data
  |> list.map(fn(x) { propagate_rule(#(1, x), data) })
  |> list.count(fn(x) {
    x
    |> list.any(fn(y) { y.name == "shiny gold" })
  })
}

fn part2(data) {
  data
  |> list.map(fn(x: Rule) { #(x.name, propagate_rule(#(1, x), data)) })
  |> list.find(fn(x) { { x.0 } == "shiny gold" })
  |> result.unwrap(#("", []))
  |> fn(x) {
    x.1
    |> list.fold(0, fn(a, b) { a + b.amount })
  }
}
