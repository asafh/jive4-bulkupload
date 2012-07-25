<@resource.javascript header="true">
    var btnSubmitText = '${action.getText('doc.create.sbmtForApprvl.button')?js_string}';
    var btnPublishText = '${action.getText('doc.create.publish.button')?js_string}';
    var isOnloadComplete = false;

    <@jive.userAutocompleteUsers users=action.getNoUsers() varName='documentViewers' />
    <@jive.userAutocompleteUsers users=action.getNoUsers() varName='documentAuthors' />
    <@jive.userAutocompleteUsers users=action.getNoUsers() varName='documentApprovers' />

    <#if (communityApprovers?size == 0) && !isUserContainer>
    function checkApproverStatus() {
        var approversStr = $j('input[name="documentApprovers"]').val();
        if (approversStr && $j.trim(approversStr).length > 0) {
            $j('#postButton').val(btnSubmitText);
        }
        else {
            $j('#postButton').val(btnPublishText);
        }
    }
    </#if>

    function handleDocApproverAdd(user) {
        $j('#postButton').val(btnSubmitText)
    }

    function handleDocAuthorAdd(user) {
        if(isOnloadComplete){
            setAuthorshipPolicy('editingPolicyClosed');
        }
    }

    function handleDocViewerAdd(user) {
        $j('#documentAuthors').trigger('addSelection', [user]);
        toggleCollaboratersAddedMessage();
    }

    function handleDocViewerRemove(userID) {
        $j('#documentAuthors').trigger('removeSelection', [userID]);
        toggleCollaboratersAddedMessage();
    }

    function setAuthorshipPolicy(policy) {
        console.log("policy:" + policy);
        $j('input[name="authorshipPolicy"]').each(function(i) {
            if (this.id == policy) {
                $j(this).attr('checked', 'checked');
            }
            else {
                $j(this).removeAttr('checked');
            }
        });
        if(policy != "editingPolicyClosed"){
            $j('#edit-policy-block ul.holder li.bit-box').each(function() {
                docAuthorChooser.dispose(this);
            });
        }
        if(policy == "editingPolicyPrivate") {
            if($j("#jiveViewersAsEditorsMsg").length > 0){
                $j("#jiveViewersAsEditorsMsg").hide();
            }
        }
    }
          
    function setVisibilityPolicy(policy) {
        $j('input[name="visibilityPolicy"]').each(function(i) {
            if (this.id == policy) {
                $j(this).attr('checked', 'checked');
            }
            else {
                $j(this).removeAttr('checked');
            }
        });
        toggleVisibilityOptions($j("#" + policy));
        toggleVisibilityRelatedOptions($j("#" + policy));
        return false;
    }

    function toggleVisibilityOptions(element){
        if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].owner}'){
            $j('#visibilityPolicyRestrictedPeople').hide();
            $j('#editingPolicyPrivate').attr('readonly', true);
            $j('#editingPolicyPrivate').checked = true;
            $j('#vis1info').show();
            $j('#vis3info').hide();
            $j("#jiveViewersAsEditorsMsg").hide();
        }
        if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].open}'){
            $j('#visibilityPolicyRestrictedPeople').hide();
            $j('#vis1info').hide();
            $j('#vis3info').hide();
            $j("#jiveViewersAsEditorsMsg").hide();
        }
        if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].restricted}'){
            $j('#visibilityPolicyRestrictedPeople').show();
            $j('#vis1info').hide();
            $j('#vis3info').show();
            $j("#jiveViewersAsEditorsMsg").hide();
        }
        return false;
    }

    function toggleVisibilityRelatedOptions(element){
        return _toggleVisibilityRelatedOptions(element, true, null);
    }

    function _toggleVisibilityRelatedOptions(element, resetUsers, editingPolicy){
        var restrictedAuthorText = "<@s.text name="doc.collab.specific_users.radio"/>";
        var viewersAuthorText = "<@s.text name="doc.collab.viewers.radio"/>";
        if(editingPolicy == null){
            if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].owner}'){
                setAuthorshipPolicy('editingPolicyPrivate');
                $j('#documentViewers').trigger('reset');
                $j('#documentAuthors').trigger('reset');
                $j('#documentAuthors').hide();
                $j('#documentAuthors').next('a').hide();
                $j('#jive-extended-options-authorship').find('input').each(function() {$j(this).attr('disabled', 'disabled');});
                $j('#editingPolicyPrivate').attr('readonly', true);
                $j('#editingPolicyPrivate').checked = true;
                $j('#editingPolicyClosed ~ label').text(restrictedAuthorText);
                $j('#authorPolicyClosedPeople > a.jive-chooser-browse').hide()
            }
            if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].open}'){
                if(isOnloadComplete){
                    setAuthorshipPolicy('editingPolicyPrivate');
                    $j('#authorPolicyClosedPeople').hide();
                }
                if(resetUsers){
                    $j('#documentViewers').trigger('reset');
                    $j('#documentAuthors').trigger('reset');
                }
                $j('#documentAuthors').show();
                $j('#documentAuthors').next('a').show();
                $j('#jive-extended-options-authorship').find('input').each(function() {$j(this).removeAttr('disabled');});
                $j('#jive-extended-options-authorship').find('input').each(function() {$j(this).removeAttr('readonly');});
                $j('#editingPolicyClosed ~ label').text(restrictedAuthorText);
                $j('#authorPolicyClosedPeople > a.jive-chooser-browse').show()
            }
            if($j(element).attr("value") == '${statics['com.jivesoftware.visibility.VisibilityPolicy'].restricted}'){
                if(isOnloadComplete){
                    setAuthorshipPolicy('editingPolicyClosed');
                    $j('#authorPolicyClosedPeople').show();
                }
                if(resetUsers){
                    $j('#documentViewers').trigger('reset');
                    $j('#documentAuthors').trigger('reset');
                }
                $j('#documentAuthors').hide();
                $j('#documentAuthors').next('a').hide();
                $j('#jive-extended-options-authorship').find('input').each(function() {$j(this).removeAttr('disabled');});
                $j('#jive-extended-options-authorship').find('input').each(function() {$j(this).removeAttr('readonly');});
                $j('#editingPolicyOpen').attr('disabled', 'disabled');
                $j('#editingPolicyClosed ~ label').text(viewersAuthorText);
                $j('#authorPolicyClosedPeople > a.jive-chooser-browse').hide()
            }
        }else{
            if(editingPolicy == ${statics['com.jivesoftware.community.Document'].AUTHORSHIP_SINGLE?c}){
                setAuthorshipPolicy('editingPolicyPrivate');
                $j('#authorPolicyClosedPeople').hide();
            }else if(editingPolicy == ${statics['com.jivesoftware.community.Document'].AUTHORSHIP_MULTIPLE?c}){
                setAuthorshipPolicy('editingPolicyClosed');
            }else if(editingPolicy == ${statics['com.jivesoftware.community.Document'].AUTHORSHIP_OPEN?c}){
                setAuthorshipPolicy('editingPolicyOpen');
                $j('#authorPolicyClosedPeople').hide();
            }
        }
        return false;
    }

    function toggleCollaboratersAddedMessage(){
        if(!$j("#editingPolicyClosed").attr("checked")){
            return;
        }
        if($j("#documentAuthors").attr("value").split(",").length > 0){
            $j("#jiveViewersAsEditorsMsg").show();
        }
        if($j("#documentAuthors").attr("value").split(",").length == 0){
            $j("#jiveViewersAsEditorsMsg").hide();
        }
        console.log("fired toggleCollaboratersAddedMessage");
    }


    $j(function() {

        jQuery.fn.extend({
            fire: function(evttype){
                el = this.get(0);
                if (document.createEvent) {
                    var evt = document.createEvent('HTMLEvents');
                    evt.initEvent(evttype, false, false);
                    el.dispatchEvent(evt);
                } else if (document.createEventObject) {
                    el.fireEvent('on' + evttype);
                }
                return this;
            }
        });
        $j("#documentViewers").userAutocomplete({
            multiple: true,
            userParam: 'documentViewers',
            startingUsers: documentViewers,
            minInputLength: 2,
            userAdded: handleDocViewerAdd,
            userRemoved: handleDocViewerRemove,
            i18nKeys: {
                remove: '<@s.text name="global.remove"/>',
                add: '<@s.text name="global.add"/>',
                change: '<@s.text name="global.change"/>',
                browse: '<@s.text name="user.picker.title"/>'
            }
        });

        $j("#documentAuthors").userAutocomplete({
            multiple: true,
            userParam: 'documentAuthors',
            startingUsers: documentAuthors,
            minInputLength: 2,
            userAdded: handleDocAuthorAdd,
            inlineRemoval: <#if isUserContainer>true<#else>false</#if>,
            i18nKeys: {
                remove: '<@s.text name="global.remove"/>',
                add: '<@s.text name="global.add"/>',
                change: '<@s.text name="global.change"/>',
                browse: '<@s.text name="user.picker.title"/>'
            }
        });

        $j("#documentApprovers").userAutocomplete({
            multiple: true,
            userParam: 'documentApprovers',
            userValue: 'userName',
            startingUsers: documentApprovers,
            minInputLength: 2,
            userAdded: handleDocApproverAdd,
            i18nKeys: {
                remove: '<@s.text name="global.remove"/>',
                add: '<@s.text name="global.add"/>',
                change: '<@s.text name="global.change"/>',
                browse: '<@s.text name="user.picker.title"/>'
            }
        });

        /* generic options show/hide */
        $j(".jive-compose-section-options h4 a").click(function() {
            $j(this).parent('h4').next('div.jive-compose-options').toggle();
            if ( $j(this).parent('h4').next('div.jive-compose-options').is(':visible') ) {
                $j(this).removeClass('jive-compose-hdr-opt-closed').addClass('jive-compose-hdr-opt');
            } else {
                $j(this).removeClass('jive-compose-hdr-opt').addClass('jive-compose-hdr-opt-closed');
            }
            return false;
        });

        if ( $j("input[name='visibilityPolicy']:checked").val() == 'restricted') {
            $j('#vis3input').show();
        }

        for(var i = 0; i < documentViewers.length; i++){
            var vID = documentViewers[i].userID;
            var isAuthor = false;
            console.log('checking:' + vID);
            for(var j = 0; j < documentAuthors.length; j++){
                if(documentAuthors[j].userID == vID){
                    console.log('is Author:' + vID);
                    isAuthor = true;
                    break;
                }
            }
            if(!isAuthor && vID != -1){
                console.log('Adding Author:' + vID)
                $j('#documentAuthors').trigger('addSelection', [documentViewers[i]]);
                var $wrapper = $j("#documentAuthors").parents().find('.user-autocomplete-selection_' + vID)[0];
                $j($j($wrapper).find('.user-autocomplete-remove')[0]).click();
            }
        }

        //Handle visibility changes
        <#if isUserContainer>
            toggleVisibilityOptions($j("#" + $j('input[name="visibilityPolicy"][value="${visibilityPolicy?js_string}"]').attr("id")));
            <#if !edit>
                _toggleVisibilityRelatedOptions($j("#" + $j('input[name="visibilityPolicy"][value="${visibilityPolicy?js_string}"]').attr("id")), true);
            <#else>
                _toggleVisibilityRelatedOptions($j("#" + $j('input[name="visibilityPolicy"][value="${visibilityPolicy?js_string}"]').attr("id")), false, ${authorshipPolicy});
            </#if>
        </#if>
        isOnloadComplete = true;

        $j('input[name="visibilityPolicy"]').change(function() {
            setVisibilityPolicy(this.id);
            if ( $j("input[name='visibilityPolicy']:checked").val() == 'owner') {
                $j('#visibilityPolicyRestrictedPeople').hide();
            } else if ( $j("input[name='visibilityPolicy']:checked").val() == 'restricted') {
                $j('#visibilityPolicyRestrictedPeople').show();
            } else {
                $j('#visibilityPolicyRestrictedPeople').hide();
            }
            return false;
        });


        $j('input[name="authorshipPolicy"]').change(function() {
            console.log("changing: authorship policy");
            setAuthorshipPolicy(this.id);
            if ( $j("input[name='authorshipPolicy']:checked").val() == '3') {
                $j('#authorPolicyClosedPeople').show();
            } else {
                $j('#authorPolicyClosedPeople').hide();
            }
        });

        $j('input[name="authorshipPolicy"], input[name="visibilityPolicy"]').click(function() {
            if($j.browser.msie) {
                $j(this).fire("change");
            }
        });
    });
</@resource.javascript>
