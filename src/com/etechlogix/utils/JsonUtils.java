package com.etechlogix.utils;

import org.json.JSONArray;
import org.json.JSONException;

public class JsonUtils {
	
	public static final int SORT_STRING = 0;
	public static final int SORT_NUMBER = 1;
	
	/**
	 * search() looks for the contents of searchStr in a JSONArray.  If the
	 * contents are found in the JSONArray's rows of data, the row
	 * will be included in the results.  Because the searchStr will be tokenized,
	 * the order of the tokens is irrelevant.  Punctuation will not
	 * be stripped out of the searchStr, but it probably should be.
	 * @param data - a JSONArray, containing some number of JSONObjects
	 * @param searchStr - a string that will be tokenized based on a regex
	 * whitespace delimiter (\s).  If the searchStr is null or blank, the 
	 * entire data set is returned.  
	 * @throws JSONException if the data is not composed of only JSONArrays, or
	 * if another error occurs during the sort.
	 */
	public static JSONArray search(JSONArray data, String searchStr) throws JSONException{
		JSONArray searchedData = new JSONArray();
		if (searchStr == null || searchStr.trim().length() == 0) {
			searchedData = data;
		} else {
			JSONArray row = null;
			try {
				String[] tokens = searchStr.toUpperCase().split("\\s");
				for (int i = 0; i < data.length(); i++) {
					row = data.getJSONArray(i);
					String rowStr = row.toString().toUpperCase();
					boolean match = true;
					for (int j = 0; j < tokens.length; j++) {
						if (rowStr.indexOf(tokens[j]) == -1) {
							match = false;
							break;
						}
					}
					if (match) {
						searchedData.put(row);
					}
				}	
			} catch (JSONException e) {
				Utils.logError(e.getMessage() + ", " +
						"searchStr: '" + searchStr + "' " +
						"row: '" + row.toString() + "'", 
						e);
				searchedData = data;
				throw e;
			}
		}
		return searchedData;
	}
	
	/**
	 * reverse() simply reverses the order of the rows in a JSONArray
	 * @param data a JSONArray of objects
	 * @return a JSONArray of objects in the reverse order
	 * @throws JSONException if an error occurs during the reverse process
	 */
	public static void reverse(JSONArray data) throws JSONException {
		JSONArray reverseData = new JSONArray();
		if (data != null && data.length() > 0) {
			for (int i = data.length(); i > 0; i--) {
				reverseData.put(data.get(i-1));
			}
			for (int i = 0; i < reverseData.length(); i++) {
				data.put(i, reverseData.get(i));
			}
		}
	}
	
	/**
	 * sort() performs a quicksort on a JSONArray, where each row in the 
	 * JSONArray is also a JSONArray.  The user can specify which field in
	 * the row's array to sort by.  This function will likely be used when
	 * the DistUtils.getJsonData() function is called, as that function will
	 * return a JSONArray of JSONArrays (the rows returned by the query).  By
	 * default, the sort will assume a String comparison
	 * @param data JSONArray of JSONArrays
	 * @param column the index of the column to sort by
	 * @throws JSONException
	 */
	public static void sort(JSONArray data, int column) throws JSONException {
		sort(data, column, SORT_STRING);
	}
	
	/**
	 * sort() performs a quicksort on a JSONArray, where each row in the 
	 * JSONArray is also a JSONArray.  The user can specify which field in
	 * the row's array to sort by.  This function will likely be used when
	 * the DistUtils.getJsonData() function is called, as that function will
	 * return a JSONArray of JSONArrays (the rows returned by the query).  	 
	 * @param data JSONArray of JSONArrays
	 * @param column the index of the column to sort by
	 * @param dataType the datatype of the sorting column.  Valid values are
	 * "String" and "Number".  If a null value is passed, "String"
	 * will be assumed  
	 * @throws JSONException if the JSONArray contains rows that are not
	 * @TODO add sort by Date datatype
	 * JSONArray's
	 */
	public static void sort(JSONArray data, int column, int dataType) throws JSONException {
		if (data.length() > 1) {
			quicksort(data, 0, data.length() - 1, column, dataType);
		}
	}
	
	/**
	 * quicksort() is a standard algorithm, in this case written to support
	 * sorting by specific fields within a data structure.  In summary, it
	 * works by picking the middle element of a list called the pivot, moving 
	 * any elements on the left of the pivot that are greater than the pivot
	 * to the right side and any elements on the right of the pivot that are
	 * less than the pivot to the left side.  Once this is done, we know
	 * that the left of the pivot is all less than the right.  We then perform
	 * a recursive sort on the left of the pivot and the right of the pivot.
	 * @param data JSONArray to sort
	 * @param low start of the range to sort
	 * @param high end of the range to sort
	 * @param column index in row's JSONArray to compare
	 * @param dataType type of comparison to do for the index in question.
	 * @throws JSONException
	 */
	private static void quicksort(JSONArray data, int low, int high, int column, int dataType) throws JSONException {
		int i = low;
		int j = high;
		JSONArray pivot = data.getJSONArray(low + (high - low) / 2); 
		while (i <= j) {
			while(compare(data.getJSONArray(i), pivot, column, dataType) < 0) {
				i++;
			}
			while (compare(pivot, data.getJSONArray(j), column, dataType) < 0) {
				j--;
			}
			if (i <= j) {
				exchange(data, i, j);
				i++;
				j--;
			}
		}	
		
		// recursion
		if (low < j) {
			quicksort(data, low, j, column, dataType);
		}
		if (i < high) {
			quicksort(data, i, high, column, dataType);
		}
	}
		
	private static int compare(JSONArray left, JSONArray right, int column, int dataType) throws JSONException {
		int result = 0;
		try {
			if (SORT_NUMBER == dataType) {
				double leftVal = (!left.isNull(column) ? left.getDouble(column) : 0d);
				double rightVal = (!right.isNull(column) ? right.getDouble(column) : 0d);
				if (leftVal < rightVal) {
					result = -1;
				} else {
					result = +1;
				}
			} else { // default to String comparison
				String leftVal = (!left.isNull(column) ? left.getString(column) : "");
				String rightVal = (!right.isNull(column) ? right.getString(column) : "");
				result = leftVal.compareTo(rightVal);			
			}
		} catch (JSONException e) {
			Utils.logError(e.getMessage() + " left: '" + left.toString() + "', " +
					"right: '" + right.toString() + ", column: '" + column + "', " +
					"datatype: '" + dataType + "'", e);
			throw e;
		}
		return result;
	}
	
	private static void exchange(JSONArray data, int i, int j) throws JSONException {
		JSONArray temp = data.getJSONArray(i);
		data.put(i, data.getJSONArray(j));
		data.put(j, temp);
	}
}
