// PasswordSafe
//
// This is a TagOS app which manages sensitive account
// information and stores it with dual AES encrypton:
// once using implicit TrustFS encryption, and a 
// second time using AES and a custom password.
//
// You may export data in plaintext, via copy-paste,
// but this app will never write plaintext to media.
//
// The advantage of this over -all other- password
// managers is the combination of these features:
//
// 1) Data held in escrow cannot be read
// 2) Data held in escrow cannot be identified
// 3) Data held in escrow can be redundantly distributed
// 4) Platform agnostic
// 5) No special client software or browser plugins
//
// d.swartzendruber, c2014
// All rights reserved, but will probably be GPL eventually


// Write test passwd file
// fat.write("/Prog/Passwords/"+TrustOS.uuid(7)+".password",TrustOS.encryptAES(Base64.encode(JSON.stringify({title:TrustOS.uuid(10),url:"http:\/\/foo.bar",password:"foo",username:"my name",email:"foo@bar.baz"})),"asdf"));
//
// Read 1st test passwd file
// JSON.parse(Base64.decode(TrustOS.decryptAES(fat.read("/Prog/Passwords/"+fat.listfiles("/Prog/Passwords/")[0]),"asdf")));  
//
// Proof of round trip crypt
//var password = "asdf"; Base64.decode(TrustOS.decryptAES(    TrustOS.encryptAES(Base64.encode(JSON.stringify({})),password)  ,password)));

<% markup shml %>

<script id="newuser" type="text/nametag">
    
    // When the user clicks the [Set Password] button
    setNewPassword:function(){
        
        // get the values from the two password fields
        var masterpassword = self.$named("masterpassword").val();
        var confirmpassword = self.$named("confirmpassword").val();
        
        // if the passwords didn't match
        if(masterpassword !== confirmpassword) {
            //inform the user of thier mistake and prompt them to try again
            self.$named("passwordmessage").text("Your passwords do not match.  Please try again.").addClass("fgred");
        } 
        // if the passwords the user entered matched, set up thier instance
        else{
            //Tell the user thier passwords matched.  They should not see this message for very long, so it's one word
            self.$named("passwordmessage").html("").text("Success!").addClass("big fggreen");
            
            // Get a reference to the manager, which is the main interface for the program
            var manager = self.lookup("Application").api.named("manager");
            // Get a fatcd object of the password files directory
            var passwordscd = self.root.directory.cd("/Passwords");
            // Get a list of the password files in the directory ?? limit this to .password  files
            var passwordfilelist = passwordscd.files();
            // Set the master password on the manager.  this only exists in memory and is cleared when the applicaiton is closed.
            manager.masterpassword = masterpassword;
            
            // Example account data to write for the new user
            var example = {
                title:"Example Account",
                username:"yourloginname",
                password:"correct horse battery staple",
                url:"http:\/\/example.com",
                email:"you@example.com"
            };
            // Write an example password file encrypted with thier master password.
            // As long as there is at least one file in thier Passwords folder, the program regocnizes them as a returning user.
            var examplewrites = fat.write(
                passwordscd.path()+"/"+TrustOS.uuid(7)+".password",
                TrustOS.encryptAES(
                    Base64.encode(JSON.stringify(example)),
                    manager.masterpassword
                )
            );
            
            // If a verified file write occured
            if(examplewrites){
                    // Load the manager for the first time.
                    manager.reload();
                    //Close the setpassword pane
                    self.lookup('Application').set('pane',false);
            }
                // if thier TagOS instance isn't broken they should never see this.
            else{
                self.$named("passwordmessage").html("").text("I was unable to write to your filesystem. Something is seriously wrong. Try restarting your TagOS instance.").addClass("fgred");
            }
        }
    }

    
    
    <div class="center padded fgblue" name="passwordmessage">
        <div class="evenbigger">Welcome, new user!
        <div>Make up a new password.  
        <div class="smaller">This password will encrypt all your account info, so <a href="https:\/\/xkcd.com\/936" target="_blank">choose wisely</a>.
    <input type="password" name="masterpassword" class="width75">
    
    <div>Confirm password:
    <input type="password" name="confirmpassword" class="width75">
    
    <div>
    <input type="button" class="button" __click__="self.root.setNewPassword()" value="Set Password">


<script id="setpassword" type="text/nametag">

    // We use this function to test the first file in the Passwords folder.  
    // If it successfully decrypts we remove the pane and load the manager
    // If it fails we inform the user (s)he should try again.
    unlockPasswords:function(){
        
        // get the value from thepassword field
        var masterpassword = self.$named("masterpassword").val();        
        // if the field wasn't empty (ie. the user did enter a password)
        if(masterpassword){
            
            // Get a reference to the manager, which is the main interface for the program
            var manager = self.lookup("Application").api.named("manager");
            
            //console.log(manager);
            
            // Get a fatcd object of the password files directory
            var passwordscd = self.root.directory.cd("/Passwords");
            
            // Get a list of the password files in the directory ?? limit this to .password  files
            var passwordfilelist = passwordscd.files();
    
            // Get the path (string) of the Password files folder.
            var decryptsuccess = manager.decryptStringToObj(passwordscd.read(passwordfilelist[0]), masterpassword);
    
            if(decryptsuccess){
                // Set the master password on the manager.  this only exists in memory and is cleared when the applicaiton is closed.
                manager.masterpassword = masterpassword;
                
                //Tell the user thier passwords matched.  They should not see this message for very long, so it's one word
                self.$named("passwordmessage").html("").text("Success!").addClass("big fggreen");
                
                // Load the manager for the first time.
                manager.reload();
                //Close the setpassword pane
                self.lookup('Application').set('pane',false);
            }
            else{
                // Inform the user the password was wrong
                self.$named("passwordmessage").text("Your password seems wrong.  Please try again.").addClass("fgred");
            }
        }
    }
    
    <div class="center padded" name="passwordmessage">Welcome back! Please enter your master password.
    <input type="password" name="masterpassword" class="width75">

    <div>
    <input type="button" class="button" __click__="self.root.unlockPasswords()" value="Set Password">

    
<script id="manager" type="text/nametag">
    
    autoload:false,
    
    // Encrypts anything that can be passed to JSON.parse()
    encryptObjToString:function(obj, password){
        return TrustOS.encryptAES(
            Base64.encode(JSON.stringify(obj)),
            password
        );
    },

    //Takes a string from a fat file and password
    // returns an object if decryption succeeds
    // Returns false if decruyption fails, and logs error to console
    decryptStringToObj:function(string, password){
        try{
            return JSON.parse(
                Base64.decode(
                    TrustOS.decryptAES(
                        string, 
                        password
                    )
                )
            );
        }catch(err){
            var error = "There was an error decrypting/parsing your password entry. Error was: " + err;
            console.log(error);
            //Nametag.Debugger.error(error);
        }
        return false;
    }

    <view class="abs scrollable" name="listbuttons"
        width="%%{self.parent.width;;value*.33}"
        height="%%{self.parent.height}">
        
        saveEntry:function(filename, entry){
            entry = entry || {};
            filename = (filename || TrustOS.uuid(7) +".password");
            //console.log("saveEntry()",filename, entry);
            self.directory.cd("Passwords").write(filename, 
                self.lookup("Application").api.named("manager").encryptObjToString({
                    title:entry.title || "New Title " + self.named("passwordlist").items.length,
                    url:entry.url || "",
                    username:entry.username || "",
                    email:entry.email || "",
                    password:entry.password || "",
                    notes:entry.notes || ""
            }, self.lookup("Application").api.named("manager").masterpassword));
        },
        
        deleteEntry:function(filename){
            self.directory.remove("Passwords/"+filename);
        }
        
        <input type="button" class="button floatleft" value="Add" onclick="self.parent.saveEntry()">
        <input type="button" class="button floatright" value="Remove" __click__="self.parent.deleteEntry(self.lookup('Application').api.named('passwordlist').selection.data.item)">
        
        <view name="passwordlist" class="rel scrollable" 
              width="%%{self.parent.width}"
              height="%%{self.parent.height ;; value-self.offsetTop}">
        
            filelist:self.root.directory.cd('Passwords'),
            selectable:"lightblue, vertLightBlueGradient shadowed, fgblack bottombordered",
            keyselectable:true,
            selectfirst:true,
            multiselectable:false,
            selectnew:true,
            unselectable:true,

            
            __preloadingitem__:function(arg){
                //console.log("__preloadingitem__  ", arg );
                
            },

            __loadingitem__:function(data){
                var filedata = self.root.decryptStringToObj(
                    self.root.directory.read("Passwords/"+data.item), 
                    self.lookup("Application").api.named("manager").masterpassword
                );
                copy(filedata,data);
                
                //console.log("__loadingitem__",data);
                
                return data;
            },
            
            __loadeditem__:function(item){
                //console.log("__loadeditem__  ", item.data);  
            },
            
            __selection__:function(elem){
                self.root.named('passwordinspector').reload(elem.data);
                //console.log(elem.data);
            }
            

            
            <view class="padded">
                __reloading__:function(data){
                    //console.log("__reloading__", data);
                }
                <div>[=title=]
        
    <view name="passwordinspector" class="abs"
        left="%%{self.parent.width;;value*0.33}" 
        width="%%{self.parent.width;;value*0.66}"
        height="%%{self.parent.height}"
        onHeight="%%{self.width, self.height, self.__load__ ;; !self.isReset && self.updateInputSizes(self.width+3, self.height-6)}">
        
        updateInputSizes:function(width, height){
            var notes = self.$named('notes');
            $(self).find("input[type='field']").width(width);
            //console.log("HEIGHT= ", self.root);
            notes.width(width).height(height-notes[0].offsetTop);
        },
        
        autoload:false,
         
        updateEntry:function(){
            var data = {
                title: self.$named("title").val(), 
                username: self.$named("username").val(),
                password: self.$named("password").val(),
                url: self.$named("url").val(),
                email: self.$named("email").val(),
                notes: self.$named("notes").val()
            };
            var filename = self.lookup("Application").api.named("passwordlist").selection.data.item;
            //console.log("updateEntry()", data, filename);
            self.lookup("Application").api.named("listbuttons").saveEntry(filename, data);
        },       
        

        __loaded__:function(){
            self.$named('notes').val(self.data.notes);
        }
        
        <div class="right width100">
            <input type="button" 
                   class="button"
                   value="Update Entry" 
                   __click__="self.parent.updateEntry()">
                <div class="right width100">
                

              
        <div>
            <div class="fgblue">Title
            <input type="field" name="title" value="[=title=]">
            
            <div class="fgblue">URL
            <input type="field" name="url" value="[=url=]">
            
            <div class="fgblue">Username
            <input type="field" name="username" value="[=username=]">            
            
            <div class="fgblue">Email
            <input type="field" name="email" value="[=email=]">
            
            <div class="fgblue">Password
            <input type="field" name="password" value="[=password=]">
            
            <div class="fgblue">Notes
            <textarea name="notes">
            
            
<fullview class="scrollable">

    __ultimately__:function(){
        var nofiles = self.directory.cd("Passwords").hasFiles();
        self.lookup("Application").set("pane", nofiles ? "@@setpassword" : "@@newuser");
    }
    
    <manager autoload="%{false}" name="manager" width="%%{self.parent.width}" height="%%{self.parent.height}">  
