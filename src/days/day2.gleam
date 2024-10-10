import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string
import nibble.{do, return}
import nibble/lexer
import simplifile
import utils/utils

type PasswordPolicy {
  Policy(first: Int, second: Int, char: String, password: String)
}

type Token {
  Num(Int)
  Str(String)
}

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day2.txt")
  let data = parse(content)

  io.debug(part1(data))
  io.debug(part2(data))

  Nil
}

fn parse(data: String) -> List(PasswordPolicy) {
  let lexer =
    lexer.simple([
      lexer.int(Num),
      lexer.token("-", Nil)
        |> lexer.ignore(),
      lexer.token(":", Nil)
        |> lexer.ignore(),
      lexer.whitespace(Nil)
        |> lexer.ignore(),
      lexer.variable(set.new(), Str),
    ])

  let int_parser = {
    use tok <- nibble.take_map("Expect Number")
    case tok {
      Num(x) -> Some(x)
      _ -> None
    }
  }

  let string_parser = {
    use tok <- nibble.take_map("Expect String")
    case tok {
      Str(x) -> Some(x)
      _ -> None
    }
  }

  let parser = {
    use a <- do(int_parser)
    use b <- do(int_parser)
    use char <- do(string_parser)
    use password <- do(string_parser)

    return(Policy(a, b, char, password))
  }

  data
  |> string.split("\n")
  |> list.map(fn(str) {
    let assert Ok(tokens) = lexer.run(str, lexer)
    let assert Ok(policy) = nibble.run(tokens, parser)
    policy
  })
}

fn part1(data: List(PasswordPolicy)) {
  data
  |> list.filter(fn(policy) {
    string.to_graphemes(policy.password)
    |> list.count(fn(x) { x == policy.char })
    |> fn(x) { x >= policy.first && x <= policy.second }
  })
  |> list.length
}

fn process_password(policy: PasswordPolicy) -> Bool {
  let a = utils.get_char_at_index(policy.password, policy.first - 1)
  let b = utils.get_char_at_index(policy.password, policy.second - 1)
  case a == policy.char {
    True -> b != policy.char
    False -> b == policy.char
  }
}

fn part2(data) {
  data
  |> list.count(process_password)
}
