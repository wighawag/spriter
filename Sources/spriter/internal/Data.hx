package spriter.internal;

using spriter.internal.XmlHelper;

//<folder id="2" name="images_alternate2">
@:access(spriter)
class Folder extends Element{
	
	
	private var files : Array<File>;//<file>
	private function new(){super();}
	private static function fromXml(xml : Xml) : Folder{
		var folder = new Folder();
		Element.fromXml(folder,xml);
		folder.files = new Array();
		for (file in xml.elementsNamed("file")){
			folder.files.push(File.fromXml(file));
		}
		return folder;
	}
}



//<file id="0" name="images_alternate2/big.png" width="512" height="256" pivot_x="0" pivot_y="1"/>
class File extends Element{
	private var type : FileType; //atribute type
	private var pivotX : Float; //attribute pivot_x
	private var pivotY : Float; //attribute pivot_y
	private var width : Float; //attribute width
	private var height : Float; //attribute height
	
	private function new(){
		super();
		pivotX = 0;
		pivotY = 1;
		width = 0;
		height = 0;
	}
	private static function fromXml(xml : Xml) : File{
		var file = new File();
		Element.fromXml(file,xml);
		if(xml.exists("type")){
			if(xml.get("type") == "image"){
				file.type = AnImage;	
			}else if(xml.get("type") == "sound"){
				file.type = ASound;
			}else{
				throw "unknown type :" + xml.get("type");
			}	
		}else{
			file.type = AnImage;
		}
		
		file.pivotX = xml.getFloat("pivot_x",0);
		file.pivotY = xml.getFloat("pivot_y",1);
		file.width = xml.getFloat("width",0);
		file.height = xml.getFloat("height",0);
		
		return file;
	}
	
}

//<entity id="0" name="squares">
@:access(spriter)
class Entity extends Element{
	private var spriter : Spriter;
	private var objectInfos : Array<ObjectInfo>; //<obj_info>
	public var objectInfosMap : Map<String,ObjectInfo>;
	private var characterMaps : Array<CharacterMap>;//<character_map>
	private var animations : Array<Animation>;//<animation> //should be a map ?
	private var variables : Array<VariableDef>;//<var_defs><i/><i/></var_defs>
	
	private var maxNumBones : Int = 1000;
	private var maxNumBoxes : Int = 1000;
	private var maxNumPoints : Int = 1000;
	private var maxNumSprites : Int = 1000;
	
	private static function fromXml(xml : Xml, spriter : Spriter) : Entity{
		var entity = new Entity();
		Element.fromXml(entity,xml);
		entity.spriter = spriter;
		
		entity.objectInfosMap = new Map();
		entity.objectInfos = new Array();
		for (xml in xml.elementsNamed("obj_info")){
			var objectInfo = ObjectInfo.fromXml(xml);
			entity.objectInfos.push(objectInfo);
			if(objectInfo.name != null && objectInfo.name != ""){
				entity.objectInfosMap[objectInfo.name] = objectInfo;
			}
		}
		
		entity.characterMaps = new Array();
		for (xml in xml.elementsNamed("character_map")){
			var characterMap = CharacterMap.fromXml(xml);
			entity.characterMaps.push(characterMap);
		}
		
		entity.animations = new Array();
		for (xml in xml.elementsNamed("animation")){
			var animation = Animation.fromXml(xml, entity); //TODO use map as well?
			entity.animations.push(animation);
		}
		
		entity.variables = new Array();
		for (xml in xml.elementsNamed("var_defs")){
			for (xml in xml.elementsNamed("i")){
				var variable = VariableDef.fromXml(xml); 
				entity.variables.push(variable);
			}
		}
		
		return entity;
	}
	private function new(){super();}
}

//<obj_info name="chest" type="bone" w="200" h="10"/>
class ObjectInfo extends Element{
	
	private var type : ObjectType ; //attribute type
	private var pivotX : Float; //attribute pivot_x
	private var pivotY : Float; //attribute pivot_y
	private var width : Float; //attribute w
	private var height : Float; //attribute h
	private var variables : Array<VariableDef>; //<var_defs><i/><i/></var_defs>
	private static function fromXml(xml : Xml) : ObjectInfo{
		var objectInfo = new ObjectInfo();
		Element.fromXml(objectInfo, xml);
		
		//TODO test various type
		if(xml.exists("type")){
			var type = xml.get("type");
			if(type == "bone"){
				objectInfo.type = ABone;	
			}else if(type == "box"){
				objectInfo.type = ABox;
			}else if(type == "sprite"){
				objectInfo.type = ASprite;
			}else if(type == "sound"){
				objectInfo.type = ASound;
			}else if(type == "point"){
				objectInfo.type = APoint;
			}else if(type == "variable"){
				objectInfo.type = AVariable;
			}else if(type == "entity"){
				objectInfo.type = AnEntity;
			}else{
				throw "unknown type :" + type;
			}	
		}else{
			objectInfo.type = ASprite; //TODO check default
		}
		
		objectInfo.pivotX = xml.getFloat("pivot_x", 0);
		objectInfo.pivotY = xml.getFloat("pivot_y", 0);
		objectInfo.width = xml.getFloat("w", 0);
		objectInfo.height = xml.getFloat("h", 0);
		
		objectInfo.variables = new Array();
		for (xml in xml.elementsNamed("var_defs")){
			for (xml in xml.elementsNamed("i")){
				var variable = VariableDef.fromXml(xml); 
				objectInfo.variables.push(variable);
			}
		}
		
		return objectInfo;
	}
	private function new(){super();}
}

//<animation id="3" name="stand_up" length="350" looping="false"> //TODO interval?
@:access(spriter)
class Animation extends Element{
	private var entity : Entity;
	private var length : Float; //attribute length
	private var looping : Bool; //attribute looping
	private var mainlineKeys : Array<MainlineKey>; //<mainline><key/><key/></mainline>
	private var timelines : Array<Timeline>;//<timeline>
	private var eventLines : Array<EventLine>;//<eventline>
	private var soundLines : Array<SoundLine>;//<soundline>
	private var meta : Meta;//<meta>
	
	private static function fromXml(xml : Xml, entity : Entity) : Animation{
		var animation = new Animation();
		Element.fromXml(animation, xml);
		animation.entity = entity;
		animation.length = xml.getFloat("length",0) / 1000;
		animation.looping = xml.getBool("looping",true);
		
		animation.mainlineKeys = new Array();
		for (xml in xml.elementsNamed("mainline")){
			for (xml in xml.elementsNamed("key")){
				var key = MainlineKey.fromXml(xml); 
				animation.mainlineKeys.push(key);
			}
		}
		
		animation.timelines = new Array();
		for (xml in xml.elementsNamed("timeline")){
			var timeline = Timeline.fromXml(xml); 
			animation.timelines.push(timeline);			
		}
		
		animation.eventLines = new Array();
		for (xml in xml.elementsNamed("eventline")){
			var eventLine = EventLine.fromXml(xml); 
			animation.eventLines.push(eventLine);			
		}
		
		animation.soundLines = new Array();
		for (xml in xml.elementsNamed("soundline")){
			var soundLine = SoundLine.fromXml(xml); 
			animation.soundLines.push(soundLine);			
		}
		
		for (xml in xml.elementsNamed("meta")){
			animation.meta = Meta.fromXml(xml);
			break;			
		}
			
		return animation;
	}
	private function new(){
		super();
		looping = true;
	}
}

//<key id="0">
class MainlineKey extends Key{
	private var boneRefs : Array<BoneRef>;//<bone_ref>
	private var objectRefs : Array<ObjectRef>;//<object_ref>
	private static function fromXml(xml : Xml) : MainlineKey{
		var mainlineKey = new MainlineKey();
		Key.fromXml(mainlineKey, xml);
		
		mainlineKey.boneRefs = new Array();
		for (xml in xml.elementsNamed("bone_ref")){ 
			var boneRef = new BoneRef();
			mainlineKey.boneRefs.push(BoneRef.fromXml(boneRef, xml));			
		}
		
		mainlineKey.objectRefs = new Array();
		for (xml in xml.elementsNamed("object_ref")){ 
			mainlineKey.objectRefs.push(ObjectRef.fromXml(xml));			
		}
		
		return mainlineKey;
	}
	private function new(){super();}
}

//<bone_ref id="1" parent="0" timeline="16" key="0"/>
class BoneRef extends Element{
	private var parentId : Int;//attribute parent
	private var timelineId : Int;//attribute timeline
	private var keyId : Int;//attribute key
	
	private static function fromXml(boneRef : BoneRef, xml : Xml) : BoneRef{
		Element.fromXml(boneRef, xml);
		
		boneRef.parentId = xml.getInt("parent",-1);
		boneRef.timelineId = xml.getInt("timeline", 0);
		boneRef.keyId = xml.getInt("key", 0);
		
		return boneRef;
	}
	private function new(){
		super();
		parentId = -1;
	}
}

//<object_ref id="0" parent="6" timeline="2" key="0" z_index="0"/>
class ObjectRef extends BoneRef{
	private var zIndex : Int;//attribute z_index
	
	private static function fromXml(xml : Xml) : ObjectRef{
		var objectRef = new ObjectRef();
		BoneRef.fromXml(objectRef, xml);
		objectRef.zIndex = xml.getInt("z_index",0);
		return objectRef;
	}
	private function new(){super();}
}

//<timeline id="1" obj="1" name="p_head_idle">
@:access(spriter)
class Timeline extends Element{
	private var objectType : ObjectType; //attribute object_type
	private var objectId : Int; // attribute obj
	private var keys: Array<TimelineKey>; //<key>
	private var meta : Meta; //<meta>  
	private static function fromXml(xml : Xml) : Timeline{
		var timeline = new Timeline();
		Element.fromXml(timeline, xml);
		
		//TODO test various type
		if(xml.exists("object_type")){
			var type = xml.get("object_type");
			if(type == "bone"){
				timeline.objectType = ABone;	
			}else if(type == "box"){
				timeline.objectType = ABox;
			}else if(type == "sprite"){
				timeline.objectType = ASprite;
			}else if(type == "sound"){
				timeline.objectType = ASound;
			}else if(type == "point"){
				timeline.objectType = APoint;
			}else if(type == "variable"){
				timeline.objectType = AVariable;
			}else if(type == "entity"){
				timeline.objectType = AnEntity;
			}else{
				throw "unknown type :" + type;
			}	
		}else{
			timeline.objectType = ASprite; //TODO check default
		}
		
		timeline.objectId = xml.getInt("obj",0);
		
	   
		timeline.keys = new Array();
		for (xml in xml.elementsNamed("key")){
			var key = TimelineKey.fromXml(xml); 
			timeline.keys.push(key);
		}
		
		for (xml in xml.elementsNamed("meta")){
			timeline.meta = Meta.fromXml(xml);
			break;			
		}
		
		return timeline;
	}
	private function new(){super();}
}

//<key id="1" time="196" spin="0">
@:access(spriter)
class TimelineKey extends Key{
	private var spin : Int;//attribute spin
	private var bone : Bone;//<bone>
	private var object : Object;//<object>
	
	private static function fromXml(xml : Xml) : TimelineKey{
		var timelineKey = new TimelineKey();
		Key.fromXml(timelineKey, xml);
		
		timelineKey.spin = xml.getInt("spin", 1);
		
		for (xml in xml.elementsNamed("bone")){ 
			var bone = new Bone();
			timelineKey.bone = Bone.fromXml(bone,xml);
			break;			
		}
		
		for (xml in xml.elementsNamed("object")){
			timelineKey.object = Object.fromXml(xml);
			break;			
		}
		
		return timelineKey;
	}
	private function new(){
		super();
		spin = 1;
	}
}

//<bone x="5" y="40" angle="91.59114" scale_x="0.18527"/>
class Bone{
	private var x : Float;//attribute x;
	private var y : Float;//attribute y;
	private var angle : Float;//attribute angle;
	private var scaleX : Float;//attribute scale_x;
	private var scaleY : Float;//attribute scale_y;
	private var alpha : Float;//attribute a;
	
	private static function fromXml(bone : Bone, xml : Xml) : Bone{
		bone.x = xml.getFloat("x", 0);
		bone.y = xml.getFloat("y", 0);
		bone.angle = xml.getFloat("angle", 0) * Math.PI / 180.0;
		bone.scaleX = xml.getFloat("scale_x", 1);
		bone.scaleY = xml.getFloat("scale_y", 1);
		bone.alpha = xml.getFloat("a", 1);
		
		return bone;
	}
	
	private function new(){
		scaleX = 1;
		scaleY = 1;
		alpha = 1;
	}
}

//<object folder="0" file="1" x="75.083824" y="115.948194" pivot_x="0.000894" pivot_y="0.000311" angle="270"/>
class Object extends Bone{
	private var animationId : Int;//attribute animation;
	private var entityId : Int;//attribute entity;
	private var folderId : Int;//attribute folder;
	private var fileId : Int;//attribute file;
	private var pivotX : Float;//attribute pivot_x;
	private var pivotY : Float;//attribute pivot_y;
	private var t : Float;//attribute t;
	
	//private var pivotXSet : Bool = false;
	//private var pivotYSet : Bool = false;
	
	private static function fromXml(xml : Xml) : Object{
		var object = new Object();
		Bone.fromXml(object, xml);
		
		object.animationId = xml.getInt("animation",0);
		object.entityId = xml.getInt("entity",0);
		object.folderId = xml.getInt("folder",0);
		object.fileId = xml.getInt("file",0);
		// if(xml.exists("pivot_x")){
		//	 object.pivotXSet = true;
		//	 object.pivotX = xml.getFloat("pivot_x",0);	
		// }
		// if(xml.exists("pivot_y")){
		//	 object.pivotYSet = true;
		//	 object.pivotY = xml.getFloat("pivot_y",0);
		// }
		object.pivotX = xml.getFloat("pivot_x",-9999); //TODO fix
		object.pivotY = xml.getFloat("pivot_y",-9999);
		object.t = xml.getFloat("t",0);
		
		return object;
	}
	
	private function new(){super();}
	
	//TODO set pivot as not used?
	// {
	//	 PivotX = float.NaN;
	//	 PivotY = float.NaN;
	// }
}

//<character_map id="0" name="alternate 1">
@:access(spriter)
class CharacterMap extends Element{
	private var maps : Array<MapInstruction>;//<map>
	
	private static function fromXml(xml : Xml) : CharacterMap{
		var characterMap = new CharacterMap();
		Element.fromXml(characterMap, xml);
		characterMap.maps = new Array();
		for(xml in xml.elementsNamed("map")){
			characterMap.maps.push(MapInstruction.fromXml(xml));
		}
		return characterMap;	
	}
	
	private function new(){super();}
}

//<map folder="0" file="0" target_folder="1" target_file="0"/>
class MapInstruction{
	private var folderId : Int;//attribute folder
	private var fileId : Int;//attribute file
	private var targetFolderId : Int;//attribute target_folder
	private var targetFileId : Int;//attribute target_file
	
	private static function fromXml(xml : Xml) : MapInstruction{
		var mapInstruction = new MapInstruction();
		mapInstruction.folderId = xml.getInt("folder",0);
		mapInstruction.fileId = xml.getInt("file",0);
		mapInstruction.targetFolderId = xml.getInt("target_folder",-1);
		mapInstruction.targetFileId = xml.getInt("target_file",-1);
		return mapInstruction;
	}
	
	private function new(){
		targetFolderId = -1;
		targetFileId = -1;
	}
}

//<meta>
@:access(spriter)
class Meta{
	private var varLines : Array<VarLine>;//<varline>
	private var tagLine : TagLine;//<tagline>
	
	private static function fromXml(xml : Xml) : Meta{
		var meta = new Meta();
		meta.varLines = new Array();
		for(xml in xml.elementsNamed("varline")){
			meta.varLines.push(VarLine.fromXml(xml));
		}
		for(xml in xml.elementsNamed("tagline")){
			meta.tagLine = TagLine.fromXml(xml);
			break;
		}
		return meta;   
	}
		
	private function new(){}
}

//<i id="0" name="testVar" type="float" default="100"/>
class VariableDef extends Element{
	private var type : VarType;//attribute type;
	private var defaultValue : String;//attribute default
	private var variableValue : VarValue;
	
	private static function fromXml(xml : Xml) : VariableDef{
		var variableDef = new VariableDef();
		Element.fromXml(variableDef, xml);
		
		//TODO test various type
		if(xml.exists("type")){
			var type = xml.get("type");
			if(type == "string"){
				variableDef.type = AString;	
			}else if(type == "int"){
				variableDef.type = AnInt;
			}else if(type == "float"){
				variableDef.type = AFloat;
			}else{
				throw "unknown type :" + type;
			}	
		}else{
			throw "no type specified :" + xml;
		}
		
		variableDef.defaultValue = xml.getString("default"); //TODO default based on type
		
		return variableDef;
	}
		
	private function new(){super();variableValue = new VarValue();}
}

class VarLine extends Element{
	private var def : Int;//attribute def
	private var keys : Array<VarLineKey>;//<key>
	
	private static function fromXml(xml : Xml) : VarLine{
		var varLine = new VarLine();
		
		varLine.def = xml.getInt("def",0);
		
		varLine.keys = new Array();
		for(xml in xml.elementsNamed("key")){
			varLine.keys.push(VarLineKey.fromXml(xml));
		}
		
		return varLine;
	}
		
	private function new(){super();}
}

class VarLineKey extends Key{
	private var value : String;//attribute val
	private var variableValue : VarValue;
	
	private static function fromXml(xml : Xml) : VarLineKey{
		var varLineKey = new VarLineKey();
		Key.fromXml(varLineKey, xml);
		
		varLineKey.value = xml.getString("val");
		
		return varLineKey;	
	}
	
	private function new(){super();variableValue = new VarValue();}
}

class VarValue{ 
	public function new(){type = AString;}
	private var type : VarType;
	private var stringValue : String;
	private var floatValue : Float;
	private var intValue : Int;
}

class EventLine extends Element{ 
	private var keys : Array<Key>;//<key>
	
	private static function fromXml(xml : Xml) : EventLine{
		var eventLine = new EventLine();
		Element.fromXml(eventLine, xml);
		
		eventLine.keys = new Array();
		for(xml in xml.elementsNamed("key")){
			var key = new Key();
			eventLine.keys.push(Key.fromXml(key,xml));
		}
		
		return eventLine;
	}
	
	private function new(){super();}
}

@:access(spriter)
class TagLine{ 
	private var keys : Array<TagLineKey>;//<key>
	
	private static function fromXml(xml : Xml) : TagLine{
		var tagLine = new TagLine();
		
		tagLine.keys = new Array();
		for(xml in xml.elementsNamed("key")){
			tagLine.keys.push(TagLineKey.fromXml(xml));
		}
		
		return tagLine;
	}
	private function new(){}
}

class TagLineKey extends Key{
	private var tags : Array<Tag>;//<tag>
	
	private static function fromXml(xml : Xml) : TagLineKey{
		var tagLineKey = new TagLineKey();
		Key.fromXml(tagLineKey, xml);
		
		tagLineKey.tags = new Array();
		for(xml in xml.elementsNamed("tag")){
			tagLineKey.tags.push(Tag.fromXml(xml));
		}
		
		return tagLineKey;
	}
	
	private function new(){super();}
}

class Tag extends Element{
	private var tagId : Int;//attribute t
	
	private static function fromXml(xml : Xml) : Tag{
		var tag = new Tag();
		Element.fromXml(tag, xml);
		tag.tagId = xml.getInt("t",0);
		return tag;
	}
	
	private function new(){super();}
}

class SoundLine extends Element{ //TODO check if it inherit Element
	private var keys : Array<SoundLineKey>;//<key>
	
	private static function fromXml(xml : Xml) : SoundLine{
		var soundLine = new SoundLine();
		Element.fromXml(soundLine,xml);
		soundLine.keys = new Array();
		for(xml in xml.elementsNamed("key")){
			soundLine.keys.push(SoundLineKey.fromXml(xml));
		}
		
		return soundLine;
	}
	
	private function new(){super();}
}

class SoundLineKey extends Key{
	private var object : SoundObject;//<object>
	
	private static function fromXml(xml : Xml) : SoundLineKey{
		var soundLineKey = new SoundLineKey();
		Key.fromXml(soundLineKey, xml);
		
		for(xml in xml.elementsNamed("object")){
			soundLineKey.object = SoundObject.fromXml(xml);
			break;
		}
		
		return soundLineKey;
	}
	
	private function new(){super();}
}

class SoundObject extends Element{
	
	private var folderId : Int;//attribute folder
	private var fileId : Int;//attribute file
	private var trigger : Bool;//attribute trigger
	private var panning : Float;//attribute panning
	private var volume : Float;//attribute volume
	 
	private static function fromXml(xml : Xml) : SoundObject{
		var soundObject = new SoundObject();
		Element.fromXml(soundObject, xml);
		
		soundObject.folderId = xml.getInt("folder", 0);
		soundObject.fileId = xml.getInt("file", 0);
		soundObject.trigger = xml.getBool("trigger", true);
		soundObject.panning = xml.getFloat("panningr", 0);
		soundObject.volume = xml.getFloat("volume", 1);
		
		return soundObject;
	}
	 
	private function new(){
		super();
		trigger = true;
		volume = 1.0;
	}
}

class Element{
	private static function fromXml(element : Element, xml : Xml) : Element{
		element.id = xml.getInt("id");
		element.name = xml.getString("name");  
		return element;
	} 
	private var id : Int;//attribute id
	private var name : String;//attribute name
	private function new(){}
}


class Key extends Element{
	private var time : Float; //atribute time
	private var curveType : CurveType; //atribute curve_type
	private var c1 : Float; //atribute c1
	private var c2 : Float; //atribute c2
	private var c3 : Float; //atribute c3
	private var c4 : Float; //atribute c4
	
	private static function fromXml(key : Key, xml : Xml) : Key{
		Element.fromXml(key, xml);
		key.time = xml.getFloat("time") / 1000;
		
		if(xml.exists("curve_type")){
			var type = xml.get("curve_type");
			if(type == "linear"){
				key.curveType = Linear;	
			}else if(type == "instant"){
				key.curveType = Instant;
			}else if(type == "quadratic"){
				key.curveType = Quadratic;
			}else if(type == "cubic"){
				key.curveType = Cubic;
			}else if(type == "quartic"){
				key.curveType = Quartic;
			}else if(type == "quintic"){
				key.curveType = Quintic;
			}else if(type == "bezier"){
				key.curveType = Bezier;
			}else{
				throw "unknown type :" + type;
			}	
		}else{
			//throw "no type specified :" + xml;
			key.curveType = Linear; //TODO check if we should default to Linear
		}
		
	   
		key.c1 = xml.getFloat("c1");
		key.c2 = xml.getFloat("c2");
		key.c3 = xml.getFloat("c3");
		key.c4 = xml.getFloat("c4");
		
		return key;
	} 
	
	private function new(){
		super();
		time = 0;
	}
}

enum ObjectType{
	ASprite; //sprite
	ABone; //bone
	ABox; //box
	APoint; //point
	ASound; //sound
	AnEntity; //entity
	AVariable; //variable
}

enum CurveType{
	Linear;//linear
	Instant;//instant
	Quadratic;//quadratic
	Cubic;//cubic
	Quartic;//quartic
	Quintic;//quintic
	Bezier;//bezier
}

enum FileType{
	AnImage;
	ASound;//sound
}

enum VarType{
	AString; //string
	AnInt; //int
	AFloat; //float
}

class MaxCounters{
	public var numBones : Int = 0;
	public var numBonesAtRoot : Int = 0;
	public var numSprites : Int = 0;
	public var numBoxes : Int = 0;
	public var numPoints : Int = 0;
	public function new(){}
}