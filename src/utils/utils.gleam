import gleam/int
import gleam/list
import gleam/result
import gleam/string

// Gets a char at an index
pub fn get_char_at_index(str: String, idx: Int) -> String {
  let assert Ok(char) =
    str
    |> string.to_graphemes
    |> list_get_at(idx)

  char
}

// Gets item at index in a list
pub fn list_get_at(list: List(a), index: Int) -> Result(a, String) {
  case index {
    0 -> {
      case list {
        [x, ..] -> Ok(x)
        _ -> Error("Overflowing index")
      }
    }
    _ -> {
      case list {
        [_, ..y] -> list_get_at(y, index - 1)
        _ -> Error("Overflowing index")
      }
    }
  }
}

// Sets value at an index in a list
pub fn list_set_at(
  liste: List(a),
  index: Int,
  value: a,
) -> Result(List(a), String) {
  let #(head, tail) =
    liste
    |> list.split(index)

  let popped = list.pop(tail, fn(_) { True })

  case popped {
    Error(_) -> Error("Index Overflow")
    Ok(new_head) -> Ok(list.concat([head, [value], new_head.1]))
  }
}

// Creates a loop, somehow
pub fn loop(
  value: a,
  condition: fn(a) -> Bool,
  post: fn(a) -> a,
  body: fn(a) -> b,
) {
  let res = body(value)
  let new_value = post(value)
  case condition(new_value) {
    False -> res
    True -> loop(new_value, condition, post, body)
  }
}

pub fn create_int_range(start: Int, end: Int) -> List(Int) {
  loop(
    [start],
    fn(lst) { list.last(lst) |> result.unwrap(0) < end },
    fn(lst) {
      list.append(lst, [list.last(lst) |> result.unwrap(0) |> int.add(1)])
    },
    fn(lst) { lst },
  )
}

// Find indexes of items in a list that satisfies a predicate
pub fn list_find_indexes(liste: List(a), predicate: fn(a) -> Bool) -> List(Int) {
  let range = create_int_range(0, list.length(liste))

  range
  |> list.map(fn(idx) {
    let assert Ok(val) = list_get_at(liste, idx)

    #(idx, predicate(val))
  })
  |> list.filter(fn(x) { x.1 == True })
  |> list.map(fn(x) { x.0 })
}
