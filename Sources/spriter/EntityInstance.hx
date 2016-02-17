package spriter;

import spriter.Spriter;
import haxe.ds.StringMap;
import spriter.internal.DataType;
import spriter.internal.Data;
import spriter.internal.MathHelper;

@:access(spriter)
class EntityInstance{
	public var sprites : ObjectData;
	public var boxes : ObjectData;
	public var points : ObjectData;
	public var pointNames : PushMapInt;
	//TODO private var boxNames : PushMap<Int>;
	public var boxObjectIds : IntPushMapInt;
	
	public var events : PushArrayString;
	public var sounds : SoundData;
	
	public var animationVars : VarData;
	public var objectVars : ObjectVarData;
	public var animationTags : PushSet;
	public var objectTags : MapOfSet;
	
	public var animationFinished :  String -> Void; //TODO? Array
	public var eventTriggered :  String -> Void;//TODO? Array
	public var soundTriggered :  String -> Float -> Float -> Void; //TODO Array
	public var speed : Float;
	
	public var currentAnimationName(default,null) : String;
	public var currentAnimationLength(default,null) : Float; 
	public var currentAnimationTime(default,null) : Float;
	
	public function hasAnimation(name : String) : Bool { return animations.exists(name); }
	
	public var progress(get, set) : Float;

	public function play(name : String){
		var animation = animations[name];
		_play(animation);
	}

	public function transition(name : String, totalTransitionTime : Float)
	{
		this.totalTransitionTime = totalTransitionTime;
		transitionTime = 0.0;
		factor = 0.0;
		nextAnimation = animations[name];
	}

	inline public function getFilename(folderId : Int, fileId : Int) : String{
		return entity.spriter.folders[folderId].files[fileId].name;
	} 
	
	public function blend(first : String, second : String, factor : Float)
	{
		play(first);
		nextAnimation = animations[second];
		totalTransitionTime = 0;
		this.factor = factor;
	}
	
	public function step(delta : Float){ 

		var elapsed : Float = delta * speed;

		if (nextAnimation != null && totalTransitionTime != 0.0)
		{
			elapsed += elapsed * factor * _currentAnimation.length/ nextAnimation.length;

			transitionTime += Math.abs(elapsed);
			factor = transitionTime / totalTransitionTime;
			if (transitionTime >= totalTransitionTime)//swap to nextAnimation
			{
				var progressBeforePlay = progress; 
				_play(nextAnimation);
				progress = progressBeforePlay;
				nextAnimation = null;
			}
		}

		currentAnimationTime += elapsed;

		if (currentAnimationTime < 0.0)
		{
			if (_currentAnimation.looping) currentAnimationTime += currentAnimationLength;//TODO while
			else currentAnimationTime = 0.0;
			if(animationFinished != null) animationFinished(currentAnimationName);
		}
		else if (currentAnimationTime >= currentAnimationLength)
		{
			if (_currentAnimation.looping) currentAnimationTime -= currentAnimationLength;//TODO while
			else currentAnimationTime = currentAnimationLength;
			if(animationFinished != null) animationFinished(currentAnimationName);
		}

		animate(elapsed);
	}
	private var metadataEnabled : Bool;
	
	private var tmpData : ObjectData; //to simplify updateFrameData2 //TODO remove?
	private var boneData : BoneData; 

	//TODO?
	private var characterMap : CharacterMap;

	
	private var entity : Entity;
	private var _currentAnimation : Animation;
	private var nextAnimation : Animation;
	
	private var animations : Map<String, Animation>; 
	private var totalTransitionTime : Float;
	private var transitionTime : Float;
	private var factor : Float;


	private function new(entity : Entity, metadataEnabled : Bool){
		this.metadataEnabled = metadataEnabled;
		speed = 1;
		this.entity = entity;
		animations = new Map();
		
		sprites = new ObjectData(entity.maxNumSprites+1);
		boxes = new ObjectData(entity.maxNumBoxes);
		points = new ObjectData(entity.maxNumPoints);
		events = new PushArrayString();
		sounds = new SoundData();

		animationVars = new VarData();
		objectVars = new ObjectVarData();
		animationTags = new PushSet();
		objectTags = new MapOfSet();
		
		
		pointNames = new PushMapInt();
		boxObjectIds = new IntPushMapInt();
		tmpData = new ObjectData(2);
		boneData = new BoneData(entity.maxNumBones);
	
		
		//create a map of animation
		for(anim in entity.animations){ 
			animations.set(anim.name, anim);
		}
		_play(entity.animations[0]);
	}
	
	
	private function get_progress(){
		return currentAnimationTime / currentAnimationLength;
	}
	private function set_progress(value : Float){
		currentAnimationTime = value * currentAnimationLength;
		return value;
	}
	
	private function clearData(){
		boneData.clear();
		tmpData.clear();
		sprites.clear();
		boxes.clear();
		points.clear();
		events.clear();
		sounds.clear();

		animationVars.clear();
		objectVars.clear();
		animationTags.clear();
		objectTags.clear();
	}
	
	private function animate(elapsed : Float){
		
		clearData();
		if(nextAnimation == null){
			updateFrameData(_currentAnimation, currentAnimationTime, -1);	 
		}else{
			updateFrameData2(_currentAnimation, nextAnimation, currentAnimationTime, factor);
		}
		
		if(metadataEnabled){
			if(nextAnimation == null){
				updateFrameMetadata(_currentAnimation, currentAnimationTime, elapsed);		
			}else{
				updateFrameMetadata2(_currentAnimation, nextAnimation, currentAnimationTime, elapsed, factor);
			}
		}
		
		
		if (metadataEnabled && soundTriggered != null)
		{
			var current = sounds.start;
			while (current < sounds.top)
			{
				var fileName = entity.spriter.folders[sounds.folderId(current)].files[sounds.fileId(current)].name;
				soundTriggered(fileName, sounds.panning(current), sounds.volume(current));
				current+=sounds.structSize;
			}
		}
		
		if(metadataEnabled && eventTriggered != null){
			var currentEvent = 0;
			while(currentEvent < events.numElements){
				eventTriggered(events.value(currentEvent));
				currentEvent++;
			}
		}
		
	}
	
	private function _play(animation : Animation){
		if(animation == null){
			return; //TODO log
		}
		this.progress = 0;

		_currentAnimation = animation;
		currentAnimationName = animation.name;

		nextAnimation = null;
		currentAnimationLength = _currentAnimation.length;
	}
	
	
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	//FRAME DATA
///////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	
	private function updateFrameData2(first : Animation, second : Animation, targetTime : Float, factor : Float){
		if (first == second)
		{
			updateFrameData(first, targetTime, -1);
			return;
		}

		var targetTimeSecond = targetTime / first.length * second.length;

		var keys = first.mainlineKeys;
		var firstKeyA : MainlineKey = lastKeyForTime(keys, targetTime);
		var nextKey = firstKeyA.id + 1;
		if (nextKey >= keys.length) nextKey = 0;
		var firstKeyB : MainlineKey = keys[nextKey];

		var keys = second.mainlineKeys;
		var secondKeyA : MainlineKey = lastKeyForTime(keys, targetTimeSecond);
		var nextKey = secondKeyA.id + 1;
		if (nextKey >= keys.length) nextKey = 0;
		var secondKeyB : MainlineKey = keys[nextKey];

		if (!willItBlend(firstKeyA, secondKeyA) || !willItBlend(firstKeyB, secondKeyB))
		{
			updateFrameData(first, targetTime, -1);
			return;
		}

		var adjustedTimeFirst = adjustTime(firstKeyA, firstKeyB, first.length, targetTime);
		var adjustedTimeSecond = adjustTime(secondKeyA, secondKeyB, second.length, targetTimeSecond);
		
		var startA = boneData.top;
		var hasAnyBoneOnA = getBoneInfos(boneData, firstKeyA, first, adjustedTimeFirst);
		var startB = boneData.top;
		var hasAnyBoneOnB = getBoneInfos(boneData,secondKeyA, second, adjustedTimeSecond);
		
		var startBones = boneData.top;
		if (hasAnyBoneOnA && hasAnyBoneOnB)
		{
			var current = boneData.top;
			var numBonesInA = Std.int( (startB - startA) / boneData.structSize);
			var currentA = startA;
			var currentB = startB;
			for (i in 0...numBonesInA)
			{
				interpolateBoneFromBoneData(boneData, currentA, currentB, factor, 1);
				var boneAAngle = boneData.angle(currentA);
				var boneBAngle = boneData.angle(currentB);
				boneData.setAngle(current, MathHelper.closerAngleLinear(boneAAngle, boneBAngle, factor));
				currentA += boneData.structSize;
				currentB += boneData.structSize;
				current += boneData.structSize;
			}
		}

		var baseKey = factor < 0.5 ? firstKeyA : firstKeyB;
		var currentAnim = factor < 0.5 ? first : second;

		for (i in 0...baseKey.objectRefs.length)
		{
			var objectRefFirst = baseKey.objectRefs[i];
			var timeline = currentAnim.timelines[objectRefFirst.timelineId];
			var objectData : ObjectData = sprites;
			switch (timeline.objectType)
			{
				case ASprite: 
					objectData = sprites;
				case APoint: 
					objectData = points;
					pointNames.push(timeline.name, objectData.top);
				case ABox: 
					objectData = boxes;
					boxObjectIds.push(timeline.objectId, objectData.top);
				case AnEntity:
				default://dealt elsewhere
			}
			tmpData.clear();
			getObjectInfo(tmpData,objectRefFirst, first, adjustedTimeFirst);
			
			var objectRefSecond = secondKeyA.objectRefs[i];
			getObjectInfo(tmpData,objectRefSecond, second, adjustedTimeSecond);
			
			var firstIndex = tmpData.start;
			var secondIndex = firstIndex + tmpData.structSize;
			interpolateObjectFromObjectData(objectData, tmpData, firstIndex, secondIndex, factor, 1);
			
			var last = objectData.top - objectData.structSize;
			objectData.setAngle(last, MathHelper.closerAngleLinear(tmpData.angle(firstIndex), tmpData.angle(secondIndex), factor));
			objectData.setPivotX(last, MathHelper.linear(tmpData.pivotX(firstIndex), tmpData.pivotX(secondIndex), factor));
			objectData.setPivotY(last, MathHelper.linear(tmpData.pivotY(firstIndex), tmpData.pivotY(secondIndex), factor));

			if (hasAnyBoneOnA && hasAnyBoneOnB && objectRefFirst.parentId >= 0) {
				applyObjectParentTransformFromBoneData(objectData,boneData,last, startBones + objectRefFirst.parentId * boneData.structSize);
			}
			
			if (timeline.objectType == AnEntity){
				var newAnim = currentAnim.entity.spriter.entityArray[objectData.entityId(last)].animations[objectData.animationId(last)];
				var newTargetTime = objectData.t(last) * newAnim.length;
				boneData.write( //copy into boneData to act as parent
					objectData.x(last),
					objectData.y(last),
					objectData.angle(last),
					objectData.scaleX(last),
					objectData.scaleY(last),
					objectData.alpha(last)
					);
				objectData.removeLast();
				updateFrameData(newAnim, newTargetTime, boneData.top-boneData.structSize);
			}
		}
	}
	
	private static function willItBlend(firstKey : MainlineKey, secondKey : MainlineKey) : Bool
	{
		if (firstKey.boneRefs != null)
		{
			if (secondKey.boneRefs == null) return false;
			if (firstKey.boneRefs.length != secondKey.boneRefs.length) return false; //TODO really?
		}
		else if (secondKey.boneRefs != null) return false;

		if (firstKey.objectRefs != null)
		{
			if (secondKey.objectRefs == null) return false;
			if (firstKey.objectRefs.length != secondKey.objectRefs.length) return false; //TODO really?
		}
		else if (secondKey.objectRefs != null) return false;

		return true;
	}
	
	private function updateFrameData(animation : Animation, targetTime : Float, parentIndex : Int){

		var keys = animation.mainlineKeys;
		var keyA : MainlineKey = lastKeyForTime(keys, targetTime);
		var nextKey = keyA.id + 1;
		if (nextKey >= keys.length) nextKey = 0;
		var keyB : MainlineKey = keys[nextKey];

		var adjustedTime : Float = adjustTime(keyA, keyB, animation.length, targetTime);

		var start = boneData.top;
		var hasBoneInfos = getBoneInfos(boneData,keyA, animation, targetTime, parentIndex);

		if (keyA.objectRefs == null) return;

		for (i in 0...keyA.objectRefs.length)
		{
			var objectRef  : ObjectRef  = keyA.objectRefs[i];
			var timeline = animation.timelines[objectRef.timelineId];
			var objectData : ObjectData = sprites;
			switch (timeline.objectType)
			{
				case ASprite: 
					objectData = sprites;
				case APoint: 
					objectData = points;
					pointNames.push(timeline.name, objectData.top);
				case ABox: 
					objectData = boxes;
					boxObjectIds.push(timeline.objectId, objectData.top);
				case AnEntity:
				default://dealt elsewhere
			}

			getObjectInfo(objectData, objectRef, animation, adjustedTime);

			if (hasBoneInfos && objectRef.parentId >= 0) {
				applyObjectParentTransformFromBoneData(objectData, boneData, objectData.top-objectData.structSize, start + objectRef.parentId * boneData.structSize);
			}
			
			var last = objectData.top-objectData.structSize;

			if (timeline.objectType == AnEntity){
				var newAnim = animation.entity.spriter.entityArray[objectData.entityId(last)].animations[objectData.animationId(last)];
				var newTargetTime = objectData.t(last) * newAnim.length;
				boneData.write( //copy into boneData to act as parent
					objectData.x(last),
					objectData.y(last),
					objectData.angle(last),
					objectData.scaleX(last),
					objectData.scaleY(last),
					objectData.alpha(last)
					);
				objectData.removeLast();
				updateFrameData(newAnim, newTargetTime, boneData.top-boneData.structSize);
			}
	
		}

	}
	
	private static function adjustTime(keyA : Key, keyB : Key, animationLength : Float, targetTime : Float) : Float
	{
		var nextTime = keyB.time > keyA.time ? keyB.time : animationLength;
		var factor = getFactor(keyA, keyB, animationLength, targetTime);
		return MathHelper.linear(keyA.time, nextTime, factor);
	}
	
	private static function getFactor(keyA : Key, keyB : Key, animationLength : Float, targetTime : Float) : Float
	{
		var timeA = keyA.time;
		var timeB = keyB.time;

		if (timeA > timeB)
		{
			timeB += animationLength;
			if (targetTime < timeA) targetTime += animationLength;
		}

		var computedFactor : Float = MathHelper.reverseLinear(timeA, timeB, targetTime);
		computedFactor = applySpeedCurve(keyA, computedFactor);
		return computedFactor;
	}
	
	private static function applySpeedCurve(key : Key, factor : Float) : Float
	{
		switch (key.curveType)
		{
			case Instant:
				factor = 0.0;
			case Linear:
			case Quadratic:
				factor = MathHelper.curve3(factor, 0.0, key.c1, 1.0);
			case Cubic:
				factor = MathHelper.curve4(factor, 0.0, key.c1, key.c2, 1.0);
			case Quartic:
				factor = MathHelper.curve5(factor, 0.0, key.c1, key.c2, key.c3, 1.0);
			case Quintic:
				factor = MathHelper.curve6(factor, 0.0, key.c1, key.c2, key.c3, key.c4, 1.0);				
			case Bezier:
				factor = MathHelper.bezier(key.c1, key.c2, key.c3, key.c4, factor);
		}

		return factor;
	}
	
	
	
	@:generic
	private static function lastKeyForTime<T:Key>(keys : Array<T>, targetTime : Float) : T
	{
		var current : T = null;
		for(key in keys)
		{
			if (key.time > targetTime) break;
			current = key;
		}

		return current;
	}
	
	private static function getBoneInfo(boneData : BoneData, ref : BoneRef, animation : Animation, targetTime : Float, parent : Bone = null) : Void
	{
		var keys : Array<TimelineKey> = animation.timelines[ref.timelineId].keys;
		var keyA : TimelineKey = keys[ref.keyId];
		var keyB : TimelineKey = getNextXLineKey(keys, keyA, animation.looping);
		if (keyB == null) {
			boneData.write(
				keyA.bone.x,
				keyA.bone.y,
				keyA.bone.angle,
				keyA.bone.scaleX,
				keyA.bone.scaleY,
				keyA.bone.alpha);
		}else{
			var computedFactor : Float = getFactor(keyA, keyB, animation.length, targetTime);
			interpolateBone(boneData, keyA.bone, keyB.bone, computedFactor, keyA.spin);	
		}
	}

	private static function getObjectInfo(objectData : ObjectData, ref : BoneRef, animation : Animation, targetTime : Float) : Void
	{
		var keys : Array<TimelineKey> = animation.timelines[ref.timelineId].keys;
		var keyA : TimelineKey = keys[ref.keyId];
		var keyB : TimelineKey = getNextXLineKey(keys, keyA, animation.looping);

		if (keyB == null) {
			objectData.write(
				keyA.object.animationId,
				keyA.object.entityId,
				keyA.object.folderId,
				keyA.object.fileId,
				keyA.object.pivotX,
				keyA.object.pivotY,
				keyA.object.t,
				keyA.object.x,
				keyA.object.y,
				keyA.object.angle,
				keyA.object.scaleX,
				keyA.object.scaleY,
				keyA.object.alpha);
		}else{
			var computedFactor : Float = getFactor(keyA, keyB, animation.length, targetTime);
			interpolateObject(objectData, keyA.object, keyB.object, computedFactor, keyA.spin);	
		}
	}
	
	private static function interpolateBone(boneData : BoneData, a : Bone, b : Bone, f : Float, spin : Int) : Void
	{
		boneData.write(
			MathHelper.linear(a.x, b.x, f),
			MathHelper.linear(a.y, b.y, f),
			MathHelper.angleLinear(a.angle, b.angle, spin, f),
			MathHelper.linear(a.scaleX, b.scaleX, f),
			MathHelper.linear(a.scaleY, b.scaleY, f),
			1 //TODO should it interpolate alpha?
		);
	}
	
	private static function interpolateBoneFromBoneData(boneData : BoneData, a : Int, b : Int, f : Float, spin : Int) : Void
	{
		
		var ax = boneData.x(a);
		var ay = boneData.y(a);
		var aangle = boneData.angle(a);
		var ascaleX = boneData.scaleX(a);
		var ascaleY = boneData.scaleY(a);
		var aalpha = boneData.alpha(a);
		
		
		var bx = boneData.x(b);
		var by = boneData.y(b);
		var bangle = boneData.angle(b);
		var bscaleX = boneData.scaleX(b);
		var bscaleY = boneData.scaleY(b);
		var balpha = boneData.alpha(b);
		
		boneData.write(
			MathHelper.linear(ax, bx, f),
			MathHelper.linear(ay, by, f),
			MathHelper.angleLinear(aangle, bangle, spin, f),
			MathHelper.linear(ascaleX, bscaleX, f),
			MathHelper.linear(ascaleY, bscaleY, f),
			1 //TODO should it interpolate alpha?
		);
	}

	private static function interpolateObject(objectData : ObjectData, a : Object, b : Object, f : Float, spin : Int) : Void
	{
		objectData.write(
				a.animationId,
				a.entityId,
				a.folderId,
				a.fileId,
				a.pivotX,
				a.pivotY,
				MathHelper.linear(a.t, b.t, f),
				MathHelper.linear(a.x, b.x, f),
				MathHelper.linear(a.y, b.y, f),
				MathHelper.angleLinear(a.angle, b.angle, spin, f),
				MathHelper.linear(a.scaleX, b.scaleX, f),
				MathHelper.linear(a.scaleY, b.scaleY, f),
				MathHelper.linear(a.alpha, b.alpha, f));
		
	}
	
	private static function interpolateObjectFromObjectData(objectData : ObjectData, sourceObjectData : ObjectData, a : Int, b : Int, f : Float, spin : Int) : Void
	{
		var aanimationId = sourceObjectData.animationId(a);
		var aentityId  = sourceObjectData.entityId(a);
		var afolderId = sourceObjectData.folderId(a);
		var afileId = sourceObjectData.fileId(a);
		var apivotX = sourceObjectData.pivotX(a);
		var apivotY = sourceObjectData.pivotY(a);
		var ax = sourceObjectData.x(a);
		var ay = sourceObjectData.y(a);
		var aangle = sourceObjectData.angle(a);
		var ascaleX = sourceObjectData.scaleX(a);
		var ascaleY = sourceObjectData.scaleY(a);
		var aalpha = sourceObjectData.alpha(a);
		var at = sourceObjectData.t(a);
		
		var bx = sourceObjectData.x(b);
		var by = sourceObjectData.y(b);
		var bangle = sourceObjectData.angle(b);
		var bscaleX = sourceObjectData.scaleX(b);
		var bscaleY = sourceObjectData.scaleY(b);
		var balpha = sourceObjectData.alpha(b);
		var bt = sourceObjectData.t(b);
		
		objectData.write(
				aanimationId,
				aentityId,
				afolderId,
				afileId,
				apivotX,
				apivotY,
				MathHelper.linear(at, bt, f),
				MathHelper.linear(ax, bx, f),
				MathHelper.linear(ay, by, f),
				MathHelper.angleLinear(aangle, bangle, spin, f),
				MathHelper.linear(ascaleX, bscaleX, f),
				MathHelper.linear(ascaleY, bscaleY, f),
				MathHelper.linear(aalpha, balpha, f));
		
	}

	@:generic
	private static function getNextXLineKey<T:Key>(keys : Array<T>, firstKey : T, looping : Bool) : T
	{
		if (keys.length == 1) return null;

		var keyBId = firstKey.id + 1;
		if (keyBId >= keys.length)
		{
			if (!looping) return null;
			keyBId = 0;
		}

		return keys[keyBId];
	}
	
	private static function getBoneInfos(boneData : BoneData, key : MainlineKey, animation : Animation, targetTime : Float, parentIndex : Int = -1) : Bool
	{
		if (key.boneRefs == null) return false;
		
		var start = boneData.top;
		for (i in 0...key.boneRefs.length)
		{
			var boneRef : BoneRef = key.boneRefs[i];
			getBoneInfo(boneData, boneRef, animation, targetTime);
			if (boneRef.parentId >= 0) applyParentTransformFromBoneData(boneData,boneData.top-boneData.structSize, start + boneRef.parentId * boneData.structSize);
			else if (parentIndex != -1) applyParentTransformFromBoneData(boneData,boneData.top-boneData.structSize, parentIndex);
		}

		return true;
	}
	

	
	private static function applyParentTransformFromBoneData(boneData : BoneData, i : Int, parentIndex : Int) : Void
	{
		var parentScaleX = boneData.scaleX(parentIndex);
		var parentScaleY = boneData.scaleY(parentIndex);
		var parentAngle = boneData.angle(parentIndex);
		var parentX = boneData.x(parentIndex);
		var parentY = boneData.y(parentIndex);
		
    
        var px = parentScaleX * boneData.x(i);
        var py = parentScaleY * boneData.y(i);
        var s = Math.sin(parentAngle);
        var c = Math.cos(parentAngle);

        boneData.setX(i, px * c - py * s + parentX);
        boneData.setY(i, px * s + py * c + parentY);
        boneData.setScaleX(i, boneData.scaleX(i) * parentScaleX);
        boneData.setScaleY(i, boneData.scaleY(i) * parentScaleY);
        boneData.setAngle(i, parentAngle + (Math.abs(parentScaleX * parentScaleY)/(parentScaleX * parentScaleY)) * boneData.angle(i)); //was Math.Sign(parent.scaleX*parent.scaleY) insteead of abs/
        boneData.setAngle(i, boneData.angle(i) % (Math.PI * 2)); //TODO check modulo operator on float //TODO should us radians	
	}
	
	private static function applyObjectParentTransformFromBoneData(objectData : ObjectData, boneData : BoneData, i : Int, parentIndex : Int) : Void{
		var parentScaleX = boneData.scaleX(parentIndex);
		var parentScaleY = boneData.scaleY(parentIndex);
		var parentAngle = boneData.angle(parentIndex);
		var parentX = boneData.x(parentIndex);
		var parentY = boneData.y(parentIndex);
		
        var px = parentScaleX * objectData.x(i);
        var py = parentScaleY * objectData.y(i);
        var s = Math.sin(parentAngle);
        var c = Math.cos(parentAngle);

        objectData.setX(i,px * c - py * s + parentX);
        objectData.setY(i,px * s + py * c + parentY);
        objectData.setScaleX(i, objectData.scaleX(i) * parentScaleX);
        objectData.setScaleY(i, objectData.scaleY(i) * parentScaleY);
        objectData.setAngle(i, (parentAngle + (Math.abs(parentScaleX * parentScaleY)/(parentScaleX * parentScaleY)) * objectData.angle(i)) % (Math.PI * 2)) ; //was Math.Sign(parent.scaleX*parent.scaleY) insteead of abs/
	}
	
	
	

///////////////////////////////////////////////////////////////////////////////////////////////////////
	//METADATA
///////////////////////////////////////////////////////////////////////////////////////////////////////

	public function updateFrameMetadata2(first : Animation, second : Animation, targetTime : Float, deltaTime : Float, factor : Float)
	{
		var currentAnim = factor < 0.5 ? first : second;
		updateFrameMetadata(currentAnim, targetTime, deltaTime);
	}

	public function updateFrameMetadata(animation : Animation, targetTime : Float, deltaTime : Float, parentInfo : Bone = null)
	{
		//TODO conditions
		/*if (SpriterConfig.VarsEnabled || SpriterConfig.TagsEnabled)*/ addVariableAndTagData(animation, targetTime);
		/*if (SpriterConfig.EventsEnabled)*/ addEventData(animation, targetTime, deltaTime);
		/*if (SpriterConfig.SoundsEnabled)*/ addSoundData(animation, targetTime, deltaTime);
	}


	private function addVariableAndTagData(animation : Animation, targetTime : Float)
	{
		if (animation.meta == null) return;

		//TODO condition
		if (/*spriterConfig.varsEnabled &&*/ animation.meta.varLines != null && animation.meta.varLines.length > 0)
		{
			for (i in 0...animation.meta.varLines.length)
			{
				var varline = animation.meta.varLines[i];
				var variable = animation.entity.variables[varline.def];
				var keyA = getKeyA(animation, varline, targetTime);
				var varValue = if(keyA != null){
					keyA.variableValue;
				}else{
					variable.variableValue;
				}
				var keyB = null;
				if(keyA != null){
					keyB = getKeyB(animation,varline, keyA);
				}
				
				if(keyB != null){
					var adjustedTime = keyA.time == keyB.time ? targetTime : adjustTime(keyA, keyB, animation.length, targetTime);
					var factor = getFactor(keyA, keyB, animation.length, targetTime);
					
					switch(varValue.type){
						case AString: 
							animationVars.strings.push(variable.name, varValue.stringValue);
						case AFloat: 
							animationVars.floats.push(variable.name, MathHelper.linear(keyA.variableValue.floatValue, keyB.variableValue.floatValue, factor));
						case AnInt: 
							animationVars.ints.push(variable.name, Std.int(MathHelper.linear(keyA.variableValue.intValue, keyB.variableValue.intValue, factor)));
					}
					
				}else{
					switch(varValue.type){
						case AString: 
							animationVars.strings.push(variable.name, varValue.stringValue);
						case AFloat: 
							animationVars.floats.push(variable.name, varValue.floatValue);
						case AnInt: 
							animationVars.ints.push(variable.name, varValue.intValue);
					}
				}
				
			}
		}

		var tags = animation.entity.spriter.tags;
		var tagLine = animation.meta.tagLine;
		//TODO condition
		if (/*SpriterConfig.TagsEnabled &&*/ tagLine != null && tagLine.keys != null && tagLine.keys.length > 0)
		{
			var key = lastKeyForTime(tagLine.keys, targetTime);
			if (key != null && key.tags != null)
			{
				for (i in 0...key.tags.length)
				{
					var tag = key.tags[i];
					animationTags.add(tags[tag.tagId].name);
				}
			}
		}

		for (i in 0...animation.timelines.length)
		{
			var timeline = animation.timelines[i];
			var meta = timeline.meta;
			if (meta == null) continue;

			var objInfo = getObjectInfoByAnimation(animation, timeline.name);

			//TODO condition
			if (/*SpriterConfig.VarsEnabled &&*/ meta.varLines != null && meta.varLines.length > 0)
			{
				for (j in 0...timeline.meta.varLines.length)
				{
					var varline = timeline.meta.varLines[j];
					var variable = objInfo.variables[varline.def];
					var keyA = getKeyA(animation, varline, targetTime);
					var varValue = if(keyA != null){
						keyA.variableValue;
					}else{
						variable.variableValue;
					}
					var keyB = null;
					if(keyA != null){
						keyB = getKeyB(animation,varline, keyA);
					}
					
					if(keyB != null){	
						var adjustedTime = keyA.time == keyB.time ? targetTime : adjustTime(keyA, keyB, animation.length, targetTime);
						var factor = getFactor(keyA, keyB, animation.length, targetTime);
						
						switch(varValue.type){
							case AString: 
								objectVars.strings.push(objInfo.name, variable.name, varValue.stringValue);
							case AFloat: 
								objectVars.floats.push(objInfo.name, variable.name, MathHelper.linear(keyA.variableValue.floatValue, keyB.variableValue.floatValue, factor));
							case AnInt: 
								objectVars.ints.push(objInfo.name, variable.name, Std.int(MathHelper.linear(keyA.variableValue.intValue, keyB.variableValue.intValue, factor)));
						}
						
					}else{
						switch(varValue.type){
							case AString: 
								objectVars.strings.push(objInfo.name, variable.name, varValue.stringValue);
							case AFloat: 
								objectVars.floats.push(objInfo.name, variable.name, varValue.floatValue);
							case AnInt: 
								objectVars.ints.push(objInfo.name, variable.name, varValue.intValue);
						}
					}
					
				}
			}

			//TODO condition
			if (/*SpriterConfig.TagsEnabled &&*/ meta.tagLine != null && meta.tagLine.keys != null && meta.tagLine.keys.length > 0)
			{
				var key : TagLineKey = lastKeyForTime(tagLine.keys, targetTime);
				if (key != null && key.tags != null)
				{
					for (j in 0...key.tags.length)
					{
						var tag = key.tags[j];
						var key = tags[tag.tagId].name;
						objectTags.push(objInfo.name,key);
					}
				}
			}
		}
	}
	
	private static function getObjectInfoByAnimation(animation : Animation, name : String) : ObjectInfo
	{
		var objInfo : ObjectInfo = null;
		for (i in 0...animation.entity.objectInfos.length)
		{
			var info = animation.entity.objectInfos[i];
			if (info.name == name)
			{
				objInfo = info;
				break;
			}
		}

		return objInfo;
	}
	
	private static function getKeyA(animation : Animation, varLine : VarLine, targetTime : Float) : VarLineKey{
		var keys = varLine.keys;
		if (keys == null) return null;

		var keyA : VarLineKey = lastKeyForTime(keys, targetTime);
		if(keyA == null){
			keyA = keys[keys.length - 1];
		}
		return keyA;
	}
	
	private static function getKeyB(animation : Animation, varLine : VarLine, keyA : VarLineKey) : VarLineKey{
		return getNextXLineKey(varLine.keys, keyA, animation.looping);
	}
	
	
	private function addEventData(animation : Animation, targetTime : Float, deltaTime : Float)
	{
		if (animation.eventLines == null) return;
		
		var previousTime = targetTime - deltaTime;
		for (i in 0...animation.eventLines.length)
		{
			var eventLine = animation.eventLines[i];
			for (j in 0...eventLine.keys.length)
			{
				var key = eventLine.keys[j];
				if (isTriggered(key, targetTime, previousTime, animation.length)){
					events.push(eventLine.name);
				} 
			}
		}
	}

	private function addSoundData(animation : Animation, targetTime : Float, deltaTime : Float)
	{
		if (animation.soundLines == null) return;

		var previousTime = targetTime - deltaTime;
		for (i in 0...animation.soundLines.length)
		{
			var soundLine = animation.soundLines[i];
			for (j in 0...soundLine.keys.length)
			{
				var key = soundLine.keys[j];
				var sound = key.object;
				if (sound.trigger && isTriggered(key, targetTime, previousTime, animation.length)) sounds.write(sound.id, sound.folderId, sound.fileId, sound.panning, sound.volume);
			}
		}
	}

	private static function isTriggered(key : Key, targetTime : Float, previousTime : Float, animationLength : Float) : Bool
	{
		var timeA = Math.min(previousTime, targetTime);
		var timeB = Math.max(previousTime, targetTime);
		if (timeA > timeB)
		{
			if (timeA < key.time) timeB += animationLength;
			else timeA -= animationLength;
		}
		return timeA <= key.time && timeB >= key.time;
	}

}