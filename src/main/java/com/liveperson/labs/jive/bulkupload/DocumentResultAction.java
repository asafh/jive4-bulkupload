package com.liveperson.labs.jive.bulkupload;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.Set;

import org.apache.commons.httpclient.HttpStatus;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Required;

import com.jivesoftware.base.UnauthorizedException;
import com.jivesoftware.community.Document;
import com.jivesoftware.community.DocumentAlreadyExistsException;
import com.jivesoftware.community.DocumentManager;
import com.jivesoftware.community.DocumentObjectNotFoundException;
import com.jivesoftware.community.JiveContext;
import com.jivesoftware.community.TagDelegator;
import com.jivesoftware.community.lifecycle.JiveApplication;
import com.jivesoftware.community.tags.TagActionUtil;
import com.opensymphony.xwork2.Action;

/**
 * This Action allows some modification after the batch was completed at the results screen.
 * Currently the only modification that can be done is renaming the document
 * @author asafh
 *
 */
public class DocumentResultAction implements Action {
	private static final Logger log = LogManager.getLogger(DocumentResultAction.class);
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 663529071010890779L;
	private String documentID;
	private String subject;
	private String tags;
	//private DocumentManager documentManager;
	private InputStream response;
	protected TagActionUtil tagActionUtil;
	
	/*public String sendNotifications() {
		Document d;
		try {
			d = getDocumentManager().getDocument(documentID);
		} catch (DocumentObjectNotFoundException e) {
			String message = "Document not found: "+documentID;
			log.error(message);
			return error(HttpStatus.SC_NOT_FOUND,message);
		} catch (UnauthorizedException e) {
			String message = "Unauthorized changes to document: "+documentID;
			log.error(message);
			return error(HttpStatus.SC_UNAUTHORIZED,message);
		}
		getWatchManager().__notifyWatchUpdate(d, d.getUser().getID(), ModificationType.Create);
		return success("OK");
	}*/
	/**
	 * This struts method lets you rename a document in the results screen
	 */
	public String rename() {
		if(documentID == null) {
			return error(HttpStatus.SC_NOT_FOUND,"No document id supplied");
		}
		if(subject == null) {
			return error(HttpStatus.SC_BAD_REQUEST,"No subject supplied");
		}
		
		Document d;
		try {
			d = getDocumentManager().getDocument(documentID);
			d.setSubject(subject);
			d.save();
		} catch (DocumentObjectNotFoundException e) {
			String message = "Document not found: "+documentID;
			log.error(message);
			return error(HttpStatus.SC_NOT_FOUND,message);
			//return returnError(message);
		} catch (UnauthorizedException e) {
			String message = "Unauthorized changes to document: "+documentID;
			log.error(message);
			return error(HttpStatus.SC_UNAUTHORIZED,message);
			//return returnError(message);
		} catch (DocumentAlreadyExistsException e) {
			String message = "Document subject already in use: "+subject;
			log.info(message);
			return error(HttpStatus.SC_CONFLICT,message);
		}
		return success(200+"="+getSubject());
	}
	
	/**
	 * This struts method lets you rename a document in the results screen
	 */
	public String editTags() {
		if(documentID == null) {
			return error(HttpStatus.SC_NOT_FOUND,"No document id supplied");
		}
		if(tags == null) {
			return error(HttpStatus.SC_BAD_REQUEST,"No subject supplied");
		}
		
		Document d;
		try {
			d = getDocumentManager().getDocument(documentID);
			TagDelegator tagDelegator = d.getTagDelegator();
			Set<String> validatedTags = tagActionUtil.getValidTags(tags);
			tagDelegator.setTags(validatedTags);
			return success(200+"="+tagDelegator.getTagsAsString());
		} catch (DocumentObjectNotFoundException e) {
			String message = "Document not found: "+documentID;
			log.error(message);
			return error(HttpStatus.SC_NOT_FOUND,message);
			//return returnError(message);
		} catch (UnauthorizedException e) {
			String message = "Unauthorized changes to document: "+documentID;
			log.error(message);
			return error(HttpStatus.SC_UNAUTHORIZED,message);
			//return returnError(message);
		}
	}
	
	private String success(String ret) {
		setResponse(ret);
		return SUCCESS;
		
	}
	private String error(int status, String msg) {
		setResponse(status+"="+msg);
		return ERROR;
	}
	private void setResponse(String msg) {
		setResponse(new ByteArrayInputStream(msg.getBytes()));
	}
	public void setSubject(String subject) {
		this.subject = "".equals(subject) ? null : subject;
	}
	public String getSubject() {
		return subject;
	}
	public void setDocumentID(String documentID) {
		this.documentID = "".equals(documentID) ? null : documentID ;
	}
	public String getDocumentID() {
		return documentID;
	}
	
	public DocumentManager getDocumentManager() {
		return JiveApplication.getEffectiveContext().getDocumentManager();
	}
	public void setResponse(InputStream response) {
		this.response = response;
	}
	public InputStream getResponse() {
		return response;
	}
	@Required
	public void setTagActionUtil(TagActionUtil tagActionUtil) {
		this.tagActionUtil = tagActionUtil;
	}
	@Override
	public String execute() throws Exception {
		return ERROR;
	}
	

	public void setTags(String tags) {
		this.tags = tags;
	}

	public String getTags() {
		return tags;
	}
}
