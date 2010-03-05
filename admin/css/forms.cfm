<!--- allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="yes" />

	<!--- set content type of cfm to css to enable output to be parsed as css by all browsers --->
	<cfcontent type="text/css; charset=UTF-8">

	<!--- include layout css --->
	<cfinclude template="forms/layout.cfm"/>

	<!--- include webskin css --->
	<cfinclude template="forms/webskin.cfm"/>

	<!--- include formatting css --->
	<cfinclude template="forms/formatting.cfm"/>

<!--- end allow output only from cfoutput tags --->
<cfsetting enablecfoutputonly="no" />

<!---		.formsection {			
			font-size: 100%;
			border-width: 0px;
			border-style: solid;
			border-color: #000;
			margin: 0px;
			padding:10px;
			/*background: #F4F4F4 url(/css/images/featurebox_bg.gif) bottom right no-repeat;*/
		}
		
		.fieldsection {
		}
		
		.formsection legend {
			font-size: 140%;
			padding: 0px 5px;
		}

		
		.fieldsectionbreak, .formsectionbreak {
			clear:left;
			line-height:0px;
		}
		
		.fieldsectionlabel {
		  display: block;
		  float: left;
		  width: 150px;
		  padding: 2px 5px;
		  margin: 0px 0px 5px 0px;
		  text-align: right;
		}
				
		.required .fieldsectionlabel {
			font-weight:bold;
		}
		
		.richtext .fieldsectionlabel {
			display: block;
			float: none;
			padding: 2px 5px;
			margin: 0px 0px 0px 0px;
		}
		
	
		
		.labelCheckbox, .labelRadio {
			display: block;
			float: none;
			width: auto;
			padding: 0px;
			text-align: left;
		}
				
		.labelinline {
			display: inline;
			width: auto;
			padding: 5px 10px 0px 0px;
			text-indent: 0px;
			margin: 0px 0px 0px 0px;
		}

		.fieldwrap {
			display: block;
			margin: 0px 0px 5px 165px;
			padding: 2px 5px;
		}	
		

		.array div.fieldwrap {
			display: block;
			margin: 0px 0px 5px 165px;
			padding: 2px 5px;

		}
		
		.helpsectionmargin .fieldwrap {
			margin-right:200px;
		}
		
		
		.fieldwrap .fieldwrap {
			display: block;
			float: none;
			margin: 0px 0px 5px 165px;
			padding: 2px 5px;
		}	
		
		.richtext .fieldwrap {
			display:block;
			float: none;
			margin-left:0px;
			padding: 0px 5px;
		}
		
		.fieldwrap fieldset {
			border-width: 1px;
			border-style: solid;
			border-color: #000;
			padding:10px;
			
		}			
		.fieldwrap fieldset legend {
			font-size: 120%;
		}	
		
		
		
		.helpsection {
			float: right;
			width: 160px;
			padding: 5px;
			border: 1px solid #000;
			background-color: #EBEBEB;
			color: #000;
			font-size: 90%;
		}	
		
		.helpsection h4 {
			font-size: 110%;
			margin:0px;
		}	
		
		.hint {
			display: block;
			padding: 1px 3px;
			font-size: 80%;		
		}		

		.submitsection {
			margin-top:10px;
			padding:10px;
			border-width: 1px;
			border-style: dashed;
			border-color: #000;
		}
		
		
td .fieldwrap, th .fieldwrap {
	margin-left:0px;
}	
		
.richtext label, .longchar label {
  float: none;
  display: block;
}
.full div.fieldwrap, .richtext div.fieldwrap, .longchar div.fieldwrap {
  margin: 0px; 

}


.richtext textarea, .longchar textarea {
	/*width:350px;*/
} --->