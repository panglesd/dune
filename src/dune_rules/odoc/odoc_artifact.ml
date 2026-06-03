open Import
open Odoc_target
open Odoc_paths

let ( ++ ) = Path.Build.relative

type t =
  { odoc_file : Path.Build.t
  ; target : Odoc_target.t
  }

let make ~target odoc_file = { odoc_file; target }
let odoc_file t = t.odoc_file

let basename t =
  Path.Build.basename t.odoc_file |> Filename.remove_extension |> Filename.to_string
;;

let odocl_file ctx t = odocl ctx t.target ++ (basename t ^ ".odocl")

let output_file ctx (output : output_format) t =
  let basename = basename t in
  let suffix = Filename.of_string_exn (extension output) in
  match t.target with
  | Lib _ ->
    (match output with
     | Html | Json ->
       let dir =
         match output with
         | Json -> json ctx t.target
         | _ -> html ctx t.target
       in
       dir ++ Stdune.String.capitalize basename ++ "index"
       |> Path.Build.extend_basename ~suffix
     | Markdown ->
       markdown ctx t.target ++ Stdune.String.capitalize basename
       |> Path.Build.extend_basename ~suffix)
  | Pkg _ ->
    let base =
      match output with
      | Markdown -> markdown ctx t.target
      | Json -> json ctx t.target
      | Html -> html ctx t.target
    in
    base ++ (basename |> String.drop_prefix ~prefix:"page-" |> Option.value_exn)
    |> Path.Build.extend_basename ~suffix
;;
