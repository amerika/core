<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit Profile --->
<!--- @@description: Form for users editing their own profile --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/extjs/" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- You can not edit other users' profiles --->	
<cfif NOT application.security.getCurrentUserID() eq stObj.username>
	<cfthrow message="Invalid Profile Change" detail="You can not edit other users' profiles." />
</cfif>


<!----------------------------- 
ACTION	
------------------------------>
<ft:processform action="Save">
	<ft:processformobjects objectid="#stobj.objectid#">
		<cfset structappend(session.dmProfile,stProperties,true) />

		<extjs:bubble title="Saved" bAutoHide="true">
			<cfoutput>Your profile has been saved</cfoutput>
		</extjs:bubble>
		
		<cfset session.firstLogin = false />
	</ft:processformobjects>
</ft:processform>


<!----------------------------- 
VIEW	
------------------------------>
<cfif session.firstLogin>
	<extjs:bubble title="First login" bAutoHide="false">
		<cfoutput>This is the first time you've logged into the webtop. Please complete your profile form with your details.</cfoutput>
	</extjs:bubble>
</cfif>

<ft:form heading="#application.rb.getResource('coapi.dmProfile.general.editprofile@label','Edit your profile')#">
	<skin:view stobject="#stObj#" webskin="editProfile" />
	
	<ft:farcryButtonPanel>
		<ft:button value="Save" text="Update Profile" color="orange" />
		<ft:button value="Cancel" />
	</ft:farcryButtonPanel>
</ft:form>

<cfsetting enablecfoutputonly="false" />