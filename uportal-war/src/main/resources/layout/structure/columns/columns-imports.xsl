<?xml version="1.0" encoding="utf-8"?>
<!--

    Licensed to Apereo under one or more contributor license
    agreements. See the NOTICE file distributed with this work
    for additional information regarding copyright ownership.
    Apereo licenses this file to you under the Apache License,
    Version 2.0 (the "License"); you may not use this file
    except in compliance with the License.  You may obtain a
    copy of the License at the following location:

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.

-->
<xsl:stylesheet version="1.0" xmlns:dlm="http://www.uportal.org/layout/dlm" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:param name="userLayoutRoot">root</xsl:param>
    <xsl:param name="focusedTabID">none</xsl:param>
    <xsl:param name="defaultTab">1</xsl:param>
    <xsl:param name="detached">false</xsl:param>
    <xsl:param name="userImpersonating">false</xsl:param>

    <!-- Check if we have favorites or not -->
    <xsl:variable name="hasFavorites">
        <xsl:choose>
            <xsl:when test="layout/folder/folder[@type='favorites']">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Used to build the tabGroupsList:  discover tab groups, add each to the list ONLY ONCE -->
    <xsl:key name="tabGroupKey" match="layout/folder/folder[@hidden='false' and @type='regular']" use="@tabGroup"/>

    <!-- focusedFolderId is the focusedTabID param IF (1) that value points to a
         folder of type 'favorite_collection' AND (2) the user is not focusing on
         a single portlet (i.e. not in 'focused mode'); otherwise it's 'none'  :) -->
    <xsl:variable name="focusedFolderId">
        <xsl:choose>
            <xsl:when test="not(//folder/channel[@ID = $userLayoutRoot])
                            and /layout/folder/folder[@ID=$focusedTabID and @type='favorite_collection']">
                <xsl:value-of select="/layout/folder/folder[@ID=$focusedTabID and @type!='regular']/@ID"/>
            </xsl:when>
            <xsl:otherwise>none</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="activeTabIdx">
        <!-- If focusing on a favorite_collection, the activeTabInx is 1 (the favorite collection). -->
        <!-- Else if the activeTab is a number then it is the active tab index -->
        <!-- otherwise it is the ID of the active tab. If it is the ID -->
        <!-- then check to see if that tab is still in the layout and -->
        <!-- if so use its index. if not then default to an index of 1. -->
        <xsl:choose>
            <xsl:when test="$focusedFolderId!='none'">1</xsl:when>
            <xsl:when test="$focusedTabID!='none' and /layout/folder/folder[@ID=$focusedTabID and @type='regular' and @hidden='false']">
                <xsl:value-of select="count(/layout/folder/folder[@ID=$focusedTabID]/preceding-sibling::folder[@type='regular' and @hidden='false'])+1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$defaultTab" />
            </xsl:otherwise> <!-- if not found, use first tab -->
        </xsl:choose>
    </xsl:variable>

    <!-- If focused on a favorite_collection, the activeTabID is the ID of the favorite_collection.
         Otherwise it is the selected tab. -->
    <xsl:variable name="activeTabID">
        <xsl:choose>
            <xsl:when test="$focusedFolderId != 'none'">
                <xsl:value-of select="$focusedFolderId"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="/layout/folder/folder[@type='regular'and @hidden='false'][position() = $activeTabIdx]/@ID"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- Evaluate the 'activeTabGroup' (optional feature) -->
    <xsl:variable name="activeTabGroup">
        <xsl:choose>
            <xsl:when test="//folder[@ID=$activeTabID]/@tabGroup">
                <xsl:value-of select="//folder[@ID=$activeTabID]/@tabGroup"/>
            </xsl:when>
            <xsl:otherwise>DEFAULT_TABGROUP</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template name="debug-info">
        <!-- This element is not (presently) consumed by the theme transform, but it can be written to the logs easy debugging -->
        <debug>
            <userLayoutRoot><xsl:value-of select="$userLayoutRoot"></xsl:value-of></userLayoutRoot>
            <focusedTabID><xsl:value-of select="$focusedTabID"></xsl:value-of></focusedTabID>
            <focusedFolderId><xsl:value-of select="$focusedFolderId"/></focusedFolderId>
            <hasFavorites><xsl:value-of select="$hasFavorites"/></hasFavorites>
            <defaultTab><xsl:value-of select="$defaultTab"></xsl:value-of></defaultTab>
            <detached><xsl:value-of select="$detached"></xsl:value-of></detached>
            <activeTabIdx><xsl:value-of select="$activeTabIdx"></xsl:value-of></activeTabIdx>
            <activeTabID><xsl:value-of select="$activeTabID"></xsl:value-of></activeTabID>
            <activeTabGroup><xsl:value-of select="$activeTabGroup"></xsl:value-of></activeTabGroup>
            <tabsInTabGroup><xsl:value-of select="count(/layout/folder/folder[@tabGroup=$activeTabGroup and @type='regular' and @hidden='false'])"/></tabsInTabGroup>
            <userImpersonation><xsl:value-of select="$userImpersonating"/></userImpersonation>
        </debug>
    </xsl:template>

    <!-- 
     | Regions and Roles
     | =================
     | The <regions> section allows non-regular, non-sidebar portlets to appear in the
     | output page, even in focused mode.  In Universality this is done with a 'role' 
     | attribute on the portlet publication record.
     |
     | In Respondr, this is done through regions: folders with a type attribute _other than_
     | 'root', 'regular', or 'sidebar' (for legacy support).  Any folder type beyond these
     | three automatically becomes a region.  Respondr is responsible for recognizing
     | region-based portlets and placing them appropriately on the page.  Note that a region
     | name can appear multiple times in the output;  this approach allows multiple
     | fragments to place portlets in the same region.
     |
     | Regions behave normally in dashboard (normal) and focused (maximized) mode;  in
     | DETACHED window state, only a few regions are processed, and then ONLY IF THE STICKY
     | HEADER option is in effect.  The list of regions included with a sticky-header is:
     | hidden-top, page-top, page-bottom, hidden-bottom.  The remaining regions are not
     | present in the DOM and therefore their portlets MUST NOT be added to the rendering
     | queue. 
     +-->
    <xsl:template name="region">
        <region name="{@type}">
            <xsl:copy-of select="channel"/>
        </region>
    </xsl:template>

    <xsl:template name="tabList">
        <navigation>
            <!-- Signals that add-tab prompt is appropriate in the context of this navigation
                 user might or might not actually have permission to add a tab, which is evaluated later (in the theme) -->
            <xsl:attribute name="allowAddTab">true</xsl:attribute>
            <!-- The tabGroups (optional feature) -->
            <tabGroupsList>
                <xsl:attribute name="activeTabGroup">
                    <xsl:value-of select="$activeTabGroup"/>
                </xsl:attribute>
                <xsl:for-each select="/layout/folder/folder[@type='regular' and @hidden='false']"><!-- These are standard tabs -->
                    <!-- Process only the first tab in each Tab Group (avoid duplicates) -->
                    <xsl:if test="self::node()[generate-id() = generate-id(key('tabGroupKey',@tabGroup)[1])]">
                        <tabGroup name="{@tabGroup}" firstTabId="{@ID}">
                            <xsl:value-of select="@tabGroup"/>
                        </tabGroup>
                    </xsl:if>
                </xsl:for-each>
            </tabGroupsList>
            <!-- The tabs -->
            <xsl:for-each select="/layout/folder/folder[@type='regular' and @hidden='false']">
                <xsl:call-template name="tab" />
            </xsl:for-each>
        </navigation>
    </xsl:template>

    <!-- Focusing on a tab not on user's normal layout; e.g. a favorite collection -->
    <xsl:template name="tabListfocusedFolder">
        <navigation>
            <!-- signals that add-tab prompt is not appropriate in the context of this navigation -->
            <xsl:attribute name="allowAddTab">false</xsl:attribute>

            <!-- First the one focused-on tab (favorite collection) -->
            <xsl:for-each select="/layout/folder/folder[@ID = $focusedFolderId]">
                <xsl:call-template name="tab"/>
            </xsl:for-each>

            <!-- When the focused tab is a folder_collection, include the other tabs in the navigation. -->
            <xsl:for-each select="/layout/folder/folder[@type='regular' and @hidden='false']">
                <xsl:call-template name="tab" />
            </xsl:for-each>
        </navigation>
    </xsl:template>

    <!-- List of Favorites
     |   =================
     |   A list of favorited channels. 
     |   To be utilized to establish if "add to favorites" 
     |   or "remove from favorites" shows in the options menu -->
    <xsl:template name="favorites">
        <favorites>
            <xsl:for-each select="/layout/folder/folder[@type='favorites']/folder/channel">
                <favorite fname='{@fname}'/>
            </xsl:for-each>
            <xsl:for-each select="/layout/folder/folder[@type='favorite_collection']/folder/channel">
                <favorite fname='{@fname}'/>
            </xsl:for-each>
        </favorites>
    </xsl:template>

    <xsl:template match="channel">
        <xsl:choose>
            <xsl:when test="$userImpersonating = 'true' and parameter[@name='blockImpersonation']/@value = 'true'">
                <blocked-channel>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="child::*"/>
                </blocked-channel>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="parameter">
        <xsl:copy-of select="."/>
    </xsl:template>

</xsl:stylesheet>
