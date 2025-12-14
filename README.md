# MyNib
**MyNib (My Nix Library)** is a mini lil library of utilities I find
myself frequently rewriting.


## Conventions
1. *"Private"* attribute set values: start and end with underscores, ie `MyType._value_`
2. Modules: use the `useMod` and `mkMod` nib provides
3. Avoid the `with` keyword like your life depends on it!!
      Most LSPs I've tried have handled them terribly. Not to mention it absolutely
      pollutes the scoped namespace ;-; Just stick to writing out `let ... in`. And **iff**
      you **absolutely** need it to condense code in a meaningful way, then isolate its
      use to a very **very** small scope. Not your entire file!
4. All names/identifiers should be written in **camelCase**, except *"Types"* (aka specifically structured attribute sets).
      Which should be written in **PascalCase**.
