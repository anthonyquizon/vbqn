lf←@+10‿13
l←⟨⟩ ⋄ ln←⟨⟩

Run ← { 
  •Show 𝕩
  repl←•ReBQN {repl⇐"loose"}
  Repl "a←10"
  •Show Repl 𝕩
}

{ 𝕊:
    c←•term.CharB "/dev/fd/0"
    l∾↩<c
    #{𝕊: ln∾↩<l ⋄ l↩⟨⟩}⍟(1⊸≡) ∨´c=lf
    {𝕊: Run ¯1↓l ⋄ l↩⟨⟩}⍟(1⊸≡) ∨´c=lf
}•_while_ 1 @

