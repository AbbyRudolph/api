<cfset today = #dayofweek(now())#>
<cfquery name="getday" datasource="#attributes.dsn#">
	SELECT number
    FROM days
    WHERE day = '#today#'
</cfquery>
<cfset realtoday = #today#>
<cfset today = #today#-1>
<cfset caltime = #DateAdd('h', -2, now())#>

    
    <cfquery name="get_meetings" datasource="#attributes.dsn#">
	SELECT
		groupname,
		meetingid,
		day,
		time1,
		groupdirections,
		groupnote1,
		open,
		updated,
		groupaddress,
		groupcity,
		groupzip,
		groupstate,
		longitude,
		latitude,
		people,
		attended,
		smoking,
		wheelchair,
		spanish,
		childcare,
		childfriend,
		topic
	FROM 
		allmeetlist
		
	<cfif isDefined('url.type')>
		<cfif url.type eq 'gay'>
			WHERE(people = 'lgbt')
				OR(attended='lgbt')
		<cfelseif url.type eq 'men'>
			WHERE(people = 'm')
				OR(attended='men')
		<cfelseif url.type eq 'yp'>
			WHERE(people = 'yp')
				OR(attended='young people')
		<cfelseif url.type eq 'women'>
			WHERE(people = 'w')
				OR(attended='women')
		<cfelseif url.type eq 'nam'>
			WHERE(people = 'nam')
				OR(attended='native american')
		<cfelseif url.type eq 'smoking'>
			WHERE (smoking = on)
		<cfelseif url.type eq 'wheelchair'>
			WHERE (wheelchair = on)
		<cfelseif url.type eq 'spanish'>
			WHERE (spanish = on)
		<cfelseif url.type eq 'child'>
			WHERE (childcare = on)
            	OR (childfriend = on)
		<cfelseif url.type eq 'open'>
			WHERE (open = 'open')
        <cfelseif url.type eq 'rightnow'>
			WHERE day = #realtoday#
    		  	AND time2 > #numberformat(timeformat(caltime, "HH:mm:ss.0"),0.0000000)#
        <cfelseif url.type eq 'morning'>
			WHERE time2 BETWEEN 0.2500000 AND 0.4999999
        <cfelseif url.type eq 'noon'>
			WHERE time2 = 0.5000000 AND 0.5416666
        <cfelseif url.type eq 'afternoon'>
			WHERE time2 BETWEEN 0.5416667 AND 0.7499999
        <cfelseif url.type eq 'evening'>
			WHERE time2 BETWEEN 0.7500000 AND 0.8749999
        <cfelseif url.type eq 'night'>
			WHERE time2 BETWEEN 0.8750000 AND 0.9999999
        <cfelseif url.type eq 'midnight'>
			WHERE time2 BETWEEN 0.0000000 AND 0.2499999
        <cfelseif url.type eq 'Sunday'>
			WHERE day = 1
        <cfelseif url.type eq 'Monday'>
			WHERE day = 2
        <cfelseif url.type eq 'Tuesday'>
			WHERE day = 3
        <cfelseif url.type eq 'Wednesday'>
			WHERE day = 4
        <cfelseif url.type eq 'Thursday'>
			WHERE day = 5
        <cfelseif url.type eq 'Friday'>
			WHERE day = 6
        <cfelseif url.type eq 'Saturday'>
			WHERE day = 7
		</cfif> 
	</cfif>
			
</cfquery>

<cfset meetings = [] />

<cfoutput query="get_meetings">
	<cfscript>
	types = [];
	if (open IS "open") {
		ArrayAppend(types, "O");
	} else if (open IS "closed") {
		ArrayAppend(types, "C");
	}
	if (people IS "lgbt" OR attended IS "lgbt") {
		ArrayAppend(types, "LGBTQ");
	} else if (people IS "yp" OR attended IS "young people") {
		ArrayAppend(types, "Y");
	} else if (people IS "w" OR attended IS "women") {
		ArrayAppend(types, "W");
	} else if (people IS "nam" OR attended IS "native american") {
		ArrayAppend(types, "N");
	}
	if (smoking IS 1) {
		ArrayAppend(types, "SM");
	}
	if (wheelchair IS 1) {
		ArrayAppend(types, "X");
	}
	if (spanish IS 1) {
		ArrayAppend(types, "S");
	}
	if (childcare IS 1) {
		ArrayAppend(types, "BA");
	}
	if (childfriend IS 1) {
		ArrayAppend(types, "CF");
	}
	if (topic IS "12") {
		ArrayAppend(types, "ST");
	} else if (topic IS "ASL") {
		ArrayAppend(types, "ASL");
	} else if (topic IS "B") {
		ArrayAppend(types, "BE");
	} else if (topic IS "BB") {
		ArrayAppend(types, "B");
	} else if (topic IS "BBS") {
		ArrayAppend(types, "B");
		ArrayAppend(types, "ST");
	} else if (topic IS "CL") {
		ArrayAppend(types, "CAN");
	} else if (topic IS "D") {
		ArrayAppend(types, "D");
	} else if (topic IS "GV") {
		ArrayAppend(types, "GR");
	} else if (topic IS "L") {
		ArrayAppend(types, "LIT");
	} else if (topic IS "Med") {
		ArrayAppend(types, "MED");
	} else if (topic IS "S") {
		ArrayAppend(types, "ST");
	} else if (topic IS "SPK") {
		ArrayAppend(types, "SP");
	} else if (topic IS "ST") {
		ArrayAppend(types, "ST");
		ArrayAppend(types, "TR");
	} else if (topic IS "T") {
		ArrayAppend(types, "D");
	} else if (topic IS "TR") {
		ArrayAppend(types, "TR");
	}
	</cfscript>
	<cfset meeting = {
		"name"="#groupname#", 
		"slug"="#meetingid#",
		"day"="#INT(NUMBERFORMAT(day)-1)#",
		"time"="#TimeFormat(time1,"HH:mm")#",
		"location"="#groupdirections#",
		"notes"="#groupnote1#",
		"types"=#types#,
		"updated"="#DateTimeFormat(updated, "yyyy-mm-dd HH:nn:ss")#",
		"address"="#groupaddress#",
		"city"="#groupcity#",
		"postal_code"="#groupzip#",
		"state"="#groupstate#",
		"country"="USA",
		"longitude"="#longitude#",
		"latitude"="#latitude#",
		"topic"="#topic#"
	} />
	<cfset arrayAppend(meetings, meeting) />
</cfoutput>


<cfprocessingdirective suppresswhitespace="Yes">
	<cfheader name="Content-Type" value="application/json">
	<cfoutput>#serializeJSON(meetings)#</cfoutput>
</cfprocessingdirective>