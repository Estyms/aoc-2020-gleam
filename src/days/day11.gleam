import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/otp/task
import gleam/result
import gleam/string
import simplifile

pub type Cell {
  Occupied
  Free
}

pub type Coord {
  Coord(x: Int, y: Int)
}

pub type CellCoord {
  CellCoord(cell: Cell, coord: Coord)
}

fn serialize_state(lst: List(CellCoord)) {
  lst
  |> list.map(fn(c) {
    case c.cell {
      Occupied -> "#"
      Free -> "L"
    }
  })
  |> string.join("")
}

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day11.txt")
  let data = parse(content)

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

fn parse(data: String) {
  data
  |> string.split("\n")
  |> list.fold(#([], 0), fn(row_acc, l) {
    l
    |> string.to_graphemes
    |> list.fold(#([], 0), fn(col_acc, c) {
      case c {
        "L" -> #(
          list.prepend(
            col_acc.0,
            CellCoord(cell: Free, coord: Coord(x: row_acc.1, y: col_acc.1)),
          ),
          col_acc.1 + 1,
        )
        _ -> #(col_acc.0, col_acc.1 + 1)
      }
    })
    |> fn(x) { #(list.concat([row_acc.0, x.0]), row_acc.1 + 1) }
  })
  |> fn(x) { x.0 }
}

fn is_neighbour(cell: CellCoord) {
  case cell {
    CellCoord(Occupied, _) -> True
    _ -> False
  }
}

fn count_neighbours(current: Coord, board: List(CellCoord)) {
  board
  |> list.filter(fn(x) {
    let CellCoord(_, Coord(nx, ny)) = x
    case int.absolute_value(nx - current.x) {
      1 ->
        case int.absolute_value(ny - current.y) {
          1 -> True
          0 -> True
          _ -> False
        }
      0 -> {
        case int.absolute_value(ny - current.y) {
          1 -> True
          _ -> False
        }
      }
      _ -> False
    }
  })
  |> list.count(is_neighbour)
}

fn process_turn(data: List(CellCoord)) {
  data
  |> list.sized_chunk(
    data
    |> list.length
    |> int.floor_divide(28)
    |> result.unwrap(1)
    |> int.floor_divide(list.length(data), _)
    |> result.unwrap(1),
  )
  |> list.map(fn(lst) {
    task.async(fn() {
      lst
      |> list.map(fn(x) {
        case x.cell, count_neighbours(x.coord, data) {
          Free, 0 -> CellCoord(Occupied, x.coord)
          Free, _ -> x

          Occupied, n -> {
            case n >= 4 {
              True -> CellCoord(Free, x.coord)
              False -> x
            }
          }
        }
      })
    })
  })
  |> list.map(task.await_forever)
  |> list.concat
}

fn run_part1(data: List(CellCoord), last_state: String) {
  let new_state = process_turn(data)
  let serialized = serialize_state(new_state)

  serialized
  |> string.compare(last_state)
  |> fn(x) {
    case x {
      order.Eq -> new_state
      _ -> run_part1(new_state, serialized)
    }
  }
}

fn part1(data: List(CellCoord)) {
  run_part1(data, serialize_state(data))
  |> list.count(fn(x) {
    case x.cell {
      Occupied -> True
      _ -> False
    }
  })
}

fn part2(_data) {
  Nil
}
