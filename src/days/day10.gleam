import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day10.txt")
  let data = parse(content)

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

fn parse(data: String) {
  let data =
    data
    |> string.split("\n")
    |> list.map(fn(x) { x |> int.parse |> result.unwrap(-1) })

  let zero_prepended =
    data
    |> list.prepend(0)

  zero_prepended
  |> list.prepend(
    list.reduce(with: int.max, over: zero_prepended)
    |> result.unwrap(0)
    |> int.add(3),
  )
  |> list.sort(int.compare)
}

fn part1(data: List(Int)) {
  let res =
    data
    |> list.window_by_2
    |> list.fold(#(0, 0, 0), fn(acc, current) {
      case current.1 - current.0 {
        1 -> #(acc.0 + 1, acc.1, acc.2)
        2 -> #(acc.0, acc.1 + 1, acc.2)
        3 -> #(acc.0, acc.1, acc.2 + 1)
        _ -> acc
      }
    })

  res.0 * res.2
}

fn process_part2(
  from: Int,
  data: List(Int),
  cache: dict.Dict(Int, Int),
) -> #(dict.Dict(Int, Int), Int) {
  let computed = case list.length(data) {
    1 -> {
      case list.first(data) |> result.unwrap(0) == from + 3 {
        True -> #(cache, 1, 0)
        False -> #(cache, 0, 0)
      }
    }
    _ -> {
      data
      |> list.take_while(fn(x) { x - from <= 3 })
      |> list.fold(#(cache, 0, 1), fn(acc, x) {
        case dict.has_key(acc.0, x) {
          True -> {
            #(
              acc.0,
              dict.get(acc.0, x) |> result.unwrap(0) |> int.add(acc.1),
              acc.2 + 1,
            )
          }
          False -> {
            let x = process_part2(x, list.drop(data, acc.2), acc.0)
            #(dict.merge(acc.0, x.0), acc.1 + x.1, acc.2 + 1)
          }
        }
      })
    }
  }

  let res = dict.from_list([#(from, computed.1)])
  #(dict.merge(computed.0, res), computed.1)
}

fn part2(data) {
  process_part2(0, list.drop(data, 1), dict.new())
  |> fn(x) { x.0 |> dict.get(0) }
  |> result.unwrap(0)
}
