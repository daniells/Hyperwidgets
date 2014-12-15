// CharacterChart
//
// This is a TagOS app intended to print a chart of all
// possible ASCII chracters and thier numeric character
// code equivalents.
//
// This version reveals a bug in text processing: 
// text replacement occurs *after* XML has been 
// rendered. This was never a problem during Nametag 
// or TagOS development: this is a limit-pushing use
// case for Nametag.js
//
// James assures me this will be fixed in an update.
// We need bug tracking!
//
// d.swartzendruber, c2014
// MIT License: http://opensource.org/licenses/MIT

<% markup shml %>

<root class="scrollable">
    
    list:range(4)

    <div class="tablecell bordered padded">
        <span>
            &#[=i=];