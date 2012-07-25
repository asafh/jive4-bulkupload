package com.liveperson.labs.jive.bulkupload;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collection;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.zip.ZipEntry;
import java.util.zip.ZipException;
import java.util.zip.ZipFile;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Required;

import com.jivesoftware.base.UnauthorizedException;
import com.jivesoftware.base.User;
import com.jivesoftware.community.AttachmentException;
import com.jivesoftware.community.BinaryBodyException;
import com.jivesoftware.community.Community;
import com.jivesoftware.community.Document;
import com.jivesoftware.community.DocumentAlreadyExistsException;
import com.jivesoftware.community.DocumentManager;
import com.jivesoftware.community.DocumentState;
import com.jivesoftware.community.DocumentType;
import com.jivesoftware.community.DocumentTypeManager;
import com.jivesoftware.community.DuplicateIDException;
import com.jivesoftware.community.JiveConstants;
import com.jivesoftware.community.JiveContext;
import com.jivesoftware.community.RejectedException;
import com.jivesoftware.community.TagDelegator;
import com.jivesoftware.community.action.JiveActionSupport;
import com.jivesoftware.community.lifecycle.JiveApplication;
import com.jivesoftware.community.tags.TagActionUtil;
import com.jivesoftware.community.util.DocumentCollaborationHelper;
import com.jivesoftware.community.web.MimeTypeManager;
import com.jivesoftware.visibility.ContentVisibilityHelper;
import com.jivesoftware.visibility.VisibilityPolicy;

/**
 * This action is the core of the bulk upload utility, it receives the zip files and settings for the upload, creates the appropriate documents
 * and passes the BatchResult to the result page.
 * @author asafh
 *
 */
public class BulkUploadAction extends JiveActionSupport implements
		com.jivesoftware.community.action.UserContainerAware {
	private static final Logger log = LogManager
			.getLogger(BulkUploadAction.class);

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private static final String INPUT_LOCATION = "location-input";

	private static final int VALUE_NOT_SET = 0;
	private boolean publish;
	private boolean extensionless;
	private Set<File> zipFiles;
	private String successUrl;
	private String extensions;

	private BatchResult results;

	// Collab:
	// private DocumentCollaborationHelper collabHelper;
	private VisibilityPolicy visibilityPolicy;
	private String documentViewers;
	private int authorshipPolicy;
	private String documentAuthors;
	private int commentStatus;
	private String documentApprovers;
	private String tags;
	private Set<String> validatedTags;

	private Document document; // dummy

	private ContentVisibilityHelper contentVisibilityHelper;
	protected TagActionUtil tagActionUtil;

	private boolean caseSensitive;
	
	public String inputLocation() {
		return INPUT_LOCATION;
	}
	public String execute() {
		if (zipFiles == null || zipFiles.isEmpty()) {
			return INPUT;
		}
		String batchError = null;
		try {
			setVisibilityHelper((ContentVisibilityHelper) getJiveContext()
					.getSpringBean("visibilityHelper"));
			setResults(new BatchResult());

			String strPublish = getRequest().getParameter("publish");
			setPublish(strPublish != null);

			String strExtensionless = getRequest()
					.getParameter("extensionless");
			setExtensionless(strExtensionless != null);

			String strFilterType = getRequest().getParameter("filterType");
			final boolean excludeExtensions = "exclude"
					.equalsIgnoreCase(strFilterType);
			
			String strCaseSensitive = getRequest().getParameter("caseSensitive");
			caseSensitive = strCaseSensitive != null;

			String strExt = getExtensions();
			if(!caseSensitive) {
				strExt = strExt.toLowerCase(); //Lowercasing all extensions
			}
			String[] arrExt = strExt.split("[\\n,]");//either new line or comma
			
			Set<String> extensions = new HashSet<String>();
			for (String ext : arrExt) {
				extensions.add(ext);
			}
			
			validatedTags = tagActionUtil.getValidTags(tags, this);
			
			for (File file : zipFiles) {
				if (file != null) {
					uploadZip(excludeExtensions, extensions, file);
				}
			}

			return SUCCESS;
		}

		catch (ZipException e) {
			log.error("Zip file error", e);
			batchError = "Could not open zip file: " + e.getMessage();
		} catch (IOException e) {
			log.error("Zip IO error", e);
			batchError = "Could not open zip file (IO Error): "
					+ e.getMessage();
		}
		

		addActionError(batchError);
		return ERROR;
	}
	/**
	 * this method uploads a zip file
	 * @param excludeExtensions
	 * @param extensions
	 * @param file
	 * @throws ZipException
	 * @throws IOException
	 */
	private void uploadZip(boolean excludeExtensions, Set<String> extensions,
			File file) throws ZipException, IOException {
		ZipFile zipped = new java.util.zip.ZipFile(file);
		Enumeration<? extends ZipEntry> entries = zipped.entries();
		ZipEntry entry;

		while (entries.hasMoreElements()) {
			entry = entries.nextElement();
			if (entry.isDirectory()) {
				continue;
			}
			String name = entry.getName();

			int index = name.lastIndexOf('/');
			name = name.substring(index + 1);   //if there is no slash (index is -1), then we want
												// the whole name, otherwise
												// exclude it and all characters before

			boolean include = excludeExtensions;
			String ext = "";
			index = name.lastIndexOf('.'); // getting extension
			if (index == -1) {
				include = isExtensionless();
			} else {
				ext = name.substring(index + 1);
				if(!caseSensitive) {
					ext = ext.toLowerCase();
				}
				include = excludeExtensions ^ extensions.contains(ext); 
				// either extensions match and we include given extensions
				// or no extension match we need to exclude the given extensions
			}
			if (!include) {
				log.debug("Skipping " + name + " with extension " + ext);
				results.addSkipped(name);
				continue;
			}

			InputStream inputStream = zipped.getInputStream(entry);
			String docError = null;
			try {
				if(inputStream.available() == 0) {
					docError = "File is empty";
				}
				else {
					Document d = createDocument(name, inputStream);
					getResults().addDocument(name, d);
					continue;
				}
			} catch (RejectedException re) {
				docError = appendMessage("Document creation rejection", re);
				log.error(docError, re);
			} catch (DocumentAlreadyExistsException e) {
				docError = "There is already a published document with the name \""
						+ name + "\"";
				log.info(docError, e);
			} catch (BinaryBodyException bbe) {
				docError = "Could not create document binary body:";
				switch (bbe.getErrorType()) {
				case BinaryBodyException.BAD_CONTENT_TYPE:
					docError += " Bad content type";
					break;
				case BinaryBodyException.TOO_LARGE:
					docError += " file too large";
					break;
				default:
					docError += " General error (" + bbe.getErrorType() + ")";
					break;
				}
				docError = appendMessage(docError, bbe);

				log.error(name + ": Binary body error (" + docError + ")", bbe);
			} catch (IOException e) {
				log.error(name + ": Document IO error", e);
				docError = appendMessage(
						"Could not create document (IO Error)", e);
			} catch (UnauthorizedException e) {
				log.error(name + ": Permission error", e);
				docError = appendMessage("Unauthorized action", e);
			} catch (AttachmentException e) {
				docError = "Could not create attachment:";
				switch (e.getErrorType()) {
				case AttachmentException.BAD_CONTENT_TYPE:
					docError += " Bad content type";
					break;
				case AttachmentException.TOO_LARGE:
					docError += " Attachment too large";
					break;
				case AttachmentException.NO_EXTENSION:
					docError += " file has no extension";
					break;
				case AttachmentException.TOO_MANY_ATTACHMENTS:
					docError += " Too many attachments";
					break;
				default:
					docError += " General error (" + e.getErrorType() + ")";
					break;
				}
				docError = appendMessage(docError, e);

				log.error(name + ": Binary body error (" + docError + ")", e);
			} catch (DuplicateIDException e) {
				log.error(name + ": Attachment error", e);
				docError = appendMessage("Unexpected error (Duplicate ID)", e);
			}

			getResults().addError(name, docError);
		}
	}

	private static String appendMessage(String docError, Exception e) {
		if (e.getMessage() == null) {
			return docError;
		}
		return docError + ": " + e.getMessage();
	}
	
	/**
	 * Convenience  method to wrap the input stream with a BufferetInputStream
	 * @param name
	 * @param is
	 * @return
	 * @throws DuplicateIDException
	 * @throws AttachmentException
	 * @throws BinaryBodyException
	 * @throws IOException
	 * @throws RejectedException
	 * @throws UnauthorizedException
	 * @throws DocumentAlreadyExistsException
	 */
	private Document createDocument(String name, InputStream is)
			throws DuplicateIDException, AttachmentException,
			BinaryBodyException, IOException, RejectedException,
			UnauthorizedException, DocumentAlreadyExistsException {
		return createDocument(name, new BufferedInputStream(is));
	}
	/**
	 * Creates a new document named <code>name</code> who'se content is <code>is</code>
	 * @param name
	 * @param is
	 * @return
	 * @throws DuplicateIDException
	 * @throws AttachmentException
	 * @throws BinaryBodyException
	 * @throws IOException
	 * @throws RejectedException
	 * @throws UnauthorizedException
	 * @throws DocumentAlreadyExistsException
	 */
	private Document createDocument(String name, BufferedInputStream is)
			throws DuplicateIDException, AttachmentException,
			BinaryBodyException, IOException, RejectedException,
			UnauthorizedException, DocumentAlreadyExistsException {
		/*
		 * int simulateError = -1; switch(simulateError) { case 0: throw new
		 * DuplicateIDException("AHA DUP"); case 1: int attErr =
		 * AttachmentException.BAD_CONTENT_TYPE; throw new
		 * AttachmentException(attErr); case 2: int bbErr =
		 * BinaryBodyException.BAD_CONTENT_TYPE; throw new
		 * BinaryBodyException(bbErr); case 3: throw new IOException("AHA IO");
		 * case 4: throw new RejectedException("REJECTE!!@$"); case 5: throw new
		 * UnauthorizedException("UNAUTH!!!!!"); case 6: throw new
		 * DocumentAlreadyExistsException("pesky little one"); }
		 */

		JiveContext context = JiveApplication.getEffectiveContext();

		DocumentManager documentManager = context.getDocumentManager();
		DocumentTypeManager documentTypeManager = context
				.getDocumentTypeManager();
		DocumentType dt = documentTypeManager.getDefaultDocumentType();
		MimeTypeManager mimeTypeManager = (MimeTypeManager) context
				.getSpringBean("mimeTypeManager");

		Document d = documentManager.createDocument(getUser(), dt, null, name,
				(String) null);

		setCollaboration(d);

		String contentType = mimeTypeManager.getExtensionMimeType(name);
		contentType = mimeTypeManager.getFileMimeType(name, contentType, is);
		if (!JiveApplication.getContext().getBinaryBodyManager()
				.isValidType(contentType)) {
			throw new BinaryBodyException(BinaryBodyException.BAD_CONTENT_TYPE);
		}

		try {
			d.setBinaryBody(name, contentType, is);
		} finally {
			IOUtils.closeQuietly(is);
		}
		

		if (isPublish()) {
			d.setDocumentState(DocumentState.PUBLISHED);
		} else {
			d.setDocumentState(DocumentState.INCOMPLETE);
		}
		
		

		documentManager.addDocument(getContainer(), d, Collections.emptyMap());
		
		d.save();
		TagDelegator tagDelegator = d.getTagDelegator();
		tagDelegator.setTags(validatedTags);

		return d;
	}
	/**
	 * Applies collaboration values for the document (Comment status and authorship policy) 
	 * @param d
	 */
	private void setCollaboration(Document d) {
		DocumentCollaborationHelper collabHelper = new DocumentCollaborationHelper(
				d, getContainer(), getUser(), getJiveContext());
		collabHelper.setAuthors(getDocumentAuthors());
		collabHelper.setApprovers(getDocumentApprovers());

		int authorshipPolicy = getAuthorshipPolicy();
		if (authorshipPolicy != VALUE_NOT_SET) {
			collabHelper.setAuthorshipPolicy(authorshipPolicy);
		}

		int commentStatus = getCommentStatus();
		if (commentStatus != VALUE_NOT_SET) {
			collabHelper.setCommentStatus(commentStatus);
		}

		/*
		 * //TODO: required?: if (isAllowedToModifyApprovers()) {
		 * if(isUserContainer() && getVisibilityPolicy() ==
		 * VisibilityPolicy.restricted){
		 * collabHelper.applyCollaborators(getVisibilityHelper
		 * ().convertToUserIDs(getDocumentViewers())); } else {
		 * collabHelper.applyCollaborators(); } if
		 * (!collabHelper.getDissallowedUsers().isEmpty() ||
		 * !collabHelper.getInvalidUsernames().isEmpty()) { //
		 * addActionMessage(getText("doc.collab.err.no_perm.info")); //
		 * addActionMessage(getText("doc.collab.err.usrsNtFound.text")); return
		 * INPUT; } }
		 */
		if (isUserContainer()
				&& getVisibilityPolicy() == VisibilityPolicy.restricted) {

			collabHelper.applyCollaborators(getVisibilityHelper()
					.convertToUserIDs(getDocumentViewers()));
		} else {
			collabHelper.applyCollaborators();
		}
	}

	public String create() {
		return SUCCESS;
	}

	public String upload() {
		return SUCCESS;
	}

	public void setPublish(boolean publish) {
		this.publish = publish;
	}

	public boolean isPublish() {
		return publish;
	}

	public void setZipFiles(Set<File> zip) {
		this.zipFiles = zip;
	}

	public Set<File> getZipFiles() {
		return zipFiles;
	}

	public void setSuccessUrl(String successUrl) {
		this.successUrl = successUrl;
	}

	public String getSuccessUrl() {
		return successUrl;
	}

	public void setVisibilityPolicy(VisibilityPolicy visibilityPolicy) {
		this.visibilityPolicy = visibilityPolicy;
	}

	public VisibilityPolicy getVisibilityPolicy() {
		return visibilityPolicy;
	}

	public void setDocumentViewers(String documentViewers) {
		this.documentViewers = documentViewers;
	}

	public String getDocumentViewers() {
		return documentViewers;
	}

	public void setAuthorshipPolicy(int authorshipPolicy) {
		this.authorshipPolicy = authorshipPolicy;
	}

	public int getAuthorshipPolicy() {
		return authorshipPolicy;
	}

	public void setDocumentAuthors(String documentAuthors) {
		this.documentAuthors = documentAuthors;
	}

	public String getDocumentAuthors() {
		return documentAuthors;
	}

	public void setCommentStatus(int commentStatus) {
		this.commentStatus = commentStatus;
	}

	public int getCommentStatus() {
		return commentStatus;
	}

	public void setDocumentApprovers(String documentApprovers) {
		this.documentApprovers = documentApprovers;
	}

	public String getDocumentApprovers() {
		return documentApprovers;
	}

	public void setVisibilityHelper(
			ContentVisibilityHelper contentVisibilityHelper) {
		this.contentVisibilityHelper = contentVisibilityHelper;
	}

	public ContentVisibilityHelper getVisibilityHelper() {
		return contentVisibilityHelper;
	}

	/**
	 * Returns true since the page user can add or remove document approvers
	 * (new document)
	 * 
	 * @return true
	 */
	public boolean isAllowedToModifyApprovers() {
		return true;
	}

	public boolean isUserContainer() {
		return getContainer().getObjectType() == JiveConstants.USER_CONTAINER;
	}

	public boolean isEdit() {
		return false;
	}
	/**
	 * Used in ftl doc-javascript-collab.ftl
	 * @return
	 */
	@SuppressWarnings("deprecation")
	public Collection<User> getCommunityApprovers() {
		Set<User> approvers = new HashSet<User>();
		if (getContainer().getObjectType() == JiveConstants.COMMUNITY) {
			Community currentCommunity = (Community) getContainer();
			while (currentCommunity != null) {
				approvers.addAll(getJiveContext().getDocumentManager()
						.getDocumentApprovers(currentCommunity));
				currentCommunity = currentCommunity.getParentCommunity();
			}
		} else {
			approvers.addAll(getJiveContext().getDocumentManager()
					.getDocumentApprovers(getContainer()));
		}
		return approvers;
	}

	public void setDocument(Document document) {
		this.document = document;
	}

	public Document getDocument() {
		return document;
	}

	public List<User> getNoUsers() {
		return Collections.<User> emptyList();
	}

	public void setExtensions(String extensions) {
		this.extensions = extensions;
	}

	public String getExtensions() {
		return extensions;
	}

	public void setExtensionless(boolean extensionless) {
		this.extensionless = extensionless;
	}

	public boolean isExtensionless() {
		return extensionless;
	}

	public void setResults(BatchResult results) {
		this.results = results;
	}

	public BatchResult getResults() {
		return results;
	}
	public void setTags(String keywords) {
		this.tags = keywords;
	}
	public String getKeywords() {
		return tags;
	}
	@Required
	public void setTagActionUtil(TagActionUtil tagActionUtil) {
		this.tagActionUtil = tagActionUtil;
	}
}
