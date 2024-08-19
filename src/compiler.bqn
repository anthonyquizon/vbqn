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
sep←⊑bS
pred←2+⊑bH
bI←bX+⋈⟜-5⋄bR←8+⊑bX
Pl←∾⟜("s"/˜1<≠)   # Pluralize
_tmpl←{∾𝕗{𝕎𝕩}¨<𝕩} # Template
# Convert characters to numbers, mostly the same as tokens
CharCode←charSet{
  FmtChar ← (1<≠)◶⟨"'"⊸(∾∾⊣), 30(⌊⟜≠↑⊢)⟜⍷⍟(<⟜≠)⊢⟩
  ErrUnknownChars←!⟨"Unknown character"⊸Pl,": ",FmtChar⟩_tmpl
  Chk ← ⊢⊣ErrUnknownChars∘(≠/⊣)⍟≢⟜(⊏⟜𝕗)
  (! "Character set conflict: "∾gf/˜0⊸∾)⍟(∨´) 1(↓=-⊸↓)gf←(g←⍋𝕗)⊏𝕗
  ⊢ Chk g⊏˜1-˜1⌈gf⍋⊢
}
swap_undo←CharCode∊⟜mod1⊸/"˜⁼"

vd←1+vi←⊑bN  # Start of identifier numbering (plus dot)
charRole←4∾˜∾⥊¨˜⟜(≠↑cgl˙)⟨1,2,3,¯1,¯1,¯3,¯1‿0,¯2,0,¬/5‿6⟩ # For first vd chars
T←⌈`× ⋄ IT←↕∘≠⊸T ⋄ I1T←(1+↕∘≠)⊸T
PN←1(∾/∾˜)(∨/⊣)  # Partitioned-none: partitions where 𝕨<𝕩 is never 1

# TODO keep track of line number
# TODO keep track of file

# Source to ⟨tokens, roles, number of identifiers, literals⟩
# Identifiers then literal tokens are numbered starting at vi
Tokenize←{System‿vars←𝕨
  # Resolve comments and strings
  c←𝕩='#'⋄s←/0‿0⊸«⊸∧sm←𝕩='''⋄d←/dm←𝕩='"'
  g←⍋q←∾⟨  s⋄¯1↓d⋄/c⟩ ⋄q↩g⊏q                # Open indices
  e← g⊏∾⟨2+s⋄ 1↓d⋄-⟜»∘⊏⟜(0∾+`c)⊸//(𝕩∊lf)∾1⟩ # Matching close indices
  Se←≠(>/⊢)∾⟜≠{(⊏˜𝕨)𝕊⍟(≠○(¯1⊸⊑))𝕩∾𝕩⊏𝕨}⟨0⟩˙  # Find reachable openings
  St←(≠𝕩)↑·/⁼(Se q⍋e)⊸⊏                     # All indices → reached mask
  a←St q⋄b←St e⋄f←1≠`ab←a∨b                 # Open/close masks; filter
  {!⟨⊑/𝕩,"Unclosed quote"⟩}⍟(∨´)(sm∨dm)∧b<f

  # Extract character and string literals
  u←f∧𝕩='@'⋄ci←/u∨»a∧sm
  chr←(⊏⟜𝕩-('@'-@)×⊏⟜u)ci                   # Characters (indices ci)
  f>↩qe←dm∧«a∧↩dm                           # Quote Escape ""
  str←𝕩⊔˜1-˜(si←a>»qe)(⊣+`⊸×○(∾⟜1)<)≠`dm∧ab # Strings (indices /si)

  # Extract words: identifiers and numbers
  ie←/f⋄is←ie≠⊸↑/1»f                        # Token start and end
  is-↩is(-×⊏⟜c)ie                           # Comment → ending newline only
  t←CharCode ie⊏𝕩
  nd←(t=⊑bN)>«t M bD⋄rr←t=bR                # Namespace dot; 𝕣
  w←»⊸<l←rr∨nd<t M bN(⊣⋈-˜)○⊑bW             # Word chars l, start w
  us←t=¯1++´bA⋄sy←t=⊑bW                     # Underscore, system dot
  {!⟨𝕩/is,"𝕣 can only appear as 𝕣, _𝕣, or _𝕣_"⟩}⍟(∨´)rr∧((»<«)us)∨(»∨«)us(<∨∧⟜(»∧«))sy∨l
  {!⟨is/˜us∧w+`⊸⊏0∾𝕩,"Words can't only have underscores"⟩}⍟(∨´)w(/<1(⊢/«)(∨/⊣))l>us
  wk←(¬w/rr)×na⌊∘÷˜(⊑bA)-˜w/t               # Kind of word from first char
  t-↩na×l∧t≥na+⊑bA                          # Case-insensitive
  {!⟨𝕩/is,"System dot with no name"⟩}⍟(∨´)sy>«l
  w≠↩»⊸∨sy                                  # Start system word at dot
  wi←0<wt←(2×wk≥0)(×⟜¬+⊢)w/sy               # Type: 0 number, 1 system, 2 identifier
  i←l>n←l∧(+`w)⊏0∾¬wi                       # Identifier/Number masks
  num←is ReadNums○(((0∾us)<∨⟜«0∾n)/0⊸∾) t×l # Numbers
  ir←(us/˜«⊸<i)(⊢+∧⟜(2⊸=))wi/wk             # Identifier role
  iu←w>n∨fr←rr∨us∧«rr                       # Starts of 𝕣 tokens, and non-𝕣 identifiers
  if←(»⌈`)⊸<ig←(i>us∨rr)×+`iu               # Identifier groups and first character
  wu←if∨n∧w⋄ws←iu/sy                        # Starts of non-𝕣 words; system identifiers
  {!⟨is⊏˜𝕩/𝕨,"Numbers can't start with underscores"⟩}⍟(∨´⊢)⟜(ws<(⊑bA)>⊏⟜t)/if
  id←vars⊸∾⌾⊑(ws∾2)⊔(ig-1)⊔t⊏charSet        # ⟨Identifiers, system values⟩

  # Deduplicate literals and identifiers; other cleanup
  ki←((wt/˜¬w/fr)⍒⊸⊏/wu)∾(ci∾/si)⊏+`»f      # Indices in t
  k←id∾num‿chr‿str⋄k(⊢>¯1»⌈`)⊸/¨˜↩j←⊐¨k     # IDs j into uniques k
  k↩System⌾(1⊸⊑)k                           # System value lookup
  wf←¬l∨t M bW⋄is/˜↩wf∨w⋄ie/˜↩wf∨>⟜«l       # Index management for...
  t↩(vars≠⊸↓∾j++`vd»kk←≠¨k)⌾(ki⊸⊏)t         # Add IDs
  t/˜↩rr∨wu∨wf                              # Remove words/whitespace
  t-↩t(M×-⟜⊑)bS                             # Separators are equivalent
  p←≠`1¨sb←¯1↓1↓/1(∾≠∾˜)t=sep               # Separator group boundaries (excludes leading and trailing)
  eb←3‿5‿7+⊑bB                              # End brackets that allow separators
  sk←sb/˜p>∨⟜«(M⟜bH∨eb∊˜p⊸+)(sb-p)⊏t        # Keep the first of each group that's not just inside a bracket
  t{is/˜↩𝕨⋄ie/˜↩𝕨⋄𝕨/𝕩}˜↩1¨⌾(sk⊸⊏)t≠sep      # Remove the rest
  im←(t=bR)∨t M vd⋈+´2↑kk                   # Identifier (or 𝕣) mask
  r←ir⌾(im⊸/)(vd⌊t)⊏charRole∾0              # Role
  t+↩(⊑bX)((⊢M⋈⟜5)×5+3⊸+⊸≤)t                # Case-insensitive special names
  t-↩vi(<+10×=)t                            # Shift . to bX and variables back one
  ⟨t,r,k,is,ie⟩
}

# 𝕩 is a list of tokens that contains the numeric literals, each
# preceded by 0. Return the numbers.
ReadNums←{
  _err_←{(!/⟜𝔾⋈𝔽)⍟(∨´)}
  EChars←⟨"Letter"⊸Pl," """,⊏⟜charSet,""" not allowed in numbers"⟩_tmpl
  e‿d‿n‿p‿i←=⟜𝕩¨((⊑bA)+-´"ea")∾+⟜↕´bN       # Masks for e.¯π∞
  EChars∘(/⟜𝕩)_err_𝕨 (𝕩=bR)∨¬e∨𝕩<⊑bA
  s←d∨c←e∨z←0=𝕩⋄m←¬n∨c
  "Negative sign in the middle of a number"_err_𝕨 n>»c
  "Portion of a number is empty"_err_𝕨 (1«s)∧n∨s
  "Ill-formed decimal or exponent use"_err_(s/𝕎) ¬(0⊸=∨»⊸<)s/𝕩
  "π and ∞ must occur alone"_err_𝕨 (p∨i)>1(»∧(p∧«e)∨«)z∨n>»e
  l←(¬(⊢-T)·+`d⊸<)g←(«≤(d<y←𝕩≠⊑bD)>○I1T¬)⊸∧m# No leading 0s
  la←d×(»¬(⊢-T)+`)⌾⌽¬g∨y                    # Adjust dp for dropped 0s after decimal
  k‿dp←d¬⊸(/⋈1⊸»⊸/)○((d∨>⟜«g)⊸/)l-la        # Length, decimal position
  NN←(1«0⊸=)/0(0⊸≤××⟜10⊸+)`⊏⟜(¯1∾π‿1∾↕10)   # Digit lookup has ∞ as 1 to avoid ∞×0
  PN←NN(«⊸>∨d⊸<)/(𝕩-1+⊑bN)⊸×                # Evaluate numbers given mask
  va←(∨´k>15)◶PN‿{                          # Numeric values—mantissas and exponents
    𝕩∧↩20≥l⋄k⌊↩20                           # Cap at 20 digits
    𝕩>↩f←𝕩∧l≤(+`»⊸<𝕩)⊏0∾te←0⌈k-15           # Handle trailing ≤15 normally
    (1e15×PN f)⊸+⌾((te>0)⊸/) PN 𝕩           # Leading part
  } g
  v←va×1‿¯1⊏˜(r←>⟜»m)/»n                    # Negate if ¯
  vm←c/○(1»«)z                              # Mask of mantissas in v
  mn←vm/v×(r/i)⊏1‿∞                         # Mantissa, correcting ∞
  ee←vm/(k-dp)-˜«v×¬vm                      # Power of 10
  a←(0⌈ee)+ee-b←ee⌈¯308                     # Subnormal handling
  b÷⟜(10⋆-)˜⌾((0>b)⊸/)a 10⊸⋆⊸×⌾((0≠a)⊸/)mn  # mn×10⋆ee
}

Compile←{ 𝕊:
  defaults←⟨⟩‿(!∘"System values not supported"¨)‿⟨⟩‿(↕0)
  prims‿Sys‿vars‿redef ← ∾⟜(≠↓defaults˙) ⋈⍟(4<≠)𝕨
  ⟨tok,role,val,t0,t1⟩←tx←sys‿vars Tokenize 𝕩
  •Show tok
  •Show role
  •Show val
  •Show t0
  •Show t1
}
