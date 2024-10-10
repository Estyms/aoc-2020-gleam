import gleam/io
import simplifile

pub fn start() -> Nil {
  let assert Ok(content) = simplifile.read("inputs/day{number}.txt")
  let data = parse(content)

  let _ = io.debug(part1(data))
  let _ = io.debug(part2(data))

  Nil
}

fn parse(_data: String) {
  Nil
}

fn part1(_data) {
  Nil
}

fn part2(_data) {
  Nil
}
