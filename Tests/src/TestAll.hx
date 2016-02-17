using utest.Assert;

import utest.Runner;
import utest.ui.Report;

import spriter.Spriter;
import spriter.EntityInstance;

import haxe.Json;

using Lambda;

class TestAll{
	
	
	public function testBasicPlayerIsLoaded(){
		var entity = SpriterTest.createEntity("Tests/assets/player.scml", "Player");
		Assert.notNull(entity);	
	}

	public function testBasicPlayerStepAt33(){
		var entity = SpriterTest.createEntity("Tests/assets/player.scml", "Player");
		entity.step(0.033);
		
		assertThatEntityMatch(entity,Embed.fileContentAsString("Tests/assets/data_player_Player_idle_at_33.json"));	
	}
	
	
	public function testBasicPlayerStepAt66(){
		var entity = SpriterTest.createEntity("Tests/assets/player.scml", "Player");
		entity.step(0.066);
		
		assertThatEntityMatch(entity,Embed.fileContentAsString("Tests/assets/data_player_Player_idle_at_66.json"));
	}
	

	public function testBasicPlayerStepAt66In2Steps(){
		var entity = SpriterTest.createEntity("Tests/assets/player.scml", "Player");
		entity.step(0.033);
		entity.step(0.033);
		
		assertThatEntityMatch(entity,Embed.fileContentAsString("Tests/assets/data_player_Player_idle_at_66.json"));	
	}
	
	
	public function testBasicPlayerTransitionFromWalkToCrouchDown(){
		var entity = SpriterTest.createEntity("Tests/assets/player.scml", "Player");
		entity.play("walk");
		entity.step(0.33);
		entity.transition("crouch_down", 1);
		entity.step(0.33);
		
		assertThatEntityMatch(entity,Embed.fileContentAsString("Tests/assets/data_player_Player_walk_at_330_transition_1s_to_Player_crouch_down_at_330.json"));
	}
	
	public function testComplexPlayerStepAt100(){
		var entity = SpriterTest.createEntity("Tests/assets/player_006.scml", "Player");
		entity.play("hit_0");
		entity.step(0.1);
		
		
		assertThatEntityMatch(entity,Embed.fileContentAsString("Tests/assets/data_player_006_Player_hit_0_at_100.json"));	
	}
	
	public function testComplexPlayerStepAt2216(){
		var entity = SpriterTest.createEntity("Tests/assets/player_006.scml", "Player");
		entity.play("idle");
		entity.step(2.216);
		
		
		assertThatEntityMatch(entity,Embed.fileContentAsString("Tests/assets/data_player_006_Player_idle_at_2216.json"));	
	}
	
	public function testTestEntityStepAt910(){
		var entity = SpriterTest.createEntity("Tests/assets/player_006.scml", "TestEntity");
		entity.play("test");
		entity.step(0.91);
		
		
		assertThatEntityMatch(entity,Embed.fileContentAsString("Tests/assets/data_player_006_TestEntity_test_at_910.json"));	
	}
	
	#if HXCPP_TELEMETRY
	
	public function testAllocation(){
			
		var entity = SpriterTest.createEntity("Tests/assets/player_006.scml", "Player");
		
		cpp.vm.Gc.run(true); //not necessary
		
		
		var threadNum = untyped  __global__.__hxcpp_hxt_start_telemetry(true, true);
		
		//var array  = new Array();
		entity.step(2.216);
		
		cpp.vm.Gc.run(true);
		
		untyped __global__.__hxcpp_hxt_ignore_allocs(1);
		
		//advance frame : 
		//untyped __global__.__hxcpp_hxt_ignore_allocs(1);
		untyped __global__.__hxcpp_hxt_stash_telemetry();
		// var gctotal:Int = Std.int((untyped __global__.__hxcpp_gc_reserved_bytes())/1024);
		// var gcused:Int = Std.int((untyped __global__.__hxcpp_gc_used_bytes())/1024);
		// //untyped __global__.__hxcpp_hxt_ignore_allocs(-1);
		// trace(gctotal, gcused);
		
		var numAllocations = getNumAllocations(threadNum);
		
		Assert.equals(0, numAllocations);
	}
	#end
	
	#if HXCPP_TELEMETRY
	
	@:functionCode('
		TelemetryFrame* frame = __hxcpp_hxt_dump_telemetry(thread_num);
		if (frame->allocation_data!=0){
			int size = frame->allocation_data->size();
			int i = 0;
			int count = 0;
			int reallocCount = 0;
			int deallocCount = 0;
			while (i<size) {
				if (frame->allocation_data->at(i)==0) { // allocation
					i+=5;
					count++;
				}
				else if (frame->allocation_data->at(i)==1) { i+=2; deallocCount ++; } // deallocation
				else if (frame->allocation_data->at(i)==2) { i+=4; reallocCount ++; } // reallocation
			}
			printf("realloc :  %d\\ndealloc : %d",reallocCount, deallocCount);
			return count;
		}
		return -1;
	')
	public static function getNumAllocations(thread_num : Int) : Int{
		return 10;
	}
	
	
	
	#end
	
	@:access(spriter)
	private function assertThatEntityMatch(entity : EntityInstance, content : String){
		var expected = Json.parse(content);
		var expectedFrameData = Reflect.field(expected,"frameData");
		var expectedMetadata = Reflect.field(expected,"frameMetadata");
		var frameData = SpriterJson.getFrameData(entity);
		var metadata = SpriterJson.getFrameMetadata(entity);
		Assert.same(expectedFrameData,frameData,true, null,0.001);
		Assert.same(expectedMetadata, metadata,true, null,0.001);
	}
	
	
	public static function main() {
		var runner = new Runner();

		runner.addCase(new TestAll());

		Report.create(runner);
		runner.run();
	}
	public function new() {}
}