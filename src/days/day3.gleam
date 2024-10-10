import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile
import utils/utils

type SlopeIterator {
  SlopeIterator(index: Int, tree_count: Int)
}

type Slope {
  Slope(down: Int, right: Int)
}

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day3.txt")
  let data = parse(content)

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

fn parse(data: String) -> List(String) {
  let splitted = string.split(data, "\n")

  let height =
    splitted
    |> list.length
    |> int.to_float

  let width =
    splitted
    |> list.first
    |> result.unwrap("")
    |> string.length
    |> int.to_float

  let to_multiply_by =
    height /. width
    |> float.ceiling
    |> float.round

  splitted
  |> list.map(fn(x) { string.repeat(x, 7 * to_multiply_by) })
}

fn calculate_tree_on_slope(data: List(String), slope: Slope) -> Int {
  let si =
    data
    |> list.sized_chunk(slope.down)
    |> list.map(fn(x) { x |> list.first |> result.unwrap("") })
    |> list.drop(1)
    |> list.fold(SlopeIterator(slope.right, 0), fn(slope_iter, str) {
      let new_tree_count = case
        utils.get_char_at_index(str, slope_iter.index) == "#"
      {
        True -> slope_iter.tree_count + 1
        False -> slope_iter.tree_count
      }
      SlopeIterator(slope_iter.index + slope.right, new_tree_count)
    })

  si.tree_count
}

fn part1(data: List(String)) {
  calculate_tree_on_slope(data, Slope(2, 1))
}

fn part2(data) {
  [Slope(1, 1), Slope(1, 3), Slope(1, 5), Slope(1, 7), Slope(2, 1)]
  |> list.map(calculate_tree_on_slope(data, _))
  |> list.reduce(fn(a, b) { a * b })
  |> result.unwrap(-1)
}
