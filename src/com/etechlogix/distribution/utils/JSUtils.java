package com.etechlogix.distribution.utils;

import org.json.JSONArray;
import org.json.JSONObject;

public class JSUtils {
	
	public static void setFieldValue(JSONArray jsonArray, String field, String value) throws Exception {		
		JSONObject fieldValueObject = new JSONObject();
		fieldValueObject.put("field", field);
		fieldValueObject.put("value", value != null ? value : "");
		jsonArray.put(fieldValueObject);		
	}
	
	public static void setFieldValue(JSONArray jsonArray, String field, boolean value) throws Exception{		
		JSONObject fieldValueObject = new JSONObject();
		fieldValueObject.put("field", field);
		fieldValueObject.put("value", value);
		jsonArray.put(fieldValueObject);		
	}
	
	public static void setFieldValue(JSONArray jsonArray, String field, String value, String prop, String propValue) throws Exception{		
		JSONObject fieldValueObject = new JSONObject();
		fieldValueObject.put("field", field);
		fieldValueObject.put("value", value);
		fieldValueObject.put("prop", prop);
		fieldValueObject.put("propValue", propValue);
		jsonArray.put(fieldValueObject);		
	}
	
	public static void setFieldValue(JSONArray jsonArray, String field, String value, String prop) throws Exception{		
		if(value == null || value.trim().equals("")) 
			value="N";
		JSONObject fieldValueObject = new JSONObject();
		fieldValueObject.put("field", field);
		fieldValueObject.put("value", value);
		fieldValueObject.put("prop", prop);
		fieldValueObject.put("propValue", value.equals("Y") ? true : false);
		jsonArray.put(fieldValueObject);		
	}
	
	public static void setFieldPropValue(JSONArray jsonArray, String field, String prop, boolean propValue) throws Exception{		
		JSONObject fieldValueObject = new JSONObject();
		fieldValueObject.put("field", field);
		fieldValueObject.put("prop", prop);
		fieldValueObject.put("propValue", propValue);
		jsonArray.put(fieldValueObject);		
	}

}
