package com.liveperson.labs.jive.bulkupload;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.jivesoftware.community.Document;

/**
 * This class agregates results for a batch of uploads.
 * @author asafh
 *
 */
public class BatchResult {
	private Map<String, DocumentResult> resultMap;
	private List<String> skipped;
	/**
	 * Creates an empty BatchResult
	 */
	public BatchResult() {
		resultMap = new HashMap<String, DocumentResult>();
		skipped = new ArrayList<String>();
	}
	public Set<Map.Entry<String,DocumentResult>> entrySet() {
		return resultMap.entrySet();
	}
	public Collection<String> getSkipped() {
		return skipped;
	}
	/**
	 * Adds a result for the document with name <code>name</code> as an error with error message <code>error</code>
	 * @param name
	 * @param error
	 */
	public void addError(String name, String error) {
		addResult(new DocumentResult(name, error));
	}
	/**
	 * Adds a result for the document with name <code>name</code> as an successful upload with document <code>doc</code>
	 * @param name
	 * @param doc
	 */
	public void addDocument(String name, Document doc) {
		addResult(new DocumentResult(name, doc));
	}
	private void addResult(DocumentResult documentResult) {
		resultMap.put(documentResult.getName(), documentResult);
	}
	public void addSkipped(String name) {
		skipped.add(name);
	}
}
