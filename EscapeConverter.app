// EscapeConverter
//
// This is a TagOS app which converts plaintext to escaped strings, 
// and back again.
//
// d.swartzendruber, c2014
// MIT License: http://opensource.org/licenses/MIT

<% markup shml %>

<fullview class="center">
    isfirsttime:true,
    
    StringParse:function(toplaintext){
        // fetch user text from textarera
        var areatext = self.$named('convertarea').val();

        // strided lists:
        //    first pair matches regex for unformatted chars to escaped text. 
        //    second pair matches regex for escaped chars to printable chars.
        var encodeFromArray = new Array(/\\/g,/'/g,/"/g,/\r\n/g,/[\r\n]/g,/\t/g,new RegExp('/','g'));
        var encodeToArray = new Array('\\\\','\\\'','\\\"','\\n','\\n','\\t','\\\/');         
        var decodeFromArray = new Array(/\\\\/g,/\\'/g,/\\\"/g,/\\n/g, /\\t/g,new RegExp('\\\\/','g'));
        var decodeToArray = new Array("\\","'",'"','\n','\t','\/');    
        // in writing these I discovered two rules:
        //
        // 1) The regex to find the raw version of a character will almost always be the escaped version for a string literal.
        //
        // 2) You cannot find a single forward slash using any form of a 
        // literal RegExp.  You must call its constructor for that one. 
        
        // loop through user text and replace using a pair of strided lists (selected by 'toplaintext')
        if(areatext !== ""){
            for( var x = 0; x {- encodeFromArray.length; x++ ) {
                areatext = areatext.replace( toplaintext ? decodeFromArray[x] : encodeFromArray[x] , toplaintext ?  decodeToArray[x] : encodeToArray[x] );
            }
        }
        
        // deal with outside quotes
        areatext = toplaintext ? areatext.replace(/^["']/m,"").replace(/["']$/m,"") : "\'"+areatext+"\'" ;
        self.$named('convertarea').val(areatext); 
        self.isfirsttime = false;
    },
    
    // lets us clear the textarea automatically, AND when the user chooses 
    clearAreaForFirstTime:function(clearanyway){
        if(self.isfirsttime || clearanyway){
            self.$named('convertarea').val("");
            self.isfirsttime = false;
        }
    }
    
    // Three buttons for text processing behavior:
    <div class="width100" name="buttoncontainer">
        <input type="button" class="button width33 rightpadded"
            onclick="self.root.StringParse()"
            value="Text to String">
        <input type="button" class="button width33 rightpadded"
            onclick="self.root.clearAreaForFirstTime(true)"
            value="Clear">        
        <input type="button" class="button width33 leftpadded"
            onclick="self.root.StringParse(true)"
            value="String to Text">
    
    // Textareas cannot become nametags because thier content is ALWAYS parsed as XML.  No tag-incode support
    // To fix this we wrap the textarea in a view and create hitches to affect its dimentions.
    <view class="rel" width="%%{self.parent.width}" height="%%{self.parent.height;;value-self.offsetTop-6}">
        onHeight:"%%{self.height;;self.$child('convertarea').height(value)}",
        onWidth:"%%{self.width;;self.$child('convertarea').width(value-6)}",
        
        // We need to populate the textarea on __ready__ using jQuery because it's the only way to get nametag to respect line breaks or carriage returns in a textarea
        __ready__:function(){
            self.$child('convertarea').val("    Occasionally you need to convert a block of unformatted text to a Javascript string so you can assign it to a variable.\r\r    This widget lets you do that, or reverse the process and convert an escaped Javascript string into normal text.\r\r    Paste your text to convert here.  Then click a button above."); 
        }
        
        <textarea class="width100 left clickable"
                  name="convertarea"
                  __click__="self.root.clearAreaForFirstTime()">