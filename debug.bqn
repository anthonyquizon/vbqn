#! /usr/bin/env bqn

runtime ← •Import "_extern/bqn/rt.bqn"     # Runtime: primitives available to VM
gl      ← •Import "_extern/bqn/src/glyphs.bqn"

#compile ← gl •Import "src/compiler.bqn"  # Compiler: source → object code
compile ← gl •Import "src/compiler0.bqn"  # Compiler: source → object code
vm      ←    •Import "_extern/bqn/vm.bqn"     # VM: interprets object code

# TODO map •FFI to  bqns FFI

# Define system values later, to include BQN
#BQN ← ⟨runtime, {System 𝕩}⟩ ⊸ (Compile)
BQN ← {⟨𝕨, runtime, { System 𝕩 }⟩ (VM Compile) 𝕩}

#⌜
# System values
IsPrim ← ∊⟜runtime⌾<
Glyph ← runtime⊸⊐⌾<⊑(∾gl)˙
Decompose ← IsPrim◶⟨•Decompose,0⊸≍⟩

# Formatter
tn ← "*"⊸(∾∾⊣)¨"array"‿"function"‿"1-modifier"‿"2-modifier"‿"namespace"
Fmt‿Repr ← (•Import "_extern/bqn/src/f.bqn"){𝔽} ⟨
  •Type
  Decompose
  IsPrim◶⟨tn⊑˜•Type-2˙, Glyph⟩ # Format operation/namespace
  •Repr                        # Format number
⟩
Show ← •Out∘Fmt⊸⊢⊢

#⌜
# Evaluate
Eval←{
  0 < ≠𝕩 ?
    t ← ⊑ "-e"‿"-p" ⊐ ⊏𝕩
    # TODO add args
    f←0⊑𝕩
    dir←f/˜¬+`'/'=f
    #•Show t
    {dir⇐dir} BQN •file.Chars 0⊑𝕩
    #•Show •file.Chars 0⊑𝕩
    #Show⍟(t=1)∘BQN¨ (t<2)◶⟨•file.Chars¨, 1⊸↓⟩ 𝕩
    #𝕩
    #Show⍟(t=1)∘BQN¨ (t<2)◶⟨•file.Chars¨, 1⊸↓⟩ 𝕩
}

Import ← {
  path←𝕨.dir∾'/'∾𝕩
  Eval ⟨path⟩
}

# Lookup table
sys_names←⟨
  "bqn"‿"type"‿"glyph"‿"decompose"‿"repr"‿"fmt"‿"out"‿"show"‿"import"
   BQN ‿•Type ‿ Glyph ‿ Decompose ‿ Repr ‿ Fmt ‿•Out ‿ Show ‿ Import
⟩

FindSys ← {
  i ← 𝕨⊐𝕩
  { ! ∾⟨"Unknown system value",(1≠≠𝕩)/"s",":"⟩∾" •"⊸∾¨𝕩 }∘/⟜𝕩⍟(∨´) i=≠𝕨
  i
}
System ← {
  f←{
    #•Show 𝕩
    #•Show 𝕨
      𝕨⊸FindSys⊏𝕩˙
    }´sys_names
  #•Show 𝕨 F 𝕩
  𝕨 F 𝕩
}


Eval •args

BQN  # Return the evaluator so it can be •Include d from BQN
