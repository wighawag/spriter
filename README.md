[![travis status](https://travis-ci.org/wighawag/spriter.svg)](https://travis-ci.org/wighawag/spriter)

Spriter runtime for Haxe with 0 allocation for hxcpp

Ported originaly from https://github.com/loodakrawa/SpriterDotNet
Modified to separate completely rendering from logic and remove GC use while animating.

Usage
=====

You can see an example for kha at https://github.com/wighawag/spriter_test

to create :

```haxe
var spriter = Spriter.parseScml(scmlContent); //parse the scml file 
var entityInstance = spriter.createEntity("Player"); //create an entityInstance from the name of one of the entity in the scml
```

in the update then :

```haxe
entityInstance.step(delta);
```
