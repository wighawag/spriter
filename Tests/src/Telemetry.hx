import haxe.macro.Expr;

class Telemetry{
	macro public static function gatherTelemetryDataFor(expr : Expr) : Expr{
		var newExpr = macro {
		var _telemetryData : Telemetry.TelemetryData = @:privateAccess new Telemetry.TelemetryData();
		@:privateAccess _telemetryData.begin();
	};

	newExpr = append(newExpr,expr);
	newExpr = append(newExpr,macro {
		@:privateAccess _telemetryData.end();
		_telemetryData;
	});
	
	
	return newExpr;
	}
	
	static function append(expr : Expr, exprToAdd : Expr) : Expr{
		return
		switch(expr.expr){
			case EBlock(exprs):
				exprs.push(exprToAdd);
				expr;
			default :
				expr.expr = EBlock([{pos:expr.pos,expr:expr.expr}, exprToAdd]);
				expr;
		}
	}
}

#if !macro
class TelemetryData{
	
	public var numAllocations(default,null) : Int = -1;
	public var numReallocations(default,null) : Int = -1;
	public var numDeallocations(default,null) : Int = -1;
	var threadNum : Int = -1;
	private function new(){
	}
	
	private function begin(){
		threadNum = untyped  __global__.__hxcpp_hxt_start_telemetry(true, true);
		untyped  __global__.__hxcpp_hxt_ignore_allocs(1);
		cpp.vm.Gc.run(true);
		untyped  __global__.__hxcpp_hxt_ignore_allocs(-1);
	}
	
	
	private function end(){
		cpp.vm.Gc.run(true);
		untyped  __global__.__hxcpp_hxt_ignore_allocs(1);
		untyped  __global__.__hxcpp_hxt_stash_telemetry();
		gatherData();
	}
	
	@:functionCode('
		TelemetryFrame* frame = __hxcpp_hxt_dump_telemetry(threadNum);
		numAllocations = -1;
		numDeallocations = -1;
		numReallocations = -1;
		if (frame->allocation_data!=0){
			int size = frame->allocation_data->size();
			int i = 0;
			numAllocations = 0;
			numReallocations = 0;
			numDeallocations = 0;
			while (i<size) {
				if (frame->allocation_data->at(i)==0) { // allocation
					i+=5;
					numAllocations++;
				}
				else if (frame->allocation_data->at(i)==1) { 
					i+=2; numDeallocations ++; 
				}
				else if (frame->allocation_data->at(i)==2) {
					i+=4; numReallocations ++; 
				}
			}
			return null();
		}
		
		')
	function gatherData(){
		
	}

}
#end