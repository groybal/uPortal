<%--

    Licensed to Jasig under one or more contributor license
    agreements. See the NOTICE file distributed with this work
    for additional information regarding copyright ownership.
    Jasig licenses this file to you under the Apache License,
    Version 2.0 (the "License"); you may not use this file
    except in compliance with the License. You may obtain a
    copy of the License at:

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on
    an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied. See the License for the
    specific language governing permissions and limitations
    under the License.

--%>
<%@ include file="/WEB-INF/jsp/include.jsp"%>
<c:set var="n"><portlet:namespace/></c:set>

<style type="text/css">
    #${n}skinManagerConfig .loadingMessage {
        position: relative;
        top: -150px;
        left: 250px;
        font-size: 50px;
    }
</style>

<portlet:actionURL var="saveUrl"><portlet:param name="action" value="update"/></portlet:actionURL>
<portlet:actionURL var="cancelUrl"><portlet:param name="action" value="cancel"/></portlet:actionURL>

<!-- Portlet -->
<div class="skin-config-portlet" role="section">

    <!-- Portlet Body -->
  <div class="portlet-body" role="main">

        <!-- Portlet Section -->
    <div id="${n}skinManagerConfig" class="portlet-section" role="region">

            <div class="portlet-section-body">

                <form id="${n}dynSkinForm" role="form" class="form-horizontal" action="${ saveUrl }" method="POST">
                    <div class="form-group">
                        <label class="col-sm-2 control-label"><spring:message code="respondr.dynamic.skin.color1"/></label>
                        <input type="color" class="colorPicker" name="color1" value="${color1}"/>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label"><spring:message code="respondr.dynamic.skin.color2"/></label>
                        <input type="color" class="colorPicker" name="color2" value="${color2}"/>
                    </div>
                    <div class="form-group">
                        <label class="col-sm-2 control-label"><spring:message code="respondr.dynamic.skin.color3"/></label>
                        <input type="color" class="colorPicker" name="color3" value="${color3}"/>
                    </div>
                    <div class="buttons">
                        <button type="submit" class="saveButton btn btn-default"><spring:message code="save"/></button>
                        <button type="button" class="cancelButton btn btn-default" onclick="window.location.href='${cancelUrl}'"><spring:message code="cancel"/></button>
                    </div>
                </form>
                <div class="loadingMessage hidden"><i class="fa fa-spinner fa-spin"></i></div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript" src="<rs:resourceURL value="/rs/jquery/1.10.2/jquery-1.10.2.min.js"/>"></script>

<script language="javascript" type="text/javascript">
<rs:compressJs>
/*
 * Switch jQuery to extreme noConflict mode, keeping a reference to it in the dynSkinConfig["${n}"] namespace
 */
var dynSkinConfig = dynSkinConfig || {};
dynSkinConfig["${n}"] = dynSkinConfig["${n}"] || {};
dynSkinConfig["${n}"].jQuery = jQuery.noConflict(true);

dynSkinConfig["${n}"].jQuery(document).ready(function() {
    initDynSkin(dynSkinConfig["${n}"].jQuery, {
        portletSelector: "#${n}skinManagerConfig",
        formSelector: "#${n}dynSkinForm"
    });
});

var initDynSkin = initDynSkin || function($, settings, portletSelector, formSelector) {
    var formUrl = $(settings.formSelector).attr('action');
    // The url contains &amp; which messes up spring webflow. Change them to & so parameters get passed through properly.
    var cancelUrl = "${cancelUrl}".replace(/&amp;/g,"&");

    var showLoading = function() {
        $(settings.formSelector).find(".cancelButton").prop("disabled", true);
        $(settings.formSelector).find(".saveButton").prop("disabled", true);
        $(settings.portletSelector).find(".loadingMessage").removeClass("hidden");
    };

    $(settings.formSelector).submit(function (event) {
        showLoading();
        $.ajax({
            url: formUrl,
            type: "POST",
            data: $(settings.formSelector).serialize()
            })
            // We don't capture error since there is no way the portal will return a different status code on an action url. If there is an
            // error we'd get a web page with content that displayed an error message.
            .success(function(data, textStatus, jqXHR) {
                // Since it saved successfully, invoke cancelUrl to gracefully exit config mode and return to Portlet configuration
                // without spring webflow errors. I'd have thought we could do a portletUrl that sets portletMode=View but it does not
                // seem to work.
                window.location.href=cancelUrl;
            });
        event.preventDefault();
    });
};
</rs:compressJs>
</script>