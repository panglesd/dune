module Paths : sig
  val root : Context.t -> Import.Path.Build.t
  val html_root : Context.t -> Import.Path.Build.t
  val odoc_support : Context.t -> Import.Path.Build.t
end
