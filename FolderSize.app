// FolderSize
//
// This is a TagOS app which walks your top-level TrustFS directories 
// and tells you how much space each occupies in Kilobytes
//
// d.swartzendruber, c2014
// MIT License: http://opensource.org/licenses/MIT

<% markup shml %>

<fullview>
    <view class="width100 center bold margined">
        <div>
            How much space does each directory use?
        
    <view class="scrollable width100">
        list: function(){
            var top_folders = fat.folderrefs([]); // an empty array refers to the fs root '/'
            
            var sizes = []; // the list we will return to the list behavior.  it will be filled with objects: one per top-level dir 
            
            for(var i = 0; i != top_folders.length ; i++ ){
                
                sizes.push({ // add an object to the 'sizes' list
                    name: top_folders[i].__name__ ,
                    size: (function(){
                            var tally = 0;
                            
                            fat.walk(top_folders[i], function(ref){//recursively step through the folder in question.
                                
                                if(ref.__key__) // If a fat node has the '__key__' attribute it is a file.
                                    tally = tally + ref.__length__  ; // get the file's length in ASCII characters and add to tally
                            });
                            return Math.round(tally*16/8/1000); //convert characters to KB
                        })() 
                });
            }
            
            return sizes;
        }
        
        <div class="bordered padded topspacer lightblue fgblue">
            <span class="bold">
                /[=name=] 
            uses &#8776;
            <span class="bold">
                [=size=] 
            KB. 