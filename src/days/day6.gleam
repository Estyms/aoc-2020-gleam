import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day6.txt")
  let data = parse(content)

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

fn parse(data: String) {
  data
  |> string.split("\n\n")
  |> list.map(string.split(_, "\n"))
}

fn part1(data: List(List(String))) {
  data
  |> list.map(string.join(_, ""))
  |> list.map(fn(x) { list.unique(string.to_graphemes(x)) })
  |> list.map(list.length)
  |> list.reduce(int.add)
}

fn part2(data) {
  data
  |> list.map(fn(answers) {
    let questions =
      string.join(answers, "")
      |> fn(y) { list.unique(string.to_graphemes(y)) }

    questions
    |> list.count(fn(question) {
      list.all(answers, string.contains(_, question))
    })
  })
  |> list.reduce(int.add)
}
