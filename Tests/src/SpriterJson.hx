
import spriter.EntityInstance;

class SpriterJson{
	public static function getFrameData(entityInstance : EntityInstance) : Dynamic{
		var spriteData = entityInstance.sprites;
		var boxData = entityInstance.boxes;
		var pointData = entityInstance.points;
		var pointNames = entityInstance.pointNames;
		var boxObjectIds = entityInstance.boxObjectIds;
		
		var jsonObj : Dynamic = {};	
		
		jsonObj.spriteData = [];
		
		var current = spriteData.start;
		while(current < spriteData.top){
			var obj : Dynamic = {};
			obj.animationId = spriteData.animationId(current);
			obj.entityId = spriteData.entityId(current);
			obj.folderId = spriteData.folderId(current);
			obj.fileId = spriteData.fileId(current);
			obj.pivotX = spriteData.pivotX(current);
			obj.pivotY = spriteData.pivotY(current);
			obj.t = spriteData.t(current) * 1000;
			obj.x = spriteData.x(current);
			obj.y = spriteData.y(current);
			obj.angle = spriteData.angle(current) * 180 / Math.PI;
			obj.scaleX = spriteData.scaleX(current);
			obj.scaleY = spriteData.scaleY(current);
			obj.alpha = spriteData.alpha(current);
			jsonObj.spriteData.push(obj);
			current += spriteData.structSize;
		}
		
		jsonObj.pointData = {};
		for(i in 0...pointNames.numElements){
			var key = pointNames.getKey(i);
			var current = pointNames.get(key);
			var obj : Dynamic = {};
			obj.animationId = pointData.animationId(current);
			obj.entityId = pointData.entityId(current);
			obj.folderId = pointData.folderId(current);
			obj.fileId = pointData.fileId(current);
			obj.pivotX = pointData.pivotX(current);
			obj.pivotY = pointData.pivotY(current);
			obj.t = pointData.t(current) * 1000;
			obj.x = pointData.x(current);
			obj.y = pointData.y(current);
			obj.angle = pointData.angle(current) * 180 / Math.PI;
			obj.scaleX = pointData.scaleX(current);
			obj.scaleY = pointData.scaleY(current);
			obj.alpha = pointData.alpha(current);
			Reflect.setField(jsonObj.pointData,key, obj);
		}
		
		jsonObj.boxData = {};
		for(i in 0...boxObjectIds.numElements){
			var key = boxObjectIds.getKey(i);
			var current = boxObjectIds.get(key);
			var obj : Dynamic = {};
			obj.animationId = boxData.animationId(current);
			obj.entityId = boxData.entityId(current);
			obj.folderId = boxData.folderId(current);
			obj.fileId = boxData.fileId(current);
			obj.pivotX = boxData.pivotX(current);
			obj.pivotY = boxData.pivotY(current);
			obj.t = boxData.t(current) * 1000;
			obj.x = boxData.x(current);
			obj.y = boxData.y(current);
			obj.angle = boxData.angle(current) * 180 / Math.PI;
			obj.scaleX = boxData.scaleX(current);
			obj.scaleY = boxData.scaleY(current);
			obj.alpha = boxData.alpha(current);
			Reflect.setField(jsonObj.boxData,"" +key, obj);
		}
		
		return jsonObj;
	}
	
	@:access(spriter)
	public static function getFrameMetadata(entityInstance : EntityInstance) : Dynamic{
		var sounds = entityInstance.sounds;
		var events = entityInstance.events;
		var animationTags = entityInstance.animationTags;
		var animationVars = entityInstance.animationVars;
		var objectTags = entityInstance.objectTags;
		var objectVars = entityInstance.objectVars;
		
		var jsonObj : Dynamic = {};	
		
		jsonObj.sounds = [];
		var current = sounds.start;
		while(current < sounds.top){
			jsonObj.sounds.push({
				name : null,
				id : sounds.id(current),
				folderId : sounds.folderId(current),
				fileId : sounds.fileId(current),
				trigger : true,
				panning : sounds.panning(current),
				volume : sounds.volume(current)
			});
			current+=sounds.structSize;
		}
		
		
		jsonObj.events = [];

		var currentEvent = 0;
		while(currentEvent < events.numElements){
			jsonObj.events.push(events.value(currentEvent));
			currentEvent++;
		}
		
		jsonObj.animationTags= [];
		for(i in 0...animationTags.numElements){
			jsonObj.animationTags.push(animationTags.get(i));
		}
		
		
		jsonObj.animationVars = {};
		for(i in 0...animationVars.strings.numElements){
			var key = animationVars.strings.getKey(i);
			var value = {type: 0,
					stringValue: animationVars.strings.get(key),
					floatValue: 0.0,
					intValue: 0};
			Reflect.setField(jsonObj.animationVars,key, value);
		}
		for(i in 0...animationVars.floats.numElements){
			var key = animationVars.floats.getKey(i);
			var value = {type: 2,
					stringValue: null,
					floatValue: animationVars.floats.get(key),
					intValue: 0};
			Reflect.setField(jsonObj.animationVars,key, value);
		}
		for(i in 0...animationVars.ints.numElements){
			var key = animationVars.ints.getKey(i);
			var value = {type: 1,
					stringValue: null,
					floatValue: 0.0,
					intValue: animationVars.ints.get(key)};	
			Reflect.setField(jsonObj.animationVars,key, value);
		}

		jsonObj.objectTags = {};
		for(i in 0...objectTags.names.numElements){
			var name = objectTags.names.getKey(i);
			var tmp : Array<String> = [];
			Reflect.setField(jsonObj.objectTags,name, tmp);
			var index = objectTags.names.get(name);
			var length = objectTags.arrays[index];
			for(j in 0...length){
				var subIndex = objectTags.arrays[1+index+j];
				var subName = objectTags.subNames[subIndex];
				tmp.push(subName);
			}
			
		}
		
		
		jsonObj.objectVars = {};
		for(i in 0...objectVars.strings.names.numElements){
			var name = objectVars.strings.names.getKey(i);
			var tmp : Dynamic = {};
			Reflect.setField(jsonObj.objectVars,name, tmp);
			var index = objectVars.strings.names.get(name);
			var length = objectVars.strings.arrays[index];
			for(j in 0...length){
				var subIndex = objectVars.strings.arrays[1+index+j];
				var subName = objectVars.strings.subNames[subIndex];
				var value = {type: 0,
					stringValue: objectVars.strings.get(name, subName),
					floatValue: 0.0,
					intValue: 0};
				Reflect.setField(tmp,subName, value);
			}			
		}
		for(i in 0...objectVars.floats.names.numElements){
			var name = objectVars.floats.names.getKey(i);
			var tmp : Dynamic = {};
			Reflect.setField(jsonObj.objectVars,name, tmp);
			var index = objectVars.floats.names.get(name);
			var length = objectVars.floats.arrays[index];
			for(j in 0...length){
				var subIndex = objectVars.floats.arrays[1+index+j];
				var subName = objectVars.floats.subNames[subIndex];
				var value = {type: 2,
					stringValue: null,
					floatValue: objectVars.floats.get(name, subName),
					intValue: 0};
				Reflect.setField(tmp,subName, value);
			}			
		}
		for(i in 0...objectVars.ints.names.numElements){
			var name = objectVars.ints.names.getKey(i);
			var tmp : Dynamic = {};
			Reflect.setField(jsonObj.objectVars,name, tmp);
			var index = objectVars.ints.names.get(name);
			var length = objectVars.ints.arrays[index];
			for(j in 0...length){
				var subIndex = objectVars.ints.arrays[1+index+j];
				var subName = objectVars.ints.subNames[subIndex];
				var value = {type: 1,
					stringValue: null,
					floatValue: 0.0,
					intValue: objectVars.ints.get(name, subName)};
				Reflect.setField(tmp,subName, value);
			}			
		}
		return jsonObj;
	}
}