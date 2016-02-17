package spriter;

using spriter.internal.XmlHelper;
import spriter.internal.Data;


//<spriter_data scml_version="1.0" generator="BrashMonkey Spriter" generator_version="r4.1">
@:access(spriter)
class Spriter{ 
	
	
	public static function parseScml(scml : String) : Spriter{
		var spriter = new Spriter();
		
		var root = Xml.parse(scml).firstElement();
		
		spriter.folders = new Array();
		for (folder in root.elementsNamed("folder")){
			spriter.folders.push(Folder.fromXml(folder));
		}
		
		spriter.entities = new Map();
		spriter.entityArray = new Array();
		for (xml in root.elementsNamed("entity")){
			var entity = Entity.fromXml(xml, spriter);
			spriter.entityArray.push(entity);
			spriter.entities.set(entity.name, entity);
		}
		
		spriter.tags = new Array();
		for (xml in root.elementsNamed("tag_list")){
			for(xml in xml.elementsNamed("i")){
				var element = new Element();
				Element.fromXml(element,xml);
				spriter.tags.push(element);	
			}
			
		}
		
		for( entity in spriter.entities)
		{
			computeMaxData(entity);
			for(animation in entity.animations)
			{
				//set pivots for non set one
				for(timeline in animation.timelines){
					for(key in timeline.keys){
						var obj = key.object;
						if(obj == null)continue;
						var file = animation.entity.spriter.folders[obj.folderId].files[obj.fileId];
						// if(!obj.pivotXSet){
						//	 obj.pivotX = file.pivotX;		
						// }
						// if(!obj.pivotYSet){
						//	 obj.pivotY = file.pivotY;		
						// }
						//TODO remove
						if(obj.pivotX == -9999){
							obj.pivotX = file.pivotX;
						}
						if(obj.pivotY == -9999){
							obj.pivotY = file.pivotY;
						}
					}
				}
				
				//Init variables
				if (animation.meta != null && animation.meta.varLines != null && animation.meta.varLines.length > 0){
					for (varline in animation.meta.varLines)
					{
						var varDefs = animation.entity.variables[varline.def];
						initVariable(varDefs, varline, null);
					}	
				}else{
					continue; //TODO check?
				}

		

				for(timeline in animation.timelines)
				{
					
					
					var objectInfo : ObjectInfo = null;
					for (objInfo in animation.entity.objectInfos){
						if(objInfo.name == timeline.name){
							objectInfo = objInfo;
						}
					}
					
					if (timeline.meta != null && timeline.meta.varLines != null && timeline.meta.varLines.length > 0){
						if(objectInfo != null){ //TODO check : should always be the case
							for(varline in timeline.meta.varLines)
							{
								var varDef = objectInfo.variables[varline.def];
								initVariable(varDef, varline, objectInfo.name);
							}	
						}else{
							trace("no objectInfo");
						}	
					}
					
					
					
				}
			}
		}
		
		return spriter;
	}
	
	public function createEntity(entityName : String, ?withMetadata : Bool = true) : EntityInstance{
		return new EntityInstance(entities[entityName], withMetadata);
	}
	
	
	private static function computeMaxData(entity : Entity){
		var maxNumSprites = 0;
		var maxNumBoxes = 0;
		var maxNumPoints = 0;
		var maxNumBonesAtRoot = 0;
		var maxNumBones = 0;
		
		for(animation in entity.animations)
		{
			var maxCounters = computeMaxForAnim(animation);
			maxNumBones = Std.int(Math.max(maxCounters.numBones, maxNumBones));
			maxNumBonesAtRoot = Std.int(Math.max(maxCounters.numBonesAtRoot, maxNumBonesAtRoot));
			maxNumSprites = Std.int(Math.max(maxCounters.numSprites, maxNumSprites));
			maxNumBoxes = Std.int(Math.max(maxCounters.numBoxes, maxNumBoxes));
			maxNumPoints = Std.int(Math.max(maxCounters.numPoints, maxNumPoints));
		}
		// trace("maxNumBones", maxNumBones);
		// trace("maxNumBonesAtRoot", maxNumBonesAtRoot);
		// trace("maxNumSprites", maxNumSprites);
		// trace("maxNumBoxes", maxNumBoxes);
		// trace("maxNumPoints", maxNumPoints);
		
		entity.maxNumBones = maxNumBones + maxNumBonesAtRoot*2;
		entity.maxNumSprites = maxNumSprites;
		entity.maxNumBoxes = maxNumBoxes;
		entity.maxNumPoints = maxNumPoints;
	}
	
	
	private static function computeMaxForAnim(animation : Animation) : MaxCounters{
		var maxNumSprites = 0;
		var maxNumBoxes = 0;
		var maxNumPoints = 0;
		var maxNumBonesAtRoot = 0;
		var maxNumBones = 0;
		
		var keys = animation.mainlineKeys;
		for(key in keys){
			var numSprites = 0;
			var numBoxes = 0;
			var numPoints = 0;
			var numBones = key.boneRefs.length;
			var numBonesAtRoot = numBones;
			
			for (i in 0...key.objectRefs.length)
			{
				var objectRef  : ObjectRef  = key.objectRefs[i];
				var timeline = animation.timelines[objectRef.timelineId];
				switch (timeline.objectType)
				{
					case ASprite: 
						numSprites++;
					case APoint: 
						numPoints++;
					case ABox: 
						numBoxes++;
					case AnEntity:
						var refKeys : Array<TimelineKey> = animation.timelines[objectRef.timelineId].keys;
						var refKey = refKeys[objectRef.keyId];
						var newAnim = animation.entity.spriter.entityArray[refKey.object.entityId].animations[refKey.object.animationId];
						var maxCounters = computeMaxForAnim(newAnim);
						numBones += maxCounters.numBones +1;
						numSprites += maxCounters.numSprites;
						numBoxes += maxCounters.numBoxes;
						numPoints += maxCounters.numPoints;
					default://dealt elsewhere
				}
			}	
			maxNumBonesAtRoot = Std.int(Math.max(numBonesAtRoot, maxNumBonesAtRoot));
			maxNumBones = Std.int(Math.max(numBones, maxNumBones));
			maxNumSprites = Std.int(Math.max(numSprites, maxNumSprites));
			maxNumBoxes = Std.int(Math.max(numBoxes, maxNumBoxes));
			maxNumPoints = Std.int(Math.max(numPoints, maxNumPoints));
		}
		var maxCounters = new MaxCounters();
		maxCounters.numBones = maxNumBones;
		maxCounters.numBonesAtRoot = maxNumBonesAtRoot;
		maxCounters.numSprites = maxNumSprites;
		maxCounters.numBoxes = maxNumBoxes;
		maxCounters.numPoints = maxNumPoints;
		
		return maxCounters;
	}
	
	private static function initVariable(varDef : VariableDef, varline : VarLine, objectName : String) : Void
	{
		varDef.variableValue = getVarValue(varDef.defaultValue, varDef.type);
		
		for(key in varline.keys){
			key.variableValue = getVarValue(key.value, varDef.type);  
		} 
	}

	private static function getVarValue(value : String, type : VarType) : VarValue 
	{
		var floatValue : Float = 0; //TODO Single.MinValue;
		var intValue : Int = 0; //TODO Int32.MinValue;

		if (type == VarType.AFloat) floatValue = Std.parseFloat(value);
		else if (type == VarType.AnInt) intValue = Std.parseInt(value);

		var val = new VarValue();
		val.type = type;
		val.stringValue = value;
		val.floatValue = floatValue;
		val.intValue = intValue;
		return val;
	}
	
	private var folders : Array<Folder>; //<folder>
	private var entities : Map<String,Entity>;//<entity> //TODO check for duplicate name
	private var entityArray : Array<Entity>;//<entity> //sync with entities
	private var tags : Array<Element>;//<tag_list><i/><i/></tag_list> 
	
	 
	private function new(){}
}

