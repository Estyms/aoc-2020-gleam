# Advent of Code 2020 - Gleam

My take at the 2020 advent of code in the [Gleam](https://github.com/gleam-lang/gleam) programming language, 4 years later

## Requirements
- Gleam

## Usage

Put your AOC inputs into an `inputs` folder at the `pwd` of the program.

The file must be named following the syntax `day{number}.txt` where `{number}` should be replaced by the day number, ie : `day7.txt` `day24.txt`

```bash
$ gleam run
What day do you wanna run ? 
# Enter the day you wanna run in the prompt
```

## Extending
There is an `src/days/day.gleam` file that exist, this file is used as a template for all other day files.

After greating a file, for example `day10.gleam`, you must add it to the `src/aoc.gleam` in the case statement, for it to be launchable with the CLI.