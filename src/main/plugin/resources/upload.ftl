<#assign isUserContainer 	= action.isUserContainer()>
<#assign visibilityPolicy 	= statics['com.jivesoftware.visibility.VisibilityPolicy'].open>
<#assign authorshipPolicy 	= statics['com.jivesoftware.community.Document'].AUTHORSHIP_SINGLE>
<#assign commentStatus 		= statics['com.jivesoftware.community.comments.CommentManager'].COMMENTS_OPEN>


 <html>
 <head>

 <#include "/plugins/bulkupload/resources/doc-javascript-collab.ftl" />
 <script type="text/javascript">
 function nameInputs() {
 	$j('#fileInputs input[type="file"]').each(function(i) {
 		//$j(this).attr("name","zip"+i);
 		$j(this).attr("name","zipFiles");
 	});
 	return true;
 }
 $j(function() {
 	//addFileInput();
 	fileSelected();
 });
 function addFileInput() {
 	var fins = $j("#fileInputs");
	if(fins.children("li").length < 10) {
		var nFin = $j("<li><span class='error-msg jive-icon-med jive-icon-warn' style='visibility:hidden;' title='Selected file is not a zip'></span></li>");
		nFin.append($j("<a href='#' class='jive-icon-med jive-icon-delete' />").click(function() {
			nFin.remove();
			fileSelected();
			enableFileInputRemoval();
		}));
		nFin.append($j("<input type='file'/>").change(fileSelected));
		fins.append(nFin); 		
	}
	else {
		$j("#maxFilesAlert").slideDown(function() {
			setTimeout(function() {
			 $j("#maxFilesAlert").slideUp("slow");
			},2000);
		});
	}
	enableFileInputRemoval();
 }
 function enableFileInputRemoval() {
 	var dels = $j("#fileInputs .jive-icon-delete");
 	if(dels.length > 1) {
 		dels.css("visibility","visible");
 	}
 	else {
 		dels.css("visibility","hidden");
 	}
 }
 function fileSelected() {
 	var hasValid = false;
 	var hasInvalid = false;
 	var emptyCount = 0;
 	$j('#fileInputs input[type="file"]').each(function() {
 		var err = $j(this).parent().children(".error-msg");
 		if( (!this.value) || this.value == "") { //no file selected
 			err.css("visibility","hidden");
 			++emptyCount;
 		}
 		else if(getExtension(this.value).toLowerCase() != "zip") { //file selected and is not a zip
			err.css("visibility","visible");
			hasInvalid = true; 		
 		}
 		else { //zip selected
 			err.css("visibility","hidden");
 			hasValid = true;
 		}
 	});
 	if(emptyCount == 0 && (!hasInvalid)) { //no invalid inputs or free inputs
 		addFileInput();
 	}
 	
 	if(hasInvalid) {
 		$j("#submitUploadBtn").attr("disabled","disabled");
 		$j("#errMsg").fadeIn();
 	}
 	else if (!hasValid) {
 		$j("#submitUploadBtn").attr("disabled","disabled");
 		//$j("errMsg").html("<span class='jive-icon-big jive-icon-warn'></span> No valid zip file is selected");
 		$j("#errMsg").fadeOut();
 	}
 	else {
 		$j("#submitUploadBtn").removeAttr("disabled");
 		$j("#errMsg").fadeOut();
 	}
 	
 }
 function getExtension(filename) {
 	if(filename && filename != "") {
 		var ext = filename.lastIndexOf(".");
 		if(ext != -1) {
 			return filename.substr(ext+1);
 		}
 	}
 	return filename;
 }
 </script>
 <link rel="stylesheet" href="<@resource.url value='/styles/jive-compose.css'/>" type="text/css" media="all" />
 <link rel="stylesheet" href="<@resource.url value='/styles/jive-content.css'/>" type="text/css" media="all" />
 </head>
	<body><!--
		BEGIN main body -->
		
		<div id="jive-body-main">
			<!-- BEGIN main body column -->
			<div id="jive-body-maincol-container">
				<div id="jive-body-maincol" style="padding-bottom: 10px;">
					<#include "/template/global/include/form-message.ftl" />
					<form onsubmit="return nameInputs();" action="<@s.url action='bulk-upload' includeParams='none'/>" method="post" enctype="multipart/form-data" name="postform" id="postform">
						<input type="hidden" name="containerType" id="jive-container-type" value="${containerType?c}" />
                        <input type="hidden" name="containerID" id="jive-container-id" value="${containerID?c}"/>
						<div class="jive-box jive-box-form jive-standard-formblock-container jive-box-body jive-standard-formblock" style="margin-top: 10px; margin-left:10px; width:480px;">
							<table cellpadding="1" cellspacing="3">
								<caption class="jive-body-intro-content">Settings:</caption>
								<thead/>
								<tbody>
								<tr>
									<td>Zip Files: </td>
									<td>
									<ul id="fileInputs" style="list-style-type: none">
									</ul>
									<div id="maxFilesAlert" style="display:none;">
										You can only upload up to 10 zip files at a time.
									</div>
									</td>
								</tr>
								<tr>
									<td class="jive-table-cell-label">
										<label for="publish">
											Publish Documents
											<@s.text name="global.colon" />
										</label>
									</td>
									<td>
										<input type="checkbox" name="publish" />
									</td>
								</tr>
								<tr>
									<td>Filter Extensions:</td>
									<td>
									<span title="Include only files with the following extensions"> <input type="radio" name="filterType" value="include" /> Include Extensions: </span> 
									<span title="Include all files exception files with the following extensions"> <input type="radio" name="filterType" value="exclude" checked /> Exclude Extensions: </span> <br/>
									<textarea name="extensions" rows="4" cols="35" title="Extensions, separated by new line or comma">bin,db,ini</textarea> <br/>
									<span title="Include files without extensions"> Include Extensionless files: <input type="checkbox" name="extensionless" /> </span> <br/>
									<span title="Uncheck if you the extension filtering should be case-insensitive"> Case sensitive filter: <input type="checkbox" name="caseSensitive" checked /> </span> <br/>
									</td>
								</tr>
								<tr>
									<td>Tags:</td>
									<td>
										<input type="text" name="tags" width="100%" />
									</td>
								</tr>
								</tbody>
							</table>
						</div>
						<#include "/template/docs/include/doc-collab.ftl"/>
						<button type="submit" id="submitUploadBtn" name="createButton" style="margin-button: 10px;" class="jive-button jive-formbutton jive-form-button-submit"><span class="jive-icon-med jive-icon-document-upload"></span>Bulk Upload</button>
						<span id="errMsg" style="display:none;"> <span class='jive-icon-big jive-icon-warn'></span> One or more invalid files are selected </span>
					</form>
				</div>
				
			</div>
			<!-- END main body column -->
		</div>
		<!-- END main body--> 
	</body>
</html>