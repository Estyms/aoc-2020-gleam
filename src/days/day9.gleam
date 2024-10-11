import gleam/int
import gleam/io
import gleam/list
import gleam/otp/task
import gleam/result
import gleam/string
import simplifile
import utils/utils

// Constant to set weither or not you wanna use parallel computing using OTP
const parallel = True

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day9.txt")
  let data = parse(content)

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

const preamble_size = 25

fn solve_part_2(lst: List(Int), to_find: Int) {
  let res =
    lst
    |> list.fold_until(Ok(0), fn(acc, val) {
      let new_val = { acc |> result.unwrap(0) } + val
      case new_val == to_find {
        True -> list.Stop(Ok(val))
        False ->
          case new_val > to_find {
            True -> list.Stop(Error(False))
            False -> list.Continue(Ok(new_val))
          }
      }
    })

  case res {
    Ok(val) -> {
      Ok(
        lst
        |> list.take_while(fn(x) { x != val }),
      )
    }
    Error(_) -> {
      Error(Nil)
    }
  }
}

fn parse(data: String) {
  data
  |> string.split("\n")
  |> list.map(int.parse)
  |> list.map(result.unwrap(_, 0))
  |> list.split(preamble_size)
}

fn part1(data: #(List(Int), List(Int))) {
  let #(preamble, next) = data

  let assert [answer] =
    next
    |> list.fold_until(preamble, fn(preamble, current) {
      let is_ok =
        preamble
        |> list.window(int.min(preamble_size, list.length(preamble)))
        |> list.last()
        |> result.unwrap([])
        |> list.combinations(2)
        |> list.any(fn(combi) {
          let assert [a, b] = combi
          a + b == current
        })

      case is_ok {
        True -> list.Continue(list.append(preamble, [current]))
        False -> list.Stop([current])
      }
    })
  answer
}

fn part2(data: #(List(Int), List(Int))) {
  let #(a, b) = data
  let lst = list.append(a, b)

  let to_find = part1(data)

  let assert Ok(Ok(range)) = case parallel {
    // OTP Computing
    True -> {
      utils.create_int_range(0, list.length(lst))
      |> list.map(list.drop(lst, _))
      |> list.map(fn(y) { task.async(fn() { solve_part_2(y, to_find) }) })
      |> list.map(task.await_forever)
      |> list.find(fn(x) {
        case x {
          Ok(_) -> True
          _ -> False
        }
      })
    }
    // Sequential
    False -> {
      utils.create_int_range(0, list.length(lst))
      |> list.map(list.drop(lst, _))
      |> list.map(solve_part_2(_, part1(data)))
      |> list.find(fn(x) {
        case x {
          Ok(_) -> True
          _ -> False
        }
      })
    }
  }

  let assert Ok(mini) =
    range
    |> list.reduce(int.min)

  let assert Ok(maxi) =
    range
    |> list.reduce(int.max)

  mini + maxi
}
