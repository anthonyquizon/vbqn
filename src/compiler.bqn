func‿mod1‿mod2 ← •args
na←¯1⊑≢alph←("aA"+⌜↕26)∾˘"àÀ"+⌜(↕23)∾24+↕7
lf←@+10‿13
charSet‿cgl←(∾ ⋈ ≠¨)⟨
  func                  # Function
  mod1                  # 1-modifier
  mod2                  # 2-modifier
  "⋄,"∾lf               # Separator
  ":;?"                 # Header punctuation
  "⇐←↩"                 # Gets
  "(){}⟨⟩[]"            # Bracket
  "‿"                   # Ligature
  "·"                   # nOthing
  # Use last character in case of UTF-16 (like dzaima/BQN)
  ¯1⊏˘11‿∘⥊"𝕊𝕏𝕎𝔽𝔾𝕤𝕩𝕨𝕣𝕗𝕘"# Input
  ".¯π∞"                # Numeric
  '0'+↕10               # Digit
  "_"∾˜⥊alph            # Alphabetic
  "•"∾(¯1↓"𝕨")∾" "∾@+9  # Whitespace (or special name prefix in UTF-16)
  "#'""@"               # Preprocessed characters
⟩
bF‿b1‿b2‿bS‿bH‿bG‿bB‿bL‿bO‿bX‿bN‿bD‿bA‿bW‿bP←⋈¨˜⟜(0»+`)cgl
M←1⊸⊑(0⊸≤∧>)-⟜⊑   # ∊ for an init,length pair 𝕩 as above

Compile ← { 𝕨 𝕊 ch:
  ln←@
  #•Show "-- compiler.bqn --"
  # TOKENIZE
  { ln↩+`ch∊lf }                                  # line numbers
  { z←¬0⌈+`(ch='#')∨-ch∊lf ⋄ ln↩z/ln ⋄ ch↩z/ch }  # remove comments

}
