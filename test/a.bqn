b←("a"‿"b"‿"c")•Import "./b.bqn"
Foo ←{
  a←𝕩 ⋄ z ←8 #? this is a 
  a↩10  #?
}
Foo 2 
b.Bar 3
