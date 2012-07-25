<script type="text/javascript">
<#--function sendAllNotifications() {
	$j("a.jive-icon-notify").not("#sendAllNotifications").click();
}
function notifyClicked(anchor,id) {
	$j(anchor).attr("disabled","true");
	$j.ajax({
		type: "GET",
		url: "<@s.url action='bulk-document-result' method='sendNotifications'/>",
		data: {documentID: id},
		success: function(ret,status,jqXHR) {
			$j(anchor).removeAttr("disabled").removeClass('jive-icon-notify').addClass('jive-icon-check').removeAttr('href').removeAttr('onclick').attr("title","Notifications for this document were sent").unbind('click');
		},
		error: function(xhro,err,errorThrown) {
			$j(anchor).removeAttr("disabled"); 
			alert("Unknown error ("+err+"):" +errorThrown);
		}
	});
}-->
function renameDoc(id,name,anchor) {
	if(!name) {
		return;
	}
	$j.ajax({
	type: "GET",
	url: "<@s.url action='bulk-document-result' method='rename'/>",
	data: {documentID: id, subject: name}, //"<updateDocument> <document><documentID> "+id+"</documentID><subject>"+escapeXml(name)+"</subject></document></updateDocument>",
	success: function(ret,status,jqXHR) {
		var ind = ret.indexOf("=");
		var status = parseInt(ret.substring(0,ind));
		var msg = ret.substring(ind+1);
		if(status == 200) {
			$j(anchor).parent().children(".doc-name-cont").text(msg);
			//alert('Successfully renamed: '+msg);
		}
		else {
			alert("An error has occured ("+status+"):\n"+msg);
		}
		
	},
	error: function(xhro,err,errorThrown) {
		//var msg = xhro.getResponseHeader("errorMessage"); 
		alert("Unknown error ("+err+"):" +errorThrown);
	}
	});
}
function editDocTags(id,tags,anchor) {
	if(!tags) {
		return;
	}
	$j.ajax({
	type: "GET",
	url: "<@s.url action='bulk-document-result' method='editTags'/>",
	data: {documentID: id, tags: tags},
	success: function(ret,status,jqXHR) {
		var ind = ret.indexOf("=");
		var status = parseInt(ret.substring(0,ind));
		var msg = ret.substring(ind+1);
		if(status == 200) {
			$j(anchor).attr("title",msg);
		}
		else {
			alert("An error has occured ("+status+"):\n"+msg);
		}
		
	},
	error: function(xhro,err,errorThrown) {
		//var msg = xhro.getResponseHeader("errorMessage"); 
		alert("Unknown error ("+err+"):" +errorThrown);
	}
	});
}
</script>
<div class="jive-box jive-box-form jive-standard-formblock-container jive-box-body jive-standard-formblock" style="margin-top: 10px; margin-left:auto; margin-right: auto; width:900px;">
<style type="text/css">
.bulk-error {
	background-color: #FC6262;
}
.bulk-success {
	background-color: #62FCA3;
}
</style>
<div class="jive-content-block-container" style="margin: 8px;">
    <div class="jive-box-header"><h4>Bulk Upload: Current batch results (under <a href="${statics["com.jivesoftware.community.web.JiveResourceResolver"].getJiveObjectURL(container, true)?html}">${container.displayName?html} </a>):</h4></div>

    <div class="jive-content-block"> <!-- BEGIN content results =====1===== -->
<#if results.entrySet()?has_content>
        <div id="jive-content-results" class="jive-document-content-block-container"> <!-- BEGIN jive-content-results =====2===== -->
            <div id="jive-document-content"> <!-- BEGIN documents content =====3===== -->
                <div class="jive-table"> <!-- BEGIN jive-table =====4===== -->
				<table cellpadding="0" cellspacing="0" border="0">
				    <thead>
				    <tr>
				    	<th width="16px">&nbsp;</th>
				        <th width="200px">Name</th>
						<th width="100px">Status</th>
						<th width="580px">Details</th>
						<#--<th width="16px"><a id="sendAllNotifications" href="#" onclick='sendAllNotifications();' title="Click to send notifications for all documents." class="jive-icon-med jive-icon-notify">&nbsp;</a></th>-->
				    </tr>
				    </thead>
				   <tbody>
			<#list results.entrySet() as entry>
			<#assign name = entry.key>
			<#assign res = entry.value>
			
			<#if res.document?exists>
			<#assign doc = res.document>
				<tr class="jive-table-row-odd">
					<td> <span class="jive-icon-med jive-icon-document"/></td>
					<td>
						<a class='doc-name-cont' href="${statics["com.jivesoftware.community.web.JiveResourceResolver"].getJiveObjectURL(doc, true)?html}">
						${name?html}
						</a>
						<a href="#" onclick="renameDoc('${doc.documentID}',window.prompt('Select a new Name','${doc.subject?html}'),this);" class="jive-icon-sml jive-icon-edit"></a>
						<a href="#" onclick="editDocTags('${doc.documentID}',window.prompt('Choose new tags',this.title),this);" class="jive-icon-sml jive-icon-tag" title="${doc.tagDelegator.tagsAsString?html}"></a>
					</td>
					<td>
						${res.documentStateDisplay?html}
					</td>
					<td>
						&nbsp;
					</td>
					<#--<td>
						<a href="#" title="Click to send notifications about this document" onclick="notifyClicked(this, '${doc.documentID}');" class="jive-icon-med jive-icon-notify"></a>
					</td>-->
				</tr>
			<#else>
				<#assign err = res.error>
				<tr class="jive-table-row-even">
					<td> <span class="jive-icon-med jive-icon-document"/></td>
					<td>
						${name?html}
					</td>
					<td class="jive-error-message">
						Error
					</td>
					<td class="jive-error-message">
						${err?html}
					</td>
				</tr>
			</#if>
			
			</#list>
		</tbody>
				</table>
				</div><!-- END jive-table =====4=====  -->
            </div> <!-- END jive-document-content =====3=====  -->
<#else>
No documents were uploaded
</#if>
<#if results.skipped?has_content>
	The following files were skipped:
	<ul style="list-style-type:circle;">
	<#list results.skipped as sname>
		<li>
			${sname?html}
		</li>
	</#list>
	</ul>
</#if>
<br/>
<div>
	<a href="bulk-upload!inputLocation.jspa"> <span class="jive-icon-med jive-icon-document-upload"></span>Upload another batch</a>
	<br/>
	<a href="bulk-upload.jspa?containerType=${container.objectType?c}&containerID=${container.ID?c}"> <span class="jive-icon-med jive-icon-document-upload"></span>Use same location</a> (<a href="${statics["com.jivesoftware.community.web.JiveResourceResolver"].getJiveObjectURL(container, true)?html}">${container.displayName?html}</a>)
</div>

        </div> <!-- END jive-content-results =====2=====  -->

    </div> <!-- END jive-content-block =====1=====  -->
</div> <!-- END jive-content-block-container -->
</div>