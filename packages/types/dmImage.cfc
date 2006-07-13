<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/dmImage.cfc,v 1.23.2.6 2006/02/14 06:48:47 paul Exp $
$Author: paul $
$Date: 2006/02/14 06:48:47 $
$Name:  $
$Revision: 1.23.2.6 $

|| DESCRIPTION || 
$Description: dmImage type $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="types" displayname="Image" hint="Image objects" bUseInTree="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="nstring" hint="Image title." required="no" default=""> 
<cfproperty name="alt" type="nstring" hint="Alternate text" required="no" default="" > 
<cfproperty name="width" type="nstring" hint="Image width (blank for default)" required="no" default="">  
<cfproperty name="height" type="nstring" hint="Image height (blank for default)" required="no" default="">  
<cfproperty name="imagefile" type="string" hint="The image file to be uploaded" required="No" default="">
<cfproperty name="thumbnail" type="string" hint="The name of the thumbnail image to be uploaded" required="no" default="">  
<cfproperty name="optimisedImage" type="string" hint="The name of the optimised image to be uploaded" required="no" default="">  
<cfproperty name="originalImagePath" type="string" hint="The location in the filesystem where the original image is stored." required="No" default=""> 
<cfproperty name="thumbnailImagePath" editHandler="void" type="string" hint="The location in the filesystem where the thumbnail image is stored." required="no" default=""> 
<cfproperty name="optimisedImagePath" editHandler="void" type="string" hint="The location in the filesystem where the optimized image is stored." required="no" default=""> 
<cfproperty name="bLibrary" type="numeric" hint="Flag to indictae if in file library or not" required="no" default="1" ftType="boolean">
<cfproperty name="bAutoGenerateThumbnail" type="numeric" hint="Flag to indicate if to automatically generate a thumbnail form the default image" required="no" default="1" ftType="boolean">
<cfproperty name="status" type="string" hint="Status of the node (draft, pending, approved)." required="yes" default="draft">

<!--- URL locations to images (includes filename) --->
<cfproperty name="SourceImage" type="string" hint="The URL location of the uploaded image" required="No" default="" 
	ftType="Image">
<cfproperty name="StandardImage" type="string" hint="The URL location of the optimised uploaded image that should be used for general display" required="no" default="" 
	ftType="Image"> 
<cfproperty name="ThumbnailImage" type="string" hint="The URL location of the thumnail of the uploaded image that should be used in " required="no" default="" 
	ftType="Image">  
<!--- Object Methods --->


<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >

<cffunction name="ftEdit" access="public" output="true" returntype="void">
	<cfargument name="ObjectID" required="no" type="string" default="">
	
	<ft:object typename="#getTablename()#" objectID="#arguments.ObjectID#" lFields="ImageFile" inTable=0 />
	<cfoutput>
	<a href="##" onclick="Effect.toggle('edsubpanel','slide');">Advanced options</a>
	<div id="edsubpanel" style="display:none;">
	<div>		
		<ft:object typename="#getTablename()#" objectID="#arguments.ObjectID#" lFields="Title,Alt,width,height,bLibrary,status" inTable=0 />
	</div>
	</div>
	</cfoutput>
</cffunction>


<cffunction name="AddNew" access="public" output="true" returntype="void">
	<cfargument name="typename" required="true" type="string">
	<cfargument name="lFields" required="false" type="string" default="">
	
	<ft:object typename="#arguments.typename#" lfields="Title,SourceImage" inTable=0 />

</cffunction>


<cffunction name="BeforeSave" access="public" output="true" returntype="struct">
	<cfargument name="stProperties" required="yes" type="struct">
	<cfargument name="stFields" required="yes" type="struct">
		
	<cfparam name="arguments.stFields.ThumbnailImage.metadata.ftDestination" default="#application.config.image.ThumbnailImageURL#">
	<cfparam name="arguments.stFields.ThumbnailImage.metadata.ftImageWidth" default="#application.config.image.ThumbnailImageWidth#">
	<cfparam name="arguments.stFields.ThumbnailImage.metadata.ftImageHeight" default="#application.config.image.ThumbnailImageHeight#">
	
	<cfparam name="arguments.stFields.StandardImage.metadata.ftDestination" default="#application.config.image.StandardImageURL#">
	<cfparam name="arguments.stFields.StandardImage.metadata.ftImageWidth" default="#application.config.image.StandardImageWidth#">
	<cfparam name="arguments.stFields.StandardImage.metadata.ftImageHeight" default="#application.config.image.StandardImageHeight#">
	
	
	<cfset stObject = getData(objectid=stproperties.objectid) />
	
	<cfif structKeyExists(arguments.stProperties, "SourceImage") AND len(arguments.stProperties.SourceImage) AND (NOT isDefined("arguments.stProperties.ThumbnailImage") OR NOT len(arguments.stProperties.ThumbnailImage))>
		<cfif stObject.SourceImage NEQ arguments.stProperties.SourceImage>

			<!--- Image has changed --->
			<cfif NOT DirectoryExists("#application.path.project#/www#arguments.stFields.ThumbnailImage.metadata.ftDestination#")>
				<cfdirectory action="create" directory="#application.path.project#/www#arguments.stFields.ThumbnailImage.metadata.ftDestination#">
			</cfif>
			
						
			<cffile action="copy" 
				source="#application.path.project#/www#arguments.stProperties.SourceImage#"
				destination="#application.path.project#/www#arguments.stFields.ThumbnailImage.metadata.ftDestination#">
			
			
			<cfx_image action="resize"
				file="#application.path.project#/www#arguments.stFields.ThumbnailImage.metadata.ftDestination#/#File.ServerFile#"
				output="#application.path.project#/www#arguments.stFields.ThumbnailImage.metadata.ftDestination#/#File.ServerFile#"
				X="#arguments.stFields.ThumbnailImage.metadata.ftImageWidth#"
				Y="#arguments.stFields.ThumbnailImage.metadata.ftImageHeight#"
				ThumbnailImage=yes
				bevel=no
				backcolor=white>
				
			<cfset stproperties.ThumbnailImage = "#arguments.stFields.ThumbnailImage.metadata.ftDestination#/#File.ServerFile#">
			<!--- <cfset stproperties.ThumbnailImageImagePath = "#application.path.project#/www#arguments.stFields.ThumbnailImage.metadata.ftDestination#"> --->
		</cfif>
	</cfif>
		
		
	<cfif structKeyExists(arguments.stProperties, "SourceImage") AND  len(arguments.stProperties.SourceImage) AND (NOT isDefined("arguments.stProperties.StandardImage") OR NOT len(arguments.stProperties.StandardImage))>
		<cfif stObject.SourceImage NEQ arguments.stProperties.SourceImage>
			<cfif NOT DirectoryExists("#application.path.project#/www#arguments.stFields.StandardImage.metadata.ftDestination#")>
				<cfdirectory action="create" directory="#application.path.project#/www#arguments.stFields.StandardImage.metadata.ftDestination#">
			</cfif>
				
			<cffile action="copy" 
				source="#application.path.project#/www#arguments.stProperties.SourceImage#"
				destination="#application.path.project#/www#arguments.stFields.StandardImage.metadata.ftDestination#">
				
				
			<cfx_image action="read"
				file="#application.path.project#/www#arguments.stFields.StandardImage.metadata.ftDestination#/#File.ServerFile#">
				
			<cfif IMG_WIDTH GT arguments.stFields.StandardImage.metadata.ftImageWidth>
				<cfx_image action="resize"
						file="#application.path.project#/www#arguments.stFields.StandardImage.metadata.ftDestination#/#File.ServerFile#"
						output="#application.path.project#/www#arguments.stFields.StandardImage.metadata.ftDestination#/#File.ServerFile#"
						X="#arguments.stFields.StandardImage.metadata.ftImageWidth#">
			</cfif>
				
		
			<cfx_image action="read"
				file="#application.path.project#/www#arguments.stFields.StandardImage.metadata.ftDestination#/#File.ServerFile#">
				
			<cfif IMG_HEIGHT GT arguments.stFields.StandardImage.metadata.ftImageHeight>
				<cfx_image action="resize"
						file="#application.path.project#/www#arguments.stFields.StandardImage.metadata.ftDestination#/#File.ServerFile#"
						output="#application.path.project#/www#arguments.stFields.StandardImage.metadata.ftDestination#/#File.ServerFile#"
						Y="#arguments.stFields.StandardImage.metadata.ftImageHeight#">
			</cfif>
	
			<cfset stproperties.StandardImage = "#arguments.stFields.StandardImage.metadata.ftDestination#/#File.ServerFile#">
		</cfif>
	</cfif>
	
	<cfreturn stProperties>
</cffunction>

<cffunction name="ftDisplayThumbnail" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
	<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
	<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
	<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
	<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

	<cfparam name="arguments.stMetadata.ftDestination" default="/images">

	<cfset Request.inHead.Lightbox = 1>
	<cfsavecontent variable="html">
		<cfoutput>
		<cfif structKeyExists(stobject, "OptimisedImage") AND len(stObject.OptimisedImage)>
			<a href="#stObject.OptimisedImage#" rel="lightbox[Collections]">
				<img src="#arguments.stMetadata.value#">
			</a><br />			
			&nbsp;&nbsp;&nbsp;&nbsp;    
			
			 
			
		<cfelse>
			<img src="#arguments.stMetadata.value#">
		</cfif>
		</cfoutput>	

	</cfsavecontent>
	
	<cfreturn html>
</cffunction>
	


<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	
	<cfinclude template="_dmImage/edit.cfm">
</cffunction>

<cffunction name="display" access="public" output="true">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfinclude template="_dmImage/display.cfm">
</cffunction>

<cffunction name="delete" access="public" hint="Specific delete method for dmImage. Removes physical files from ther server." returntype="struct">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	
	<cfset var stLocal = StructNew()>
	<!--- get object details --->
	<cfset var stObj = getData(arguments.objectid)>
	<cfset var stReturn = StructNew()>
	<cfset var relatedTable = "">

	<cfset stReturn.bSuccess = true>
	<cfset stReturn.message = "">
		
	<cfset stLocal.errormessage = "">
	<!--- check if image is associated with any content items --->
	<cfset stLocal.lrelatedContentTypes = "dmNews,dmNavigation,dmHTML,dmEvent">

	<cfloop index="stLocal.relatedContentType" list="#stLocal.lrelatedContentTypes#">
		
		<cfif stLocal.relatedContentType IS "dmNews">
			<cfset relatedTable = "#application.dbowner##stLocal.relatedContentType#_aObjectIds">
		<cfelse>	
			<cfset relatedTable = "#application.dbowner##stLocal.relatedContentType#_aObjectIDs">
		</cfif>
		
		<cfquery name="stLocal.qCheck" datasource="#application.dsn#">
		SELECT	objectid
		FROM	#relatedTable#
		WHERE	data = '#arguments.objectid#'
		</cfquery>

		<cfif stLocal.qCheck.recordcount GTE 1>
			<cfset stReturn.bSuccess = false>
			<cfset stReturn.message = stReturn.message & "Sorry image [#stObj.label#] cannot be delete because it is associated to <strong>#stLocal.qCheck.recordcount# #stLocal.relatedContentType#</strong> item(s).<br />">
		</cfif>
	</cfloop>

	<cfif stReturn.bSuccess EQ true>
		<cfinclude template="_dmImage/delete.cfm">
	</cfif>
	<cfreturn stReturn>
</cffunction>

<cffunction name="checkForExisting" access="public" output="No" returntype="struct" hint="Checks to see if an existing image object already uses that name">
	<cfargument name="filename" required="yes" type="string" hint="Filename of the new image being uploaded">
	<cfargument name="dsn" required="no" type="string" default="#application.dsn#">
	<cfargument name="dbowner" required="no" type="string" default="#application.dbowner#">
	
	<cfset var stCheck = structNew()>
	<cfset var newFileName = "">
	<cfset var qCheck = "">
	
	<!--- prepare filename --->
	<cfset newFileName = listLast(replace(arguments.filename,"\","/","all"),"/")>
	
	<!--- check if existing objects use the same filename --->
	<cfquery name="qCheck" datasource="#arguments.dsn#">
		select objectid
		from #arguments.dbowner#dmImage
		where imagefile = '#newFileName#' or 
			thumbnail = '#newFileName#' or 
			optimisedImage = '#newFileName#'
	</cfquery>
	
	<!--- if query returned an object it means another object is using the same image name --->
	<cfif qCheck.recordcount>
		<cfset stCheck.bExists = 1>
		<cfset stCheck.fileName = newFileName>
	<cfelse>
		<cfset stCheck.bExists = 0>
	</cfif>
	
	<cfreturn stCheck>
</cffunction>

<cffunction name="getURLImagePath" returntype="string" hint="returns the image path for either thumb, optimised or original - depending on what is passed in" access="public">
	<cfargument name="objectid" type="string" hint="Image Object id">
	<cfargument name="imageType" type="string" hint="thumb, optimised or original">
	
	<cfset var stObject = structnew()>
	<cfset stObject = getData(arguments.objectid)>

	<cfif not structIsEmpty(stObject)>
		<cfswitch expression="#lcase(imageType)#">
			<cfcase value="thumb">
				<cfreturn rendorURLImagePath(stObject.thumbnailImagePath, stObject.thumbnail)>
			</cfcase>
			<cfcase value="optimised">
				<cfreturn rendorURLImagePath(stObject.optimisedImagePath, stObject.optimisedImage)>
			</cfcase>
			<cfcase value="original">
				<cfreturn rendorURLImagePath(stObject.originalImagePath, stObject.imagefile)>
			</cfcase>
			<cfdefaultcase>
				<cfthrow message="You must pass either thumb, optimised or original for the imageType argument">
			</cfdefaultcase>
		</cfswitch>
	<cfelse>
		<cfthrow message="The image stObject must be a valid structure with values">
	</cfif>
</cffunction>

<cffunction name="rendorURLImagePath" returntype="string" access="private" hint="returns the thumb image path" output="false">
	<cfargument name="filePath" type="string" hint="file path of thumbnail" required="true">
	<cfargument name="fileName" type="string" hint="file name of thumbnail" required="true">
	
	<cfif Len(application.url.webroot) AND application.url.webroot NEQ "/" >
		<cfset imagePath= application.url.webroot >
	<cfelse>
		<cfset imagePath= "" >
	</cfif>

	<cfif len(filePath) and len(fileName)>
		<!--- change all backslashes to forward slashes --->
		<cfset filePath = replace(filePath, "\", "/", "all")>
		<cfset imagePos = listfindNoCase(filePath, "images", "/")>
		<!--- create a new imagepath string by looping over filePath as a list and getting all elements after and including "images" --->
		<cftry>
		<cfloop from="#imagePos#" to ="#listlen(filePath, '/')#" index="i">
			<cfset listElement = listgetAt(filePath, i, "/")>
			<cfset imagePath = "#imagePath#/#listElement#">
		</cfloop>
		<!--- add the file name onto the filepath --->
		<cfset imagePath="#imagePath#/#arguments.filename#">
		
		<cfcatch type="any">
			<cftrace type="error" text="Unable to determine imagepath. filepath: #arguments.filepath# filename: #arguments.filename#" category="dmimage">
		</cfcatch>
		</cftry>
	<cfelse>
		<cftrace category="dmImage" type="warning" text="The filePath or fileName passed to function rendorURLImagePath in dmImage.cfc is empty which will cause the image not to display">
	</cfif>
	<cfreturn imagePath>
</cffunction>

<!--- TODO: Is this needed anymore? The argument doesn't even match the super's arg. TL 20060214 --->
<cffunction name="setFriendlyURL" access="public" returntype="struct" hint="Files do not have FUs; method always returns false." output="false">
	<cfargument name="stProperties" required="true" type="struct">
	<cfset var stReturn = StructNew()>
	<cfset stReturn.bSuccess = 0>
	<cfset stReturn.message = "File content type cannot have friendly url.">
	<cfreturn stReturn>
</cffunction>


</cfcomponent>
	