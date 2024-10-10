import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile

type SeatRange {
  SeatRange(
    s_row: Int,
    e_row: Int,
    keep_row: Int,
    s_col: Int,
    e_col: Int,
    keep_col: Int,
  )
}

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day5.txt")
  let data = parse(content)

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

fn parse(data: String) {
  data
  |> string.split("\n")
  |> list.map(string.to_graphemes)
}

fn get_seat_id(seat_code: List(String)) {
  seat_code
  |> list.fold(SeatRange(0, 127, 0, 0, 7, 0), fn(sr, letter) {
    case letter {
      "F" -> {
        let new_value = sr.e_row - { { sr.e_row - sr.s_row + 1 } / 2 }
        SeatRange(
          sr.s_row,
          new_value,
          sr.s_row,
          sr.s_col,
          sr.e_col,
          sr.keep_col,
        )
      }
      "B" -> {
        let new_value = sr.s_row + { { sr.e_row - sr.s_row + 1 } / 2 }
        SeatRange(
          new_value,
          sr.e_row,
          sr.e_row,
          sr.s_col,
          sr.e_col,
          sr.keep_col,
        )
      }
      "L" -> {
        let new_value = sr.e_col - { { sr.e_col - sr.s_col + 1 } / 2 }
        SeatRange(
          sr.s_row,
          sr.e_row,
          sr.keep_row,
          sr.s_col,
          new_value,
          sr.s_col,
        )
      }
      "R" -> {
        let new_value = sr.s_col + { { sr.e_col - sr.s_col + 1 } / 2 }
        SeatRange(
          sr.s_row,
          sr.e_row,
          sr.keep_row,
          new_value,
          sr.e_col,
          sr.e_col,
        )
      }
      _ -> sr
    }
  })
  |> fn(sr) { sr.keep_row * 8 + sr.keep_col }
}

fn part1(data: List(List(String))) {
  data
  |> list.map(get_seat_id)
  |> list.reduce(int.max)
}

fn part2(data) {
  let seat_ids =
    data
    |> list.map(get_seat_id)

  seat_ids
  |> list.combinations(2)
  |> list.find(fn(x) {
    case x {
      [a, b] -> {
        case int.max(a, b) - int.min(a, b) == 2 {
          True -> !list.contains(seat_ids, a + 1)
          False -> False
        }
      }
      _ -> False
    }
  })
  |> result.unwrap([])
  |> fn(x) { list.first(x) |> result.unwrap(0) |> int.add(1) }
}
