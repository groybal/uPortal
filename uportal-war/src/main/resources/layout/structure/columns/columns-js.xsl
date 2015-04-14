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

    <!-- Import standard templates for column output -->
    <xsl:import href="columns-imports.xsl" />

    <!-- ROOT template.  Default to NORMAL window state (since DETACHED window state does not apply). -->
    <xsl:template match="layout">
        <xsl:apply-templates select="folder[@type='root']" mode="NORMAL" />
    </xsl:template>

    <!-- NORMAL page template.  Governs the overall structure when the page is 
         non-detached. -->
    <xsl:template match="folder[@type='root']" mode="NORMAL">
        <layout>
            <xsl:call-template name="debug-info"/>

            <xsl:if test="/layout/@dlm:fragmentName">
                <xsl:attribute name="dlm:fragmentName"><xsl:value-of select="/layout/@dlm:fragmentName"/></xsl:attribute>
            </xsl:if>

            <regions>
                <xsl:call-template name="regions" />
            </regions>

            <xsl:choose>
                <xsl:when test="$focusedFolderId != 'none'"><xsl:call-template name="tabListfocusedFolder"/></xsl:when>
                <xsl:otherwise><xsl:call-template name="tabList"/></xsl:otherwise>
            </xsl:choose>

            <xsl:call-template name="favorites" />

            <xsl:call-template name="favorite-groups" />
        </layout>
    </xsl:template>

    <xsl:template name="regions">
                <xsl:choose>
                    <xsl:when test="$userLayoutRoot = 'root'">
                        <!-- Include all regions when in DASHBOARD mode -->
                        <xsl:for-each select="child::folder[@type!='regular' and @type!='sidebar' and @type!='customize' and channel]"><!-- Ignores empty folders -->
                            <xsl:call-template name="region"/>
                        </xsl:for-each>
                        <!--  Combine 'customize' regions -->
                        <xsl:if test="child::folder[@type='customize' and channel]">
                            <region name="customize">
                                <xsl:for-each select="child::folder[@type='customize' and channel]">
                                    <xsl:copy-of select="channel"/>
                                </xsl:for-each>
                            </region>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Include all regions EXCEPT 'region-customize' when in FOCUSED mode -->
                        <xsl:for-each select="child::folder[@type!='customize' and @type!='regular' and @type!='sidebar' and channel]"><!-- Ignores empty folders -->
                            <xsl:call-template name="region"/>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
    </xsl:template>

    <xsl:template match="folder[@type!='root' and @hidden='false']">
        <xsl:attribute name="type">regular</xsl:attribute>
        <xsl:if test="child::folder">
            <xsl:for-each select="folder">
                <xsl:call-template name="column" />
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="child::channel">
            <xsl:call-template name="column" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="@*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="column">
                <column>
                    <xsl:copy-of select="@*" />
                    <xsl:apply-templates/>
                </column>
    </xsl:template>

    <xsl:template name="tab">
        <tab>
            <!-- Copy folder attributes verbatim -->
            <xsl:for-each select="attribute::*">
                <xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
            </xsl:for-each>
            <xsl:if test="@ID = $focusedFolderId">
                <xsl:attribute name="focusedFolder">true</xsl:attribute>
            </xsl:if>
            <xsl:if test="count(./folder[not(@dlm:addChildAllowed='false')]) >0">
                <xsl:attribute name="dlm:hasColumnAddChildAllowed">true</xsl:attribute>
            </xsl:if>

            <!-- Add 'activeTab' and 'activeTabPosition' attributes as appropriate -->
            <xsl:choose>
                <xsl:when test="$activeTabID = @ID">
                    <xsl:attribute name="activeTab">true</xsl:attribute>
                    <!-- JNW Changed from activeTabID to activeTabIdx as that seems right. However not referenced in OOTB theme so academic.
                         Mark as deprecated and eligible for cleanup in future release 2/10/15 -->
                    <xsl:attribute name="activeTabPosition"><xsl:value-of select="$activeTabIdx"/></xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="activeTab">false</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>

            <content>
                <xsl:attribute name="hasFavorites"><xsl:value-of select="$hasFavorites" /></xsl:attribute>
                <xsl:choose>
                    <xsl:when test="$focusedFolderId != 'none'">
                        <xsl:apply-templates select="folder[@ID=$focusedFolderId]"/>
                    </xsl:when>
                    <xsl:when test="$userLayoutRoot = 'root'">
                        <xsl:apply-templates select="folder[@type='regular']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <focused>
                            <!-- Detect whether a focused channel is present in the user's layout -->
                            <xsl:attribute name="in-user-layout">
                                <xsl:choose>
                                    <xsl:when test="//folder[@type='regular' and @hidden='false']/channel[@ID = $userLayoutRoot]">yes</xsl:when>
                                    <xsl:otherwise>no</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:apply-templates select="//*[@ID = $userLayoutRoot]"/>
                        </focused>
                    </xsl:otherwise>
                </xsl:choose>
            </content>
        </tab>
    </xsl:template>

    <xsl:template name="favorites">
        <favorites>
            <xsl:for-each select="/layout/folder/folder[@type='favorites']/folder/channel">
                <favorite>
                    <xsl:apply-templates select="." />
                </favorite>
            </xsl:for-each>
        </favorites>
    </xsl:template>

    <xsl:template name="favorite-groups">
        <favoriteGroups>
            <xsl:for-each select="/layout/folder/folder[@type='favorite_collection']">
                <favoriteGroup>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates select="folder" />
                </favoriteGroup>
            </xsl:for-each>
        </favoriteGroups>
    </xsl:template>

    <xsl:template match="/layout/folder/folder[@type='favorite_collections']/folder">
        <xsl:call-template name="column" />
    </xsl:template>

</xsl:stylesheet>
