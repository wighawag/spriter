package spriter.internal;

import haxe.ds.Vector;

class MapOfMapString{
	var top : Int;
	var n : Int;
	var names : PushMapInt;
	var arrays : Array<Int>;
	var subNames : Array<String>;
	var values : Array<String>;
	
	public function new(){
		names = new PushMapInt();
		arrays = new Array<Int>();
		arrays.push(0);
		subNames = new Array<String>();
		subNames.push("");
		values = new Array<String>();
		values.push("");
		clear();
	}
	
	public function clear(){
		top = 0;
		n = 0;
		names.clear();
	}
	
	public function push(name : String, subName : String, value : String){
		if(!names.exists(name)){
			arrays[top] = 1; //length
			subNames[n] = subName;
			values[n] = value;
			arrays[top+1] = n;
			n++;
			names.push(name,top);
		}else{
			if(top != names.get(name)){
				//TODO Error
			}else{
				var length = arrays[top];
				arrays[top] = arrays[top] + 1;
				subNames[n] = subName;
				values[n] = value;
				arrays[1+top+length]=n;
				n++;
			}
		}
	}
	
	public function exists(name : String, subName : String) : Bool{
		if(!names.exists(name)){
			return false;
		}
		var index = names.get(name);
		var length = arrays[index];
		for(i in 0...length){
			var subIndex = arrays[1+index+i];
			if(subNames[subIndex] == subName){
				return true;
			}
		}
		return false;
	}
	
	public function get(name : String, subName : String) : String{
		if(!names.exists(name)){
			return null;
		}
		var index = names.get(name);
		var length = arrays[index];
		for(i in 0...length){
			var subIndex = arrays[1+index+i];
			if(subNames[subIndex] == subName){
				return values[subIndex];
			}
		}
		return null;
	}
	
}

class MapOfMapFloat{
	var top : Int;
	var n : Int;
	var names : PushMapInt;
	var arrays : Array<Int>;
	var subNames : Array<String>;
	var values : Array<Float>;
	
	public function new(){
		names = new PushMapInt();
		arrays = new Array<Int>();
		arrays.push(0);
		subNames = new Array<String>();
		subNames.push("");
		values = new Array<Float>();
		values.push(0);
		clear();
	}
	
	public function clear(){
		top = 0;
		n = 0;
		names.clear();
	}
	
	public function push(name : String, subName : String, value : Float){
		if(!names.exists(name)){
			arrays[top] = 1; //length
			subNames[n] = subName;
			values[n] = value;
			arrays[top+1] = n;
			n++;
			names.push(name,top);
		}else{
			if(top != names.get(name)){
				//TODO Error
			}else{
				var length = arrays[top];
				arrays[top] = arrays[top] + 1;
				subNames[n] = subName;
				values[n] = value;
				arrays[1+top+length]=n;
				n++;
			}
		}
	}
	
	public function exists(name : String, subName : String) : Bool{
		if(!names.exists(name)){
			return false;
		}
		var index = names.get(name);
		var length = arrays[index];
		for(i in 0...length){
			var subIndex = arrays[1+index+i];
			if(subNames[subIndex] == subName){
				return true;
			}
		}
		return false;
	}
	
	public function get(name : String, subName : String) : Float{
		if(!names.exists(name)){
			return 0;
		}
		var index = names.get(name);
		var length = arrays[index];
		for(i in 0...length){
			var subIndex = arrays[1+index+i];
			if(subNames[subIndex] == subName){
				return values[subIndex];
			}
		}
		return 0;
	}
	
}


class MapOfMapInt{
	var top : Int;
	var n : Int;
	var names : PushMapInt;
	var arrays : Array<Int>;
	var subNames : Array<String>;
	var values : Array<Int>;
	
	public function new(){
		names = new PushMapInt();
		arrays = new Array<Int>();
		arrays.push(0);
		subNames = new Array<String>();
		subNames.push("");
		values = new Array<Int>();
		values.push(0);
		clear();
	}
	
	public function clear(){
		top = 0;
		n = 0;
		names.clear();
	}
	
	public function push(name : String, subName : String, value : Int){
		if(!names.exists(name)){
			arrays[top] = 1; //length
			subNames[n] = subName;
			values[n] = value;
			arrays[top+1] = n;
			n++;
			names.push(name,top);
		}else{
			if(top != names.get(name)){
				//TODO Error
			}else{
				var length = arrays[top];
				arrays[top] = arrays[top] + 1;
				subNames[n] = subName;
				values[n] = value;
				arrays[1+top+length]=n;
				n++;
			}
		}
	}
	
	public function exists(name : String, subName : String) : Bool{
		if(!names.exists(name)){
			return false;
		}
		var index = names.get(name);
		var length = arrays[index];
		for(i in 0...length){
			var subIndex = arrays[1+index+i];
			if(subNames[subIndex] == subName){
				return true;
			}
		}
		return false;
	}
	
	public function get(name : String, subName : String) : Int{
		if(!names.exists(name)){
			return 0;
		}
		var index = names.get(name);
		var length = arrays[index];
		for(i in 0...length){
			var subIndex = arrays[1+index+i];
			if(subNames[subIndex] == subName){
				return values[subIndex];
			}
		}
		return 0;
	}
	
}


class MapOfSet{
	var top : Int;
	var n : Int;
	var names : PushMapInt;
	var arrays : Array<Int>;
	var subNames : Array<String>;
	
	public function new(){
		names = new PushMapInt();
		arrays = new Array<Int>();
		arrays.push(0);
		subNames = new Array<String>();
		subNames.push("");
		clear();
	}
	
	public function clear(){
		top = 0;
		n = 0;
		names.clear();
	}
	
	public function push(name : String, subName : String){
		if(!names.exists(name)){
			arrays[top] = 1; //length
			subNames[n] = subName;
			arrays[top+1] = n;
			n++;
			names.push(name,top);
		}else{
			if(top != names.get(name)){
				//TODO Error
			}else{
				var length = arrays[top];
				arrays[top] = arrays[top] + 1;
				subNames[n] = subName;
				arrays[1+top+length]=n;
				n++;
			}
		}
	}
	
	public function has(name : String, subName : String) : Bool{
		if(!names.exists(name)){
			return false;
		}
		var index = names.get(name);
		var length = arrays[index];
		for(i in 0...length){
			if(subNames[arrays[1+index+i]] == subName){
				return true;
			}
		}
		return false;
	}
	
}

class PushMapString{
	var map : Map<String,String>;
	var keys : Array<String>;
	public var numElements(default,null) : Int;
	public function new(){
		map = new Map();
		map.set("","");
		map.remove("");
		keys = new Array();
		keys.push("");
		numElements = 0;
	}
	
	inline public function getKey(i : Int) : String{
		if(i >= numElements){
			return null;
		}
		return keys[i];
	}
	
	inline public function push(key : String, value : String){
		map.set(key,value);
		keys[numElements] = key;
		numElements++;
	}
	
	inline public function clear(){
		for(i in 0...numElements){
			var key = keys[i];
			map.remove(key);
		}
		numElements = 0;
	}
	
	inline public function exists(key : String) : Bool{
		return map.exists(key);
	}
	
	inline public function get(key : String) : String{
		return map.get(key);
	}
	
}


class PushMapFloat{
	var map : Map<String,Float>;
	var keys : Array<String>;
	public var numElements(default,null) : Int;
	public function new(){
		map = new Map();
		map.set("",0.0);
		map.remove("");
		keys = new Array();
		keys.push("");
		numElements = 0;
	}
	
	inline public function getKey(i : Int) : String{
		if(i >= numElements){
			return null;
		}
		return keys[i];
	}
	
	inline public function push(key : String, value : Float){
		map.set(key,value);
		keys[numElements] = key;
		numElements++;
	}
	
	inline public function clear(){
		for(i in 0...numElements){
			var key = keys[i];
			map.remove(key);
		}
		numElements = 0;
	}
	
	inline public function exists(key : String) : Bool{
		return map.exists(key);
	}
	
	inline public function get(key : String) : Float{
		return map.get(key);
	}
	
}

class PushMapInt{
	var map : Map<String,Int>;
	var keys : Array<String>;
	public var numElements(default,null) : Int;
	public function new(){
		map = new Map();
		map.set("",0);
		map.remove("");
		keys = new Array();
		keys.push("");
		numElements = 0;
	}
	
	inline public function getKey(i : Int) : String{
		if(i >= numElements){
			return null;
		}
		return keys[i];
	}
	
	inline public function push(key : String, value : Int){
		map.set(key,value);
		keys[numElements] = key;
		numElements++;
	}
	
	inline public function clear(){
		for(i in 0...numElements){
			var key = keys[i];
			map.remove(key);
		}
		numElements = 0;
	}
	
	inline public function exists(key : String) : Bool{
		return map.exists(key);
	}
	
	inline public function get(key : String) : Int{
		return map.get(key);
	}
	
}

class PushSet{
	var map : Map<String,Bool>;
	var keys : Array<String>;
	public var numElements(default,null) : Int;
	public function new(){
		map = new Map();
		map.set("",true);
		map.remove("");
		keys = new Array();
		keys.push("");
		numElements = 0;
	}
	
	inline public function get(i : Int) : String{
		if(i >= numElements){
			return null;
		}
		return keys[i];
	}
	
	inline public function add(key : String){
		map.set(key,true);
		keys[numElements] = key;
		numElements++;
	}
	
	inline public function clear(){
		for(i in 0...numElements){
			var key = keys[i];
			map.remove(key);
		}
		numElements = 0;
	}
	
	inline public function exists(key : String) : Bool{
		return map.exists(key);
	}

	
}

class IntPushMapInt{
	var map : Map<Int,Int>;
	var keys : Array<Int>;
	public var numElements(default,null) : Int;
	public function new(){
		map = new Map();
		map.set(0,0);
		map.remove(0);
		keys = new Array();
		keys.push(0);
		numElements = 0;
	}
	
	inline public function getKey(i : Int) : Int{
		if(i >= numElements){
			return -1;
		}
		return keys[i];
	}
	
	inline public function push(key : Int, value : Int){
		map.set(key,value);
		keys[numElements] = key;
		numElements++;
	}
	
	inline public function clear(){
		for(i in 0...numElements){
			var key = keys[i];
			map.remove(key);
		}
		numElements = 0;
	}
	
	inline public function exists(key : Int) : Bool{
		return map.exists(key);
	}
	
	inline public function get(key : Int) : Int{
		return map.get(key);
	}
	
}


class PushArrayString{
	var data : Array<String>;
	
	public var numElements(default,null) : Int;
	public function value(current) : String{
		return data[current];
	}
	
	public function new(){
		data = new Array();
		data.push("");
		numElements = 0;
	}
	
	inline private function push(value : String){
		data[numElements] = value;
		numElements++;
	}
	
	inline private function clear(){
		numElements = 0;
	}
	
}

abstract BoneData(Vector<Float>){
	
	public var structSize(get,never):Int;
	public var top(get,never) : Int;
	public var start(get,never) : Int;
	
	inline public function x(current : Int) : Float{
		return this[current];
	}
	inline public function y(current : Int) : Float{
		return this[current+1];
	}
	inline public function angle(current : Int) : Float{
		return this[current+2];
	}
	inline public function scaleX(current : Int) : Float{
		return this[current+3];
	}
	inline public function scaleY(current : Int) : Float{
		return this[current+4];
	}
	inline public function alpha(current : Int) : Float{
		return this[current+5];
	}
    
    inline private function setX(current : Int, value : Float) : Float{
		return this[current] = value;
	}
	inline private function setY(current : Int, value : Float) : Float{
		return this[current+1] = value;
	}
	inline private function setAngle(current : Int, value : Float) : Float{
		return this[current+2] = value;
	}
	inline private function setScaleX(current : Int, value : Float) : Float{
		return this[current+3] = value;
	}
	inline private function setScaleY(current : Int, value : Float) : Float{
		return this[current+4] = value;
	}
	inline private function setAlpha(current : Int, value : Float) : Float{
		return this[current+5] = value;
	}
	
	
	inline public function write(
		x : Float,
		y : Float,
		angle : Float,
		scaleX : Float,
		scaleY : Float,
		alpha : Float
	) : Void{
		var current : Int = untyped this[0];
		this[current] = x;
		this[current+1] = y;
		this[current+2] = angle;
		this[current+3] = scaleX;
		this[current+4] = scaleY;
		this[current+5] = alpha;
		this[0] = current + structSize;
	}
	
	inline public function set(
		current : Int,
		x : Float,
		y : Float,
		angle : Float,
		scaleX : Float,
		scaleY : Float,
		alpha : Float
	) : Void{
		this[current] = x;
		this[current+1] = y;
		this[current+2] = angle;
		this[current+3] = scaleX;
		this[current+4] = scaleY;
		this[current+5] = alpha;
	}
	
	
	inline public function clear(){
		this[0] = 1;
	}
	
	inline public function get_start() : Int{
		return 1;
	}
	
	inline public function get_top() : Int{
		return untyped this[0];
	}
	
	inline public function get_structSize() : Int{
		return 6;
	}
	
	inline public function new(length : Int){
		this = new Vector(length*structSize + start);
		this[0] = 1;
	}
	
}

abstract SoundData(Array<Float>){
	
	public var top(get,never) : Int;
	public var start(get,never) : Int;
	public var structSize(get,never) : Int;

	inline public function id(current : Int) : Int{
		return untyped this[current];
	}
	inline public function folderId(current : Int) : Int{
		return untyped this[current+1];
	}
	inline public function fileId(current : Int) : Int{
		return untyped this[current+2];
	}
	inline public function panning(current : Int) : Float{
		return this[current+3];
	}
	inline public function volume(current : Int) : Float{
		return this[current+4];
	}
		
	inline public function write(
		id : Int,
		folderId : Int,
		fileId : Int,
		panning : Float,
		volume : Float
	) : Void{
		var current : Int = untyped this[0];
		this[current] = id;
		this[current+1] = folderId;
		this[current+2] = fileId;
		this[current+3] = panning;
		this[current+4] = volume;
		this[0] = current + structSize;
	}
	
	inline public function get_start() : Int{
		return 1;
	}
	
	inline public function get_top() : Int{
		return untyped this[0];
	}
	
	inline public function get_structSize() : Int{
		return 5;
	}
	
	inline public function clear(){
		this[0] = 1;
	}
	
	
	inline public function new(){
		this = new Array();
		this[0] = 1;
	}
	
}


class ObjectVarData{
	var strings : MapOfMapString;
	var floats : MapOfMapFloat;
	var ints : MapOfMapInt;
	
	public function new(){
		strings = new MapOfMapString();
		floats = new MapOfMapFloat();
		ints = new MapOfMapInt();
	}
	
	inline public function clear(){
		strings.clear();
		floats.clear();
		ints.clear();
	}
	
	inline public function hasString(name : String, subName : String) : Bool{
		return strings.exists(name, subName);
	}
		
	inline public function getString(name : String, subName : String) : String{
		return strings.get(name, subName);
	}
	
	inline public function hasFloat(name : String, subName : String) : Bool{
		return floats.exists(name, subName);
	}
		
	inline public function getFloat(name : String, subName : String) : Float{
		return floats.get(name, subName);
	}
	
	inline public function hasInt(name : String, subName : String) : Bool{
		return ints.exists(name, subName);
	}
		
	inline public function getInt(name : String, subName : String) : Int{
		return ints.get(name, subName);
	}
	
}


class VarData{
	var strings : PushMapString;
	var floats : PushMapFloat;
	var ints : PushMapInt;
	
	public function new(){
		strings = new PushMapString();
		floats = new PushMapFloat();
		ints = new PushMapInt();
	}
	
	inline public function clear(){
		strings.clear();
		floats.clear();
		ints.clear();
	}
	
	inline public function hasString(name : String) : Bool{
		return strings.exists(name);
	}
		
	inline public function getString(name : String) : String{
		return strings.get(name);
	}
	
	inline public function hasFloat(name : String) : Bool{
		return floats.exists(name);
	}
		
	inline public function getFloat(name : String) : Float{
		return floats.get(name);
	}
	
	inline public function hasInt(name : String) : Bool{
		return ints.exists(name);
	}
		
	inline public function getInt(name : String) : Int{
		return ints.get(name);
	}
	
}


abstract ObjectData(Vector<Float>){
	
	public var top(get,never) : Int;
	public var start(get,never) : Int;
	public var structSize(get,never) : Int;

	
	inline public function animationId(current : Int) : Int{
		return untyped this[current];
	}
	inline public function entityId(current : Int) : Int{
		return untyped this[current+1];
	}
	inline public function folderId(current : Int) : Int{
		return untyped this[current+2];
	}
	inline public function fileId(current : Int) : Int{
		return untyped this[current+3];
	}
	inline public function pivotX(current : Int) : Float{
		return this[current+4];
	}
	inline public function pivotY(current : Int) : Float{
		return this[current+5];
	}
	inline public function t(current : Int) : Float{
		return this[current+6];
	}
	inline public function x(current : Int) : Float{
		return this[current+7];
	}
	inline public function y(current : Int) : Float{
		return this[current+8];
	}
	inline public function angle(current : Int) : Float{
		return this[current+9];
	}
	inline public function scaleX(current : Int) : Float{
		return this[current+10];
	}
	inline public function scaleY(current : Int) : Float{
		return this[current+11];
	}
	inline public function alpha(current : Int) : Float{
		return this[current+12];
	}
	
	inline public function setPivotX(current : Int, value : Float) : Float{
		return this[current+4] = value;
	}
	inline public function setPivotY(current : Int, value : Float) : Float{
		return this[current+5] = value;
	}
	
	inline private function setX(current : Int, value : Float) : Float{
		return this[current+7] = value;
	}
	inline private function setY(current : Int, value : Float) : Float{
		return this[current+8] = value;
	}
	inline private function setAngle(current : Int, value : Float) : Float{
		return this[current+9] = value;
	}
	inline private function setScaleX(current : Int, value : Float) : Float{
		return this[current+10] = value;
	}
	inline private function setScaleY(current : Int, value : Float) : Float{
		return this[current+11] = value;
	}
	inline private function setAlpha(current : Int, value : Float) : Float{
		return this[current+12] = value;
	}
	
	
	inline public function write(
		animationId : Int,
		entityId : Int,
		folderId : Int,
		fileId : Int,
		pivotX : Float,
		pivotY : Float,
		t : Float,
		x : Float,
		y : Float,
		angle : Float,
		scaleX : Float,
		scaleY : Float,
		alpha : Float
	) : Void{
		var current = top;
		this[current] = animationId;
		this[current+1] = entityId;
		this[current+2] = folderId;
		this[current+3] = fileId;
		this[current+4] = pivotX;
		this[current+5] = pivotY;
		this[current+6] = t;
		this[current+7] = x;
		this[current+8] = y;
		this[current+9] = angle;
		this[current+10] = scaleX;
		this[current+11] = scaleY;
		this[current+12] = alpha;
		this[0] = current + structSize;
	}
	
	
	inline public function get_start() : Int{
		return 1;
	}
	
	inline public function get_top() : Int{
		return untyped this[0];
	}
	
	inline public function get_structSize() : Int{
		return 13;
	}
	
	inline public function removeLast(){
		this[0]-=structSize;
	}
	
	inline public function clear(){
		this[0] = 1;
	}
	
	
	inline public function new(length : Int){
		this = new Vector(length*structSize + start);
		this[0] = 1;
	}
	
}


