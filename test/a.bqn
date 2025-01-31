b←•Import "./b.bqn"
Foo ←{
  a←𝕩   #? this is a 
  a↩10  #?
}
Foo 2 
b.Bar 3
