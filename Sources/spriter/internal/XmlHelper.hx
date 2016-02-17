package spriter.internal;


class XmlHelper{
	public static function getString(xml : Xml, attName : String, ?defaultValue : String = "") : String{
		if(xml.exists(attName)){
			return xml.get(attName);
		}
		return defaultValue;
	}
	
	public static function getFloat(xml : Xml, attName : String, ?defaultValue : Float = 0) : Float{
		if(xml.exists(attName)){
			return Std.parseFloat(xml.get(attName));
		}
		return defaultValue;
	}
	
	public static function getInt(xml : Xml, attName : String, ?defaultValue : Int = 0) : Int{
		if(xml.exists(attName)){
			return Std.parseInt(xml.get(attName));
		}
		return defaultValue;
	}
	
	public static function getBool(xml : Xml, attName : String, ?defaultValue : Bool = false) : Bool{
		if(xml.exists(attName)){
			return xml.get(attName).toLowerCase() == "true";
		}
		return defaultValue;
	}
}