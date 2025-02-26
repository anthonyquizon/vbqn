# should show vm error
a←1
Foo←{ 𝕊:
  "woo"! 𝕩
  
}

Bar ←{ 𝕊:Foo 0 }
Baz12345←{ 𝕊:Bar 1 }

Baz12345 2
