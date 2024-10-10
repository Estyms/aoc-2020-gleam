import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import simplifile
import utils/utils

type Opcode {
  NOP(Int)
  ACC(Int)
  JMP(Int)
}

type MachineState {
  MachineState(
    pc: Int,
    acc: Int,
    visited: Dict(Int, Int),
    program: List(Opcode),
  )
}

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day8.txt")
  let data = parse(content)

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

fn parse_instruction(data: String) {
  let assert Ok(#(opcode, value)) = data |> string.split_once(" ")
  let value =
    value
    |> fn(x) {
      case string.starts_with(x, "+") {
        True -> string.drop_left(x, 1) |> int.parse() |> result.unwrap(0)
        False ->
          string.drop_left(x, 1)
          |> int.parse()
          |> result.unwrap(0)
          |> int.negate
      }
    }

  case opcode {
    "nop" -> NOP(value)
    "jmp" -> JMP(value)
    "acc" -> ACC(value)
    _ -> NOP(0)
  }
}

fn parse(data: String) {
  data
  |> string.split("\n")
  |> list.map(parse_instruction)
}

fn process_instruction(opcode: Opcode, state: MachineState) -> MachineState {
  case opcode {
    NOP(_) -> {
      MachineState(state.pc + 1, state.acc, state.visited, state.program)
    }

    ACC(val) -> {
      MachineState(state.pc + 1, state.acc + val, state.visited, state.program)
    }

    JMP(val) -> {
      MachineState(state.pc + val, state.acc, state.visited, state.program)
    }
  }
}

fn execute_machine(state: MachineState) {
  let visited = case dict.has_key(state.visited, state.pc) {
    True -> {
      state.visited
      |> dict.get(state.pc)
      |> result.unwrap(0)
      |> int.add(1)
      |> dict.insert(state.visited, state.pc, _)
    }
    False -> {
      state.visited
      |> dict.insert(state.pc, 1)
    }
  }

  let state = MachineState(state.pc, state.acc, visited, state.program)

  case { dict.get(state.visited, state.pc) |> result.unwrap(0) } > 1 {
    True -> state
    False -> {
      state.program
      |> utils.list_get_at(state.pc)
      |> fn(x) {
        case x {
          Error(_) -> state
          Ok(op) ->
            op
            |> process_instruction(state)
            |> execute_machine
        }
      }
    }
  }
}

fn part1(data: List(Opcode)) {
  {
    MachineState(0, 0, dict.new(), data)
    |> execute_machine
  }.acc
}

fn part2(data: List(Opcode)) {
  data
  |> utils.list_find_indexes(fn(x) {
    case x {
      JMP(_) -> True
      _ -> False
    }
  })
  |> list.map(fn(idx) {
    let assert Ok(a) = utils.list_set_at(data, idx, NOP(0))
    a
  })
  |> list.find(fn(program) {
    MachineState(0, 0, dict.new(), program)
    |> execute_machine()
    |> fn(x) { x.pc >= list.length(program) }
  })
  |> fn(x) {
    let assert Ok(program) = x
    execute_machine(MachineState(0, 0, dict.new(), program)).acc
  }
}
