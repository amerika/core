<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/messageCentre.cfm,v 1.10 2005/09/02 06:27:37 guy Exp $
$Author: guy $
$Date: 2005/09/02 06:27:37 $
$Name: milestone_3-0-1 $
$Revision: 1.10 $

|| DESCRIPTION || 
$Description: Message Centre $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfsetting enablecfoutputonly="No">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfset iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab")>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iGeneralTab eq 1>

	<cfimport taglib="/farcry/core/tags/display/" prefix="display">
	
	<cfparam name="stargs.typename" default="dmEmail">
	
	<cffunction name="getAllObjects">
		<cfquery name="q" datasource="#application.dsn#">
			SELECT * FROM #stArgs.typename#
		</cfquery>
		<cfreturn q>
	</cffunction>

	
	<cfoutput>
	
	<script>
	function editObject(objectID)
	{
		document.dynamicAdmin.objectid = objectID;
	}	
	
	function confirmDelete(objectID){
		var msg = "#application.adminBundle[session.dmProfile.locale].confirmDeleteItem#";
		if (confirm(msg))
		{	
			return true;
		}	
		else
			return false;
	}				
	function confirmApprove(action){
		var msg = "#application.adminBundle[session.dmProfile.locale].confirmObjStatusChange#" + action;
		if (confirm(msg))
			return true;
		else
			return false;
	}				
	
	</script>
	
	</cfoutput>
	
	
	<cfif isDefined("form.add")>
		<cfscript>
			o = createObject("component", application.types[stArgs.typename].typePath);
			objectID = o.create();
			o.edit(objectid=objectid);
		</cfscript>
	
	</cfif>
	
	<cfif isDefined("form.edit")>
		<cfscript>
			o = createObject("component", application.types[stArgs.typename].typePath);
			o.edit(objectid=form.objectid);
		</cfscript>
	</cfif>
	
	<cfif isDefined("form.delete")>
		<cfscript>
			o = createObject("component", application.types[stArgs.typename].typePath);
			o.delete(objectid=form.objectid);
		</cfscript>
	</cfif>
	
	
	<!--- change status of objects --->
	<cfif isDefined("form.status")>
		<cfif isDefined("form.objectID")>
			<cfscript>
				if (form.status contains "Approve")
					status = 'approved';
				else if (form.status contains "Send to Draft")
					status = 'draft'; 	
				else if (form.status contains 'Request')
					status = 'requestApproval';
				else
					status = 'unknown';
			</cfscript>
			<!--- custom tag to add user comments --->
			<cflocation url="#application.url.farcry#/navajo/objectComment.cfm?status=#status#&objectID=#form.objectID#" addtoken="no">
					
		<cfelse>
			<cfset msg = "#application.adminBundle[session.dmProfile.locale].noObjSelected#">			
		</cfif>
	</cfif>
	
	
	<cfparam name="FORM.currentStatus" default="All"> 
	<cfparam name="url.order" default="datetimecreated">
	<cfparam name="url.direction" default="desc">
	
	
	<cfparam name="url.pgno" default="1">
	<cfif isdefined("url.status")>
		<cfset form.currentStatus = url.status>
	</cfif>
	
	<!--- get objects to display --->
	<cfinvoke component="#application.types.dmEmail.typePath#" method="getAllObjects" returnvariable="recordSet">
	
	<cfparam name="FORM.thisPage" default="1">
	<cfscript>
		numRecords = application.config.general.genericAdminNumItems;
		thisPage = FORM.thisPage;
		if (recordSet.recordCount GT 0)
		{
			startRow = ((thisPage*numRecords) + 1) - numRecords; //the query row which we start from
			numPages = recordSet.recordcount/numRecords;
			numPages = ceiling(numPages); // the number of 'pages' of results
			if (thisPage GT 1){
				prevPage = thisPage - 1; 
			}	//the next page to advance to  
			if (thisPage LT numPages){
				nextPage = thisPage + 1;
			}	 // the previous page to go back to	
		}else
		{	numpages = 1;
			thispage = 1;
		}
	</cfscript>
	
	<cfset comment = false>
	
	<cfoutput>
	<cfif isDefined("msg")>
	<div class="FormTableClear" style="margin-left:0;">
		<strong>#msg#</strong>
	</div>
	</cfif>
	

			<h3>#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].items,"#recordSet.recordcount#")#</h3>
					
					<form action="" method="post" name="dynamicAdmin">
						<cfif thisPage GT 1>
							<input type="image" src="#application.url.farcry#/images/treeImages/leftarrownormal.gif" value="#application.adminBundle[session.dmProfile.locale].prev#" name="prev"  onclick="this.form.thisPage.selectedIndex--;this.form.submit();" >
						</cfif>
						Page 
						<select name="thisPage" onChange="this.form.submit();">
							<cfloop from="1" to="#numPages#" index="i">
								<option value="#i#" <cfif i eq thisPage>selected</cfif>>#i#
							</cfloop>
						</select> #application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].pageOfPages,"#numPages#")# 
						<cfif thisPage LT numpages>
							<input name="next" type="image" src="#application.url.farcry#/images/treeImages/rightarrownormal.gif" value="#application.adminBundle[session.dmProfile.locale].next#" onclick="this.form.thisPage.selectedIndex++;this.form.submit();">
						</cfif>
						<cfif isDefined("form.fieldnames")>
						<cfloop list="#form.fieldnames#" index="element">
							<cfif NOT element IS "thisPage">
							<input type="Hidden" name="#element#" value="#evaluate('form.'&element)#">
							</cfif>
						</cfloop>
						</cfif>
						</form>
					
			<hr />

				<table class="table-2" cellspacing="0">
				<tr>
					<th>#application.adminBundle[session.dmProfile.locale].subject# </th>
					<th>#application.adminBundle[session.dmProfile.locale].edit# </th>
					<th>#application.adminBundle[session.dmProfile.locale].preview# </th>
					<th>#application.adminBundle[session.dmProfile.locale].send# </th>
					<th>#application.adminBundle[session.dmProfile.locale].delete# </th>
				</tr>
	         </cfoutput>
			<cfif recordSet.recordCount EQ 0 >
				<cfoutput>
				<tr>
					<td colspan="8">
						<strong>#application.adminBundle[session.dmProfile.locale].noRecsRecovered#</strong>
					</td>	
				</tr>
				</cfoutput>
			<cfelse>
				<cfoutput query="recordSet" startrow="#startRow#" maxrows="#numRecords#"> 
				<cfscript>
					finishURL = URLEncodedFormat("#cgi.SCRIPT_NAME#?#CGI.QUERY_STRING#");
					editObjectURL = "#application.url.farcry#/navajo/edit.cfm?objectid=#objectID#&finishUrl=#finishURL#&type=#stArgs.typename#";
					previewURL = "#application.url.webroot#/index.cfm?objectID=#objectID#&flushcache=1";
				</cfscript>
				  <tr class="#IIF(currentrow MOD 2, de("dataOddRow"), de("dataEvenRow"))#"> 
				  <form action="" method="post" name="form_#recordset.objectid#">
					<td><strong>#title#</strong></td>
					<td>
						
						<input type="hidden" name="objectid" value="#recordset.objectid#">
						<input class="f-submit" type="button" name="edit" value="#application.adminBundle[session.dmProfile.locale].Edit#" onClick="location.href='#editObjectURL#';" />
					</td>
					<td>
						<input class="f-submit" type="button" name="preview" value="#application.adminBundle[session.dmProfile.locale].preview#" onClick="window.open('#previewURL#');" />
					</td>
					<td>
						<cfif bSent>
							#application.adminBundle[session.dmProfile.locale].sent#
						<cfelse>
							<input class="f-submit" type="button" name="send" value="#application.adminBundle[session.dmProfile.locale].send#" onClick="location.href='#application.url.farcry#/admin/messageSend.cfm?objectid=#objectid#';" />	
						</cfif>						
					</td>
					<td>
						<input class="f-submit" type="submit" name="delete" value="#application.adminBundle[session.dmProfile.locale].delete#" onClick="return confirmDelete('#recordset.objectid#')" />
						
					</td>
					</form>
				  </tr>
				</cfoutput>
			</cfif>
			<cfoutput> </table>

	
	<hr />
				
					<!--- get permissions  --->
						<form action="" method="post">
						<cfset finishURL = URLEncodedFormat("#cgi.SCRIPT_NAME#?#CGI.QUERY_STRING#")><!--- navajo/createObject.cfm?typename=#stArgs.typename#&finishURL=#finishURL#' ---><!--- window.location='#application.url.farcry#/#application.url.conjurer#?typename=#stArgs.typename#&finishURL=#finishURL#'; --->
						<input type="button" value="#application.adminBundle[session.dmProfile.locale].add#" name="add" class="f-submit" onclick="window.location='#application.url.farcry#/conjuror/evocation.cfm?typename=#stArgs.typename#&finishURL=#finishURL#';" />
						</form>					
					
				</form>		
			
	</cfoutput>	

<cfelse>
	<admin:permissionError>
</cfif>

<!--- setup footer --->
<admin:footer>

<cfsetting enablecfoutputonly="no">