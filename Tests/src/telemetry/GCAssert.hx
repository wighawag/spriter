package telemetry;

import haxe.macro.Expr;

class GCAssert{
	macro public static function gatherTelemetryData(expr : Expr) : Expr{
		var newExpr = macro {
      var _telemetryData : telemetry.TelemetryData = new telemetry.TelemetryData();
      _telemetryData.begin();
    };

    newExpr = append(newExpr,expr);
    newExpr = append(newExpr,macro {
      _telemetryData.end();
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