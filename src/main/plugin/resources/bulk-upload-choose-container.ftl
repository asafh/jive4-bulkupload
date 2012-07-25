<#--
  - $Revision: 32834 $
  - $Date: 2006-08-02 15:56:32 -0700 (Wed, 02 Aug 2006) $
  -
  - Copyright (C) 1999-2008 Jive Software. All rights reserved.
  - This software is the proprietary information of Jive Software. Use is subject to license terms.
-->

<html>
<head>
    <#if contentType == JiveConstants.ANNOUNCEMENT>   
        <#include '/template/global/include/manage-announcements.ftl' />
    </#if>
    <title>${title?html}</title>

    <meta name="nosidebar" content="true" />

    <content tag="breadcrumb">
        <@s.action name="community-breadcrumb" executeResult="true" ignoreContextParams="true">
            <#if container?exists>
            <@s.param name="containerType">${container.objectType?c}</@s.param>
            <@s.param name="container">${container.ID?c}</@s.param>
            </#if>
        </@s.action>
    </content>

    <#if (userContainer?exists) >
    <script type="text/javascript">
        function chooseUserContainer() {
            $j('#jive-container-id').val("${userContainer.ID?c}");
            $j('#jive-container-type').val("${JiveConstants.USER_CONTAINER?c}");
            $j('#jive-view').val("VIEW_VIDEO");
            $j('#choosejivecontainerform').submit();
        }
    </script>
    </#if>

</head>
<body class="jive-body-formpage jive-body-choose-container">

<!-- BEGIN header & intro  -->
<div id="jive-body-intro">
    <div id="jive-body-intro-content">
        <#if !container?exists  || (action.isRootContainer() && contentType != JiveConstants.ANNOUNCEMENT)>
         <h1>${"Documents Bulk Upload"?html}<span><@s.text name="global.colon"/> <@s.text name="container.choose.location"/></span></h1>
        <#else>
         <h1>${"Documents Bulk Upload"?html}</h1>
        </#if>
    </div>
</div>
<!-- END header & intro -->


<!-- BEGIN main body -->
<div id="jive-body-main">


    <!-- BEGIN main body column -->
    <div id="jive-body-maincol-container">
        <div id="jive-body-maincol">

            <!-- BEGIN formblock -->
            <div class="jive-box jive-box-form jive-standard-formblock-container">
                <div class="jive-box-body jive-standard-formblock clearfix">

                    <form action="<@s.url action='bulk-upload-choose-container'/>" id="choosejivecontainerform" name="jivechoosecontainerform">
                        <input type="hidden" name="view" id="jive-view" value="${view!}"/>
                        <input type="hidden" name="prefix" id="jive-alpha-prefix" value="${prefix!}"/>
                        <input type="hidden" name="contentType" id="jive-content-type" value="${contentType?c}"/>
                        <input type="hidden" name="containerType" id="jive-container-type"/>
                        <input type="hidden" name="container" id="jive-container-id"/>

                        <#if tempObjectID?has_content>
                            <input type="hidden" name="tempObjectID" id="jive-content-tempObjectID" value="${tempObjectID?html}"/>
                        </#if>
                        <#if subject?has_content>
                            <input type="hidden" name="subject" id="jive-content-subject" value="${subject?html}"/>
                        </#if>
                        <#if tags?has_content>
                            <input type="hidden" name="tags" id="jive-content-tags" value="${tags?html}"/>
                        </#if>
							<#-- not required:
                            <#if action.isBinaryBodyUploadCapable() && binaryEnabled && !tempObjectID?exists>
                                <div id="jive-choose-content-type" class="clearfix">
                                    <span onClick="jivechoosecontainer.selectWriteContent();" id="jive-content-type-write" <#if !upload>class="jive-choose-content-type-selected"</#if>>
                                        <input onChange="jivechoosecontainer.selectWriteContent();" type="radio" name="upload" value="false" id="jive-content-collab" <#if !upload>checked="checked"</#if>/>
                                        <label for="jive-content-collab"><@s.text name="content.picker.crtNwCnt.button"/></label>
                                    </span>
                                    <span onClick="jivechoosecontainer.selectUpload();" id="jive-content-type-upload" <#if upload>class="jive-choose-content-type-selected"</#if>>
                                        <input onChange="jivechoosecontainer.selectUpload();" type="radio" name="upload" value="true" id="jive-content-upload" <#if upload>checked="checked"</#if>/>
                                        <label for="jive-content-upload"><@s.text name="content.picker.upldNwCnt.button"/></label>
                                    </span>
                                </div>
                            </#if> -->
                        </form>

                    <#--BEGIN doc create continue -->
                    <div id="jive-doc-create-continue" class="clearfix">
                        <#if action.isBinaryBodyUploadCapable() && binaryEnabled && !tempObjectID?exists>
                            <p>
                                <@s.text name="document.picker.container.selected" /><@s.text name="global.colon"/>
                                <span id="jive-selected-doctype">Bulk document upload</span>
                            </p>
                        </#if>

                        <#if container?exists && !tempObjectID?exists && ((!action.isRootContainer() && contentType != JiveConstants.ANNOUNCEMENT) ||(contentType == JiveConstants.ANNOUNCEMENT))>
                           <#if contentType == JiveConstants.ANNOUNCEMENT>
                                <input id="annNotifyCreateNew" type="button" value="<@s.text name="global.continue"/>"/>
                           <#else>
                                <input type="button" value="<@s.text name="global.continue"/>" onclick="return jivechoosecontainer.submitForm(${container.objectType?c}, ${container.ID?c}); return false;" />
                           </#if>
                           <input type="button" value="<@s.text name="global.cancel"/>" onclick="location.href='<@s.url value='${JiveResourceResolver.getJiveObjectURL(container)}'/>'; return false;" />
                        <#else>                             
                            <#if action.isBinaryBodyUploadCapable() && binaryEnabled && !tempObjectID?exists>
                                <hr noshade size="1"/>
                            </#if>
                            <#if contentType == JiveConstants.DOCUMENT && tempObjectID?exists>
                                <!-- Special logic for converted threads -->
                                <p>
                                    <@s.text name="container.choose.current.location">
                                    <@s.param>
                                    <a href="#"
                                       onclick="return jivechoosecontainer.submitForm(${container.objectType?c},
                                       ${container.ID?c}); return false;">
                                        <#if action.isUserContainer(container)>
                                            <span class="jive-icon-sml jive-icon-people"></span>${container.name?html}
                                        <#else>
                                            <span class="${SkinUtils.getJiveObjectCss(container, 0)}"></span>${container.name?html}
                                        </#if>
                                    </a>
                                    </@s.param>
                                    </@s.text>
                                </p>
                            </#if>

                            <#--BEGIN container block-->

                            <div id="jive-choose-container-block" class="clearfix">

                                <div id="jive-choose-containers" class="clearfix">


                                    <#--BEGIN choose container views-->
                                    <div id="jive-choose-containers-views">
                                        <#if (contentType != JiveConstants.BLOGPOST && action.isAllowedInPersonalContainer(action.getContentType()) && userContainer?exists)>
                                            <#if contentType == JiveConstants.THREAD>
                                                <div onclick="chooseUserContainer();" class="jive-choose-containers-personal">
                                                    <span class="jive-icon-med jive-icon-discussion"></span><@s.text name="ctr.choose.myctr.discussion.header" />
                                                </div>
                                            </#if>
                                            <#if contentType == JiveConstants.DOCUMENT>
                                                <div onclick="chooseUserContainer();" class="jive-choose-containers-personal">
                                                    <span class="jive-icon-med jive-icon-document"></span><@s.text name="ctr.choose.myctr.document.header" />
                                                </div>
                                            </#if>
                                            <#if contentType == JiveConstants.POLL>
                                                <div onclick="chooseUserContainer();" class="jive-choose-containers-personal">
                                                <span class="jive-icon-med jive-icon-poll"></span><@s.text name="ctr.choose.myctr.poll.header" />
                                                </div>
                                            </#if>
                                            <#if contentType == JiveConstants.VIDEO>
                                                <div onclick="chooseUserContainer();" class="jive-choose-containers-personal">
                                                <span class="jive-icon-med jive-icon-video"></span><@s.text name="ctr.choose.myctr.${action.getJiveObjectType().getCode()}.header" />
                                                </div>
                                            </#if>
                                            <#if contentType != JiveConstants.POLL && contentType != JiveConstants.DOCUMENT && contentType != JiveConstants.THREAD && contentType != JiveConstants.VIDEO>
                                            <div onclick="chooseUserContainer();" class="jive-choose-containers-personal">
                                                    <span class="${SkinUtils.getJiveObjectIconForType(contentType,true,1)}"></span><@s.text name="ctr.choose.profile.header"/>
                                            </div>
                                            </#if>
                                        <#elseif (contentType == JiveConstants.BLOGPOST)>
                                            <div class="jive-choose-containers-personal">
                                            <#if personalBlog?exists>
                                                <a href="#" class="font-color-meta"
                                                    onclick="return jivechoosecontainer.submitForm(${personalBlog.objectType?c},
                                                    ${personalBlog.ID?c}); return false;"><span class="${SkinUtils.getJiveObjectCss(personalBlog, 1)}"></span>${personalBlog.name?html}</a>
                                            <#elseif BlogPermHelper.getCanCreateBlog()>
                                                <p class="jive-blog-nopersonal">
                                                    <@s.text name="blogs.picker.create.new.text">
                                                        <@s.param><a href="<@s.url action="blogs-create-blog" method="input" />"></@s.param>
                                                        <@s.param></a></@s.param>
                                                    </@s.text>
                                                </p>
                                            </#if>
                                            </div>
                                        </#if>

                                        <div onclick="jivechoosecontainer.setView(this, '${statics["com.jivesoftware.community.action.ChooseContainerListAction"].VIEW_SEARCH}');" class="jive-choose-container-currentview">
                                            <span class="jive-icon-med jive-icon-search"></span>
                                                <@s.text name="ctr.choose.search.header"/>

                                        </div>
                                        <#if (userFollowedCommunityCount > 0)>
                                            <div onclick="jivechoosecontainer.setView(this, '${statics["com.jivesoftware.community.action.ChooseContainerListAction"].VIEW_USER_COMMUNITIES}');">
                                                <span class="jive-icon-med jive-icon-space"></span><@s.text name="ctr.choose.mycom.header"/>
                                            </div>
                                        </#if>
                                        <div onclick="jivechoosecontainer.setView(this, '${statics["com.jivesoftware.community.action.ChooseContainerListAction"].VIEW_COMMUNITIES}');">
                                            <span class="jive-icon-med jive-icon-space"></span><@s.text name="ctr.choose.com.header"/>
                                        </div>
                                        <#if projectsEnabled && contentType != JiveConstants.PROJECT>
                                            <#if (userTrackedProjectCount > 0)>
                                                <div onclick="jivechoosecontainer.setView(this, '${statics["com.jivesoftware.community.action.ChooseContainerListAction"].VIEW_USER_PROJECTS}');">
                                                    <span  class="jive-icon-med jive-icon-project"></span><@s.text name="ctr.choose.mypjt.header"/>
                                                </div>
                                            </#if>

                                            <div onclick="jivechoosecontainer.setView(this, '${statics["com.jivesoftware.community.action.ChooseContainerListAction"].VIEW_PROJECTS}');">
                                                <span  class="jive-icon-med jive-icon-project"></span><@s.text name="ctr.choose.pjt.header"/>
                                             </div>
                                        </#if>
                                        <#if socialGroupsEnabled>
                                            <#if (userSocialGroupCount > 0)>
                                                <div  onclick="jivechoosecontainer.setView(this, '${statics["com.jivesoftware.community.action.ChooseContainerListAction"].VIEW_USER_SOCIAL_GROUPS}');">
                                                    <span  class="jive-icon-med jive-icon-group"></span><@s.text name="ctr.choose.mysgroup.header"/>
                                                </div>
                                            </#if>
                                            <div onclick="jivechoosecontainer.setView(this, '${statics["com.jivesoftware.community.action.ChooseContainerListAction"].VIEW_SOCIAL_GROUPS}');">
                                                <span  class="jive-icon-med jive-icon-group"></span><@s.text name="ctr.choose.sgroup.header"/>
                                            </div>
                                        </#if>
                                        <#if (contentType == JiveConstants.BLOGPOST && otherBlogCount > 0)>
                                            <div onclick="jivechoosecontainer.setView(this, '${statics["com.jivesoftware.community.action.ChooseContainerListAction"].VIEW_BLOGS}');">
                                                <span class="jive-icon-med jive-icon-blog"></span><@s.text name="ctr.choose.blgpst.header"/>
                                            </div>
                                        </#if>

                                        <#list customContainerTypes as containerType>
                                            <div onclick="jivechoosecontainer.setView(this, '${containerType.code}');">
                                                <span class="${containerType.typeUIProvider.linkMediumCSS}"></span><@s.text name="ctr.choose.${containerType.code}.header"/>
                                            </div>
                                        </#list>



                                    </div>

                                    <#--END choose container views-->

                                    <div id="jive-choose-containers-results-container">
                                    <div id="jive-choose-containers-results">

                                        <div id="jive-choose-container-searchbox">
                                            <@s.text name="ctr.choose.search.header"/>
                                            <input type="text" id="jive-choose-container-query" name="query" autocomplete="off"/>
                                        </div>

                                        <div id="jive-choose-containers-result-block">
                                        <@s.action name='choose-container-list' executeResult='true'>
                                            <@s.param name='contentType' value='${contentType?c}'/>
                                        </@s.action>
                                        </div>
                                    </div>

                                        <#-- Show a message regarding containers that you can view but not post in -->
                                        <p class="jive-key-unavailable">
                                            <span class="jive-container-unavailable">
                                                <@s.text name="container.choose.gray.why" />
                                            </span>
                                            <span>
                                                <@s.text name="container.choose.gray.answer" />
                                            </span>
                                        </p>

                                    </div>


                                </div>
                            </div>
                            <#--END container block-->
                        </#if>
                    </div>
                    <#--END doc create continue -->


                </div>
            </div>
            <!-- END formblock -->

                    <@resource.javascript file="/resources/scripts/lib/event.js"/>
                    <@resource.javascript file="/resources/scripts/jivechoosecontainer.js"/>
                    <script type="text/javascript">
                        var jiveContentType = ${contentType?c};
                        var jiveChooseContainerAction = "<@s.url action='choose-container-list' />";
                        var jiveCreateDocButton = "<@s.text name='content.picker.crtNwCnt.button'/>"
                        var jiveUploadDocButtonText = "<@s.text name='content.picker.upldNwCnt.button'/>"
                        var chooseSearchEmpty = "<@s.text name='ctr.choose.search.emty'/>";
                    </script>
                    <@resource.javascript>
                        $j(document).ready(function() {
                            window.jivechoosecontainer = new JiveChooseContainer({
                                suggestionsContainer: '#jive-choose-containers-result-block',
                                contentType: jiveContentType,
                                chooseContainerURL: jiveChooseContainerAction,
                                currentViewClass: 'jive-choose-container-currentview',
                                queryElement: '#jive-choose-container-query',
                                resultListElement: '#jive-choose-container-resultlist',
                                i18n: {
                                    writeDocumentText: jiveCreateDocButton,
                                    uploadDocumentText: jiveUploadDocButtonText,
                                    queryResultsEmptyText: chooseSearchEmpty
                                }
                            });
                        });
                    </@resource.javascript>

            </div>
        </div>
        <!-- END main body column -->


    </div>
    <!-- END main body -->
<#if contentType == JiveConstants.ANNOUNCEMENT>
    <@resource.dwr file="ManageAnnouncement" />
</#if>
</body>
</html>
