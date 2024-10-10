import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/regex
import gleam/result
import gleam/string
import simplifile

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day4.txt")
  let data = parse(content)

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

fn parse_passport(passport: String) {
  passport
  |> string.split(" ")
  |> list.map(fn(field) {
    let field = field |> string.split(":")
    let key = field |> list.first |> result.unwrap("")
    let value = field |> list.last |> result.unwrap("")
    #(key, value)
  })
  |> dict.from_list
}

fn parse(data: String) {
  let passports =
    data
    |> string.split("\n\n")
    |> list.map(string.replace(_, "\n", " "))

  passports
  |> list.map(parse_passport)
}

fn validate_all_fields(passport: Dict(String, String)) {
  ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]
  |> list.all(dict.has_key(passport, _))
}

fn validate_fields(passport: Dict(String, String)) -> Bool {
  let parse_int = fn(x: String) {
    case string.length(x) {
      4 -> x
      _ -> "0"
    }
    |> int.parse
    |> result.unwrap(0)
  }

  passport
  |> dict.map_values(fn(k, v) {
    case k {
      "byr" -> {
        let y = parse_int(v)
        y >= 1920 && y <= 2002
      }

      "iyr" -> {
        let y = parse_int(v)
        y >= 2010 && y <= 2020
      }

      "eyr" -> {
        let y = parse_int(v)
        y >= 2020 && y <= 2030
      }

      "hgt" -> {
        let assert Ok(rgx) =
          regex.from_string("^(1([5-8][0-9]|9[0-3])cm|(59|6[0-9]|7[0-6])in)$")
        regex.check(rgx, v)
      }

      "hcl" -> {
        let assert Ok(rgx) = regex.from_string("^#[0-9a-f]{6}$")
        regex.check(rgx, v)
      }

      "ecl" -> {
        ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
        |> list.contains(v)
      }

      "pid" -> {
        let assert Ok(rgx) = regex.from_string("^[0-9]{9}$")
        regex.check(rgx, v)
      }

      "cid" -> True

      _ -> False
    }
  })
  |> dict.values
  |> list.all(fn(x) { x == True })
}

fn validate_password(passport: Dict(String, String)) {
  case validate_all_fields(passport) {
    True -> validate_fields(passport)
    False -> False
  }
}

fn part1(data: List(Dict(String, String))) {
  data
  |> list.count(validate_all_fields)
}

fn part2(data) {
  data
  |> list.count(validate_password)
}
