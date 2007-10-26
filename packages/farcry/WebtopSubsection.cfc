<!--- {{{ jEdit Modes
:mode=coldfusion:
:collapseFolds=1:
:noTabs=true:
:tabSize=4:
:indentSize=4:
}}} --->
<!--- {{{
|| LEGAL ||
$Copyright: (C) 2005 The University of Texas at Austin, http://www.utexas.edu $
$License: Released Under the "Common Public License 1.0", http://www.opensource.com/licenses/cpl.php$

|| DESCRIPTION ||
$Description: Represents a webtop configuration, can merge with other webtop roots, and translate to and from xml. $

|| DEVELOPER ||
$Developer: Tyler Ham (tylerh@austin.utexas.edu)$
}}} --->

<cfcomponent displayname="Webtop Subsection"
  hint="Represents a webtop subsection, can merge with another subsection,
  and translate to and from xml.">
  
  <!--- this is the name of the xml attribute used to order items --->
  <cfset this.orderAttrib = "sequence">
  
  <cfset this.isInitialized = "false">
  <cfset this.stAttributes = StructNew()>
  <cfset this.aMenus = ArrayNew(1)>
  
  <!--- default mergeType of a subsection is 'merge' --->
  <!--- other possible values: 'mergeNoReplace', 'replace', 'none' --->
  <!--- see WebtopRoot.cfc for more info on mergeTypes --->
  <cfset this.stAttributes.mergeType = "merge">
  
  <!--- set default order attribute --->
  <cfset this.stAttributes[this.orderAttrib] = "500000">
  
<!--- {{{ PACKAGE functions --->

<!--- {{{ package setPolicyGroup(policyGroupID, qPermissions) --->
<cffunction name="setPolicyGroup" access="package" output="no"
  hint="sets isAllowed attributes on each node if it allows access
  to the specified policy group">
  
  <cfargument name="policyGroupID" type="numeric" required="yes"
    hint="ID of the policy group to mark allowed nodes for">
  
  <cfargument name="qPermissions" type="query" required="yes"
    hint="permission map query">
  
  <cfargument name="overrideAllowed" type="boolean" required="yes"
    hint="if true, a parent node that is disallowed will cause all children
    nodes to be disallwoed, regardless of the permissions">
  
  <cfargument name="parentIsAllowed" type="boolean" required="yes"
    hint="indicates if the parent permission is allowed">
  
  <cfset var checkPermission = "">
  <cfset var i = "">
  
  <!--- first, get permissions - we'll need to pass them down the chain --->
  <cfset var permissions = arguments.qPermissions>
  
  <!--- set isAllowed for the root node --->
  <cfif StructKeyExists(this.stAttributes, "permission")>
    <!--- check that any required permission on this node is allowed by the policy group --->
    <cfquery name="checkPermission" dbtype="query">
      SELECT *
      FROM permissions
      WHERE PolicyGroupID = <cfqueryparam value="#arguments.policyGroupID#" cfsqltype="cf_sql_numeric">
        AND PermissionName = <cfqueryparam value="#this.stAttributes.permission#" cfsqltype="cf_sql_varchar">
        AND Allowed = 1
    </cfquery>
    
    <cfif checkPermission.RecordCount>
      <cfset this.stAttributes.isAllowed = "true">
    <cfelse>
      <cfset this.stAttributes.isAllowed = "false">
    </cfif>
    
  <cfelse>
    <cfset this.stAttributes.isAllowed = "true">  <!--- allow by default --->
    
  </cfif>
  
  <!--- override isAllowed if necessary --->
  <cfif this.stAttributes.isAllowed
    and arguments.overrideAllowed 
    and (not arguments.parentIsAllowed)>
    <cfset this.stAttributes.isAllowed = "false">
  </cfif>
  
  <!--- set policy group on children --->
  <cfloop index="i" from="1" to="#ArrayLen(this.aMenus)#">
    <cfset this.aMenus[i].setPolicyGroup(arguments.policyGroupID, permissions, arguments.overrideAllowed, this.stAttributes.isAllowed)>
  </cfloop>
  
</cffunction>
<!--- }}} package setPolicyGroup(policyGroupID, qPermissions) --->

<!--- {{{ package transformLabels() --->
<cffunction name="transformLabels" access="package" output="no"
  hint="transforms the label attributes (if any) of nodes
  depending on the labelType attribute (evaluate, expression, text)">
  
  <cfset var i = "">
  
  <cfset this.stAttributes.transformedLabel = "">
  
  <cfif StructKeyExists(this.stAttributes, "label")>
    <cfset this.stAttributes.transformedLabel = this.stAttributes.label>
  </cfif>
  
  <cfif StructKeyExists(this.stAttributes, "labelType")>
    <cftry>
      <cfswitch expression="#this.stAttributes.labelType#">
        <cfcase value="evaluate">
          <cfset this.stAttributes.transformedLabel = Evaluate(this.stAttributes.label)>
        </cfcase>
        
        <cfcase value="expression">
          <cfset this.stAttributes.transformedLabel = Evaluate(this.stAttributes.label)>
        </cfcase>
        
        <cfcase value="text">
          <!--- let transformedLabel just equal label (it already does) --->
        </cfcase>
        
        <cfdefaultcase>
          <!--- let transformedLabel just equal label (it already does) --->
        </cfdefaultcase>
      </cfswitch>
      
      <cfcatch>
        <cfset this.stAttributes.transformedLabel = "*** #this.stAttributes.label# ***">
      </cfcatch>
    </cftry>
  </cfif>
  
  <!--- transform labels on children --->
  <cfloop index="i" from="1" to="#ArrayLen(this.aMenus)#">
    <cfset this.aMenus[i].transformLabels()>
  </cfloop>
  
</cffunction>
<!--- }}} package transformLabels() --->

<!--- {{{ package init(SubsectionXmlElement) --->
<cffunction name="init" access="package" output="no" returnType="WebtopSubsection"
  hint="initializes this WebtopSubsection with data from the given subsection XmlElement
  from a webtop xml file.">
  
  <cfargument name="SubsectionXmlElement" required="true"
    hint="webtop subsection XmlElement">
  
  <cfset var i = "">
  <cfset var attrib = "">
  <cfset var newChild = "">
  
  <!--- if anything is bad, simply return this --->
  <!--- isInitialized is still false, so getXml will --->
  <!--- just return empty string --->
  
  <!--- make sure the argument is an xml element --->
  <cfif not isXmlElem(arguments.SubsectionXmlElement)>
    <cfreturn this>
  </cfif>
  
  <!--- make sure XmlName is 'subsection' --->
  <cfif not arguments.SubsectionXmlElement.XmlName is "subsection">
    <cfreturn this>
  </cfif>
  
  <!--- ok, everything SEEMS ok, lets get the attributes --->
  <cfloop index="attrib" list="#StructKeyList(arguments.SubsectionXmlElement.XmlAttributes)#">
    <cfset this.stAttributes[attrib] = arguments.SubsectionXmlElement.XmlAttributes[attrib]>
  </cfloop>
  
  <!--- get the xml children --->
  <cfloop index="i" from="1" to="#ArrayLen(arguments.SubsectionXmlElement.XmlChildren)#">
    <cfinvoke component="WebtopMenu" method="init" returnVariable="newChild">
      <cfinvokeargument name="MenuXmlElement" value="#arguments.SubsectionXmlElement.XmlChildren[i]#">
    </cfinvoke>
    
    <cfset insertChildWithOrder(newChild)>
  </cfloop>
  
  <!--- we are officially initialized, now getXml will work --->
  <cfset this.isInitialized = "true">
  
  <cfreturn this>
</cffunction>
<!--- }}} package init(SubsectionXmlElement) --->


<!--- {{{ package mergeSubsection(WebtopSubsection subsection2) --->
<cffunction name="mergeSubsection" access="package" output="no" returnType="void"
  hint="merges the given subsection2 onto this subsection, following any specified
  mergeType rules.  See WebtopRoot.cfc for more information about mergeType.
  Assuming subsection1 and subsection2 match (have same id).">
  
  <cfargument name="subsection2" type="WebtopSubsection" required="true"
    hint="subsection to merge into this one">
  
  <!--- comment note: subsection1 means THIS --->
  
  <!--- if mergeType='none' on subsection1, it cannot be replaced or merged --->
  <cfif this.stAttributes.mergeType is "none">
    <cfreturn>
  </cfif>
  
  <cfswitch expression="#arguments.subsection2.stAttributes.mergeType#">
    <cfcase value="replace">
      <!--- replace ALL data about subsection1 with that of subsection2 --->
      <!--- ?? should we maintain the same mergeType, though?? -TH --->
      <cfset this.stAttributes = arguments.subsection2.stAttributes>
      <cfset this.aMenus = arguments.subsection2.aMenus>
    </cfcase>
    
    <cfcase value="merge">
      <!--- append subsection2.stAttributes to subsection1.stAttributes --->
      <!--- replace if duplicate keys --->
      <!--- normal merge/replace operation on children --->
      <cfset StructAppend(this.stAttributes, arguments.subsection2.stAttributes, "yes")>
      <cfset mergeChildren(arguments.subsection2)>
    </cfcase>
    
    <cfcase value="mergeNoReplace">
      <!--- append subsection2.stAttributes to subsection1.stAttributes --->
      <!--- do not replace duplicate keys --->
      <!--- normal merge/replace operation on children --->
      <cfset StructAppend(this.stAttributes, arguments.subsection2.stAttributes, "no")>
      <cfset mergeChildren(arguments.subsection2)>
    </cfcase>
    
    <cfdefaultcase> <!--- this will catch "none" values --->
      <!--- what should we do with strange mergeTypes? or "none"s? --->
      <!--- (remember, subsection1.id = subsection2.id - we assume this in here) --->
      <!--- How about "merge" as default for subsections? -TH --->
      <cfset StructAppend(this.stAttributes, arguments.subsection2.stAttributes, "yes")>
      <cfset mergeChildren(arguments.subsection2)>
    </cfdefaultcase>
  </cfswitch>
  
</cffunction>
<!--- }}} package mergeSubsection(WebtopSubsection subsection2) --->


<!--- {{{ package getXml() --->
<cffunction name="getXml" access="package" output="no" returnType="string"
  hint="returns xml of this webtop element as a string">
  
  <cfset var sOutput = "">
  <cfset var i = "">
  
  <!--- if we were not initialized with a proper SubsectionXmlElement, --->
  <!--- just return empty string--->
  <!--- this ought to do the least amount of harm --->
  <cfif not this.isInitialized>
    <cfreturn sOutput>
  </cfif>
  
  <!--- this call takes the struct and returns a string that looks like --->
  <!--- 'key="value" key="value" ...' --->
  <cfinvoke component="WebtopRoot" method="toAttributeString" returnVariable="sOutput" stAttributes="#this.stAttributes#">
  <cfset sOutput = "<subsection " & sOutput & " >">
  
  <!--- add the children --->
  <cfloop index="i" from="1" to="#ArrayLen(this.aMenus)#">
    <cfset sOutput = sOutput & " " & this.aMenus[i].getXml()>
  </cfloop>
  
  <!--- add the close tag --->
  <cfset sOutput = sOutput & " </subsection>">
  
  <cfreturn sOutput>
</cffunction>
<!--- }}} package getXml() --->


<!--- }}} PACKAGE functions --->


<!--- {{{ PRIVATE functions --->

<!--- {{{ private mergeChildren(WebtopSubsection subsection2) --->
<cffunction name="mergeChildren" access="private" output="no" returnType="void"
  hint="merges the children of subsection2 into the children of this subsection,
  following any specified mergeType rules.  See WebtopRoot.cfc for more information
  about mergeType.">
  
  <cfargument name="subsection2" type="WebtopSubsection" required="true"
    hint="subsection whose children to merge with this one">
  
  <cfset var i = "">
  
  <!--- comment note: subsection1 means THIS --->
  
  <!--- loop through and merge each child (passing the buck again!) --->
  <cfloop index="i" from="1" to="#ArrayLen(arguments.subsection2.aMenus)#">
    <cfset mergeChild(arguments.subsection2.aMenus[i])>
  </cfloop>
  
</cffunction>
<!--- }}} private mergeChildren(WebtopSubsection subsection2) --->


<!--- {{{ private mergeChild(WebtopMenu child) --->
<cffunction name="mergeChild" access="private" output="no" returnType="void"
  hint="merges the child into aMenus">
  
  <cfargument name="child" type="WebtopMenu" required="true"
    hint="menu to merge into this subsections's children">
  
  <cfset var i = "">
  <cfset var matchFound = "false">
  
  <!--- we must have an id to match, otherwise, no point in looking --->
  <cfif StructKeyExists(arguments.child.stAttributes, "id")>
    <!--- does the same child exist in this menu? --->
    <!--- ID will match, if so --->
    <cfloop index="i" from="1" to="#ArrayLen(this.aMenus)#">
      <!--- id attribute must be present and must match --->
      <cfif StructKeyExists(this.aMenus[i].stAttributes, "id")
        and this.aMenus[i].stAttributes.id is arguments.child.stAttributes.id>
        
        <!--- set matchFound=true so we don't append the child later --->
        <cfset matchFound = "true">
        
        <!--- they match, so merge them --->
        <cfset this.aMenus[i].mergeMenu(arguments.child)>
        
        <!--- no need to keep looping --->
        <cfbreak>
      </cfif>
    </cfloop>
    
  </cfif>
  
  <cfif not matchFound>
    <!--- a match was not found, so we should append the menuitem --->
    
    <cfset insertChildWithOrder(arguments.child)>
  </cfif>
  
</cffunction>
<!--- }}} private mergeChild(WebtopMenu child) --->


<!--- {{{ private insertChildWithOrder(WebtopMenu child) --->
<cffunction name="insertChildWithOrder" access="private" output="no" returnType="void"
  hint="inserts the child into aMenus with order">
  
  <cfargument name="child" type="WebtopMenu" required="true"
    hint="menu to insert into this subsections's children">
  
  <cfset var i = 0>
  <cfset var inserted = "false">
  
  <cfloop index="i" from="1" to="#ArrayLen(this.aMenus)#">
    <cfif arguments.child.stAttributes[this.orderAttrib] lt this.aMenus[i].stAttributes[this.orderAttrib]>
      <cfset ArrayInsertAt(this.aMenus, i, arguments.child)>
      <cfset inserted = "true">
      <cfbreak>
    </cfif>
  </cfloop>
  
  <cfif not inserted>
    <cfset ArrayAppend(this.aMenus, arguments.child)>
    <cfset inserted = "true">
  </cfif>
</cffunction>
<!--- }}} private insertChildWithOrder(WebtopMenu child) --->


<!--- }}} PRIVATE functions --->


</cfcomponent>
