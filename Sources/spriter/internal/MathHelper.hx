package spriter.internal;

class MathHelper
{
	inline public static function angleLinear(a : Float, b : Float, spin : Int, f : Float) : Float
	{
		if (spin == 0) return a;
		if (spin > 0 && (b - a) < 0) b += Math.PI * 2;
		if (spin < 0 && (b - a) > 0) b -= Math.PI * 2;
		return linear(a, b, f);
	}

	inline public static function closerAngleLinear(a : Float, b : Float, factor : Float) : Float
	{
		if (Math.abs(b - a) < Math.PI) return linear(a, b, factor);
		if (a < b) a += Math.PI * 2;
		else b += Math.PI * 2;
		return linear(a, b, factor);
	}

	inline public static function reverseLinear(a : Float, b : Float, v : Float) : Float
	{
		return (v - a) / (b - a);
	}

	inline public static function linear(a : Float, b : Float, f : Float) : Float
	{
		return a + (b - a) * f;
	}

	
	inline public static function curve3(f : Float, c0 : Float, c1 : Float, c2 : Float) : Float
	{
		c0 = linear(c0,c1,f);
		c1 = linear(c1, c2, f);
		c0 = linear(c0, c1,f);
		return c0;
	}
	
	inline public static function curve4(f : Float, c0 : Float, c1 : Float, c2 : Float, c3 : Float) : Float
	{
		c0 = linear(c0,c1,f);
		c1 = linear(c1, c2, f);
		c2 = linear(c2, c3, f);
		c0 = linear(c0, c1,f);
		c1 = linear(c1, c2,f);
		c0 = linear(c0, c1,f);
		return c0;
	}
	
	inline public static function curve5(f : Float, c0 : Float, c1 : Float, c2 : Float, c3 : Float, c4 : Float) : Float
	{
		c0 = linear(c0,c1,f);
		c1 = linear(c1, c2, f);
		c2 = linear(c2, c3, f);
		c3 = linear(c3, c4, f);
		c0 = linear(c0, c1,f);
		c1 = linear(c1, c2,f);
		c2 = linear(c2, c3, f);
		c0 = linear(c0, c1,f);
		c1 = linear(c1, c2,f);
		c0 = linear(c0, c1,f);
		return c0;
	}
	
	inline public static function curve6(f : Float, c0 : Float, c1 : Float, c2 : Float, c3 : Float, c4 : Float, c5 : Float) : Float
	{
		c0 = linear(c0,c1,f);
		c1 = linear(c1, c2, f);
		c2 = linear(c2, c3, f);
		c3 = linear(c3, c4, f);
		c4 = linear(c4, c5, f);
		c0 = linear(c0, c1,f);
		c1 = linear(c1, c2,f);
		c2 = linear(c2, c3, f);
		c3 = linear(c3, c4, f);
		c0 = linear(c0, c1,f);
		c1 = linear(c1, c2,f);
		c2 = linear(c2, c3, f);
		c0 = linear(c0, c1,f);
		c1 = linear(c1, c2,f);
		c0 = linear(c0, c1,f);
		return c0;
	}

	inline public static function bezier(x1 : Float, y1 : Float, x2 : Float, y2 : Float, t : Float) : Float
	{
		var duration : Float = 1.0;
		var cx : Float = 3.0 * x1;
		var bx : Float = 3.0 * (x2 - x1) - cx;
		var ax : Float = 1.0 - cx - bx;
		var cy : Float = 3.0 * y1;
		var by : Float = 3.0 * (y2 - y1) - cy;
		var ay : Float = 1.0 - cy - by;

		return solve(ax, bx, cx, ay, by, cy, t, solveEpsilon(duration));
	}

	inline static function sampleCurve(a : Float, b : Float, c : Float, t : Float) : Float
	{
		return ((a * t + b) * t + c) * t;
	}

	inline static function sampleCurveDerivativeX(ax : Float, bx : Float, cx : Float, t : Float) : Float
	{
		return (3.0 * ax * t + 2.0 * bx) * t + cx;
	}

	inline static function solveEpsilon(duration : Float) : Float
	{
		return 1.0 / (200.0 * duration);
	}

	inline static function solve(ax : Float, bx : Float, cx : Float, ay : Float, by : Float, cy : Float, x : Float, epsilon : Float) : Float
	{
		return sampleCurve(ay, by, cy, solveCurveX(ax, bx, cx, x, epsilon));
	}

	static function solveCurveX(ax : Float, bx : Float, cx : Float, x : Float, epsilon : Float) : Float
	{
		var t0 : Float;
		var t1 : Float;
		var t2 : Float;
		var x2 : Float;
		var d2 : Float;
		var i : Int;

		// First try a few iterations of Newton's method -- normally very fast.
		var i = 0;
		t2 = x;
		while(i<8){
			x2 = sampleCurve(ax, bx, cx, t2) - x;
			if (Math.abs(x2) < epsilon) return t2;

			d2 = sampleCurveDerivativeX(ax, bx, cx, t2);
			if (Math.abs(d2) < 1e-6) break;

			t2 = t2 - x2 / d2;
			i++;
		}

		// Fall back to the bisection method for reliability.
		t0 = 0.0;
		t1 = 1.0;
		t2 = x;

		if (t2 < t0) return t0;
		if (t2 > t1) return t1;

		while (t0 < t1)
		{
			x2 = sampleCurve(ax, bx, cx, t2);
			if (Math.abs(x2 - x) < epsilon) return t2;
			if (x > x2) t0 = t2;
			else t1 = t2;
			t2 = (t1 - t0) * 0.5 + t0;
		}

		return t2; // Failure.
	}
}