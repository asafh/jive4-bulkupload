package com.liveperson.labs.jive.bulkupload;

import com.jivesoftware.community.Document;
import com.jivesoftware.community.DocumentState;

/**
 * This class represents the result for uploading one document (out of the batch)
 * @author asafh
 *
 */
public class DocumentResult {
	private static boolean isNull(Object o) {
		return o == null;
	}

	private Document document;
	private String error;
	private String name;
	/**
	 * Creates a document result, exactly one of [document, error] should be null
	 * @param name The name of document attempted to upload
	 * @param document The created document, if succeeded
	 * @param error The error (to display to the error) if failed
	 */
	private DocumentResult(String name, Document document, String error) {
		if (!(isNull(document) ^ isNull(error))) { // if both or neither are
													// null
			throw new IllegalStateException(
					"Exactly one of either document or error must be null");
		}

		this.setName(name);
		this.setDocument(document);
		this.setError(error);
	}
	/**
	 * Creates a new DocumentResult describing an error for document <code>name</code>
	 * @param name
	 * @param error
	 */
	public DocumentResult(String name, String error) {
		this(name, null, error);
	}
	/**
	 * Creates a new DocumentResult describing a successful upload for document <code>name</code>
	 * @param name
	 * @param document
	 */
	public DocumentResult(String name, Document document) {
		this(name, document, null);
	}
	
	/**
	 * Returns the a user friendly name of state the document is (i.e. Published or Draft)
	 * if this document result describes an error, a NullPointerException will be thrown  
	 * @return
	 * @throws NullPointerException if this DocumentResult describes an error
	 */
	public String getDocumentStateDisplay() {
		DocumentState state = getDocument().getDocumentState();
		switch (state) {
		case PUBLISHED:
			return "Published";
		case INCOMPLETE:
			return "Draft";
		default:
			return state.getState();
		}
	}
	/**
	 * Gets the successfully uploaded document, null if this is an error
	 * @return
	 */
	public Document getDocument() {
		return document;
	}
	/**
	 * Returns the name of the document attempted to upload
	 * @return
	 */
	public String getName() {
		return name;
	}
	/**
	 * Returns the user friendly error message, null if this describes a successful upload
	 * @return
	 */
	public String getError() {
		return error;
	}

	protected void setDocument(Document document) {
		this.document = document;
	}

	protected void setError(String error) {
		this.error = error;
	}

	protected void setName(String name) {
		this.name = name;
	}
}
