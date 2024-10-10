import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day1.txt")

  let data =
    content
    |> string.split(on: "\n")
    |> list.map(fn(x) {
      let assert Ok(y) = int.parse(x)
      y
    })

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

fn part1(data: List(Int)) -> Result(Int, Nil) {
  data
  |> list.combinations(2)
  |> list.find_map(fn(x: List(Int)) {
    case x {
      [a, b, ..] ->
        case a + b {
          2020 -> Ok(a * b)
          _ -> Error(Nil)
        }
      _ -> Error(Nil)
    }
  })
}

fn part2(data: List(Int)) -> Result(Int, Nil) {
  data
  |> list.combinations(3)
  |> list.find_map(fn(x: List(Int)) {
    case x {
      [a, b, c, ..] ->
        case a + b + c {
          2020 -> Ok(a * b * c)
          _ -> Error(Nil)
        }
      _ -> Error(Nil)
    }
  })
}
