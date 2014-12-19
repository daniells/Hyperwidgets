/*  
 * PasswordSafe v1
 *
 * d.l.s. 2014.12.19
 */ 

<% markup shml %>

<fullview>
    /* The top-level wrapper for the Manager.
    */
    
    // When the main content container is loaded, create a menu item for Help/About
    __loaded__:function(){
        self.root.menudata = [
            {name:'Export', width:210, items:[    
                {label:'Export Plaintext', shift:true, shortcut:'a', action:function(app){
                    self.lookup('Application').set('pane','@@ExportPlaintext');
                }}]},
            {name:'Help', width:210, items:[    
                {label:'About', shift:true, shortcut:'a', action:function(app){
                    self.lookup('Application').set('pane','@@AboutPane');
                }}]}
        ]; 
    },
    
    // Decide which pane we're going to show the user, depending on whether there are files in the Passwords folder
    __ultimately__:function(){
    
        var nofiles = self.directory.cd("Passwords").hasFiles();
        self.lookup("Application").set("pane", nofiles ? "@@ReturningUserPane" : "@@NewUserPane");
    }
    
    <Manager name="Manager" 
             width="%%{self.parent.width}" 
             height="%%{self.parent.height}"
             autoload="%{false}">  


<script id="AboutPane" type="text/nametag">
    
    app:self.lookup('Application'),
    
    __ready__:function(){
        $(self).removeClass("scrollable");
    }
    
    <view class="abs class bordered rounded left scrollable margined"
        height="%%{self.parent.app.height ;; value*0.9 }"
        width="%%{self.parent.app.width ;; value*0.8 }"
        left="%%{self.parent.app.width;; value*0.1}"
        top="%%{self.parent.app.height;; value*0.025}">

        <div>
            PasswordSafe is a trustworthy tool for storing the private account info you use every day.
            
        <div>
            You won't find its full feature list in any other password Manager.
            
        <div>
            <ul>
                <li> Double AES encryption
                <li> Available anywhere you have a browser and the internet
                <li> Storage service cannot read password data
                <li> Storage service cannot know you are storing password data
                <li> Storage can be distributed
                <li> 100% verifiable source code
                <li> Open source GUI
                <li> Free
                
        <div>
            For more information and feature requests, email daniel@tagos.io

<script id="NewUserPane" type="text/nametag">

    /* This pane is what the user sees if there is no saved password data:
    *  i.e. they cleared thier list prior to closing, or they are a new user.
    */
    
    // When the user clicks the [Set Password] button
    setNewPassword:function(){
        
        var app = self.lookup("Application");
        
        // get the values from the two password fields
        var master_password = self.$named("master_password").val();
        var confirm_password = self.$named("confirm_password").val();
        
        // if the passwords didn't match
        if(master_password !== confirm_password) 
            //inform the user of their mistake and prompt them to try again
            self.$named("PasswordMessage").text("Your passwords do not match.  Please try again.").addClass("evenbigger fgred");
        
        // if the passwords the user entered matched, set up their instance
        else{
            //Tell the user their passwords matched.  They should not see this message for very long, so it's one word
            self.$named("PasswordMessage").html("").text("Success!").addClass("big fggreen");
            
            // Get a reference to the Manager, which is the main interface for the program
            var Manager = app.api.named("Manager");
            // Get a fatcd object of the password files directory
            var passwordscd = self.root.directory.cd("/Passwords");
            // Get a list of the password files in the directory ?? limit this to .password  files
            var password_file_list = passwordscd.files();
            // Set the master password on the Manager.  this only exists in memory and is cleared when the application is closed.
            Manager.master_password = master_password;
            
            // Example account data to write for the new user
            var example = {
                title:"Example Account",
                username:"YourLoginName",
                password:"correct horse battery staple",
                url:"http:\/\/example.com",
                email:"you@example.com"
            };
            // Write an example password file encrypted with their master password.
            // As long as there is at least one file in their Passwords folder, the program recognizes them as a returning user.
            var example_writes = fat.write(
                passwordscd.path()+"/"+TrustOS.uuid(7)+".password",
                TrustOS.encryptAES(
                    Base64.encode(JSON.stringify(example)),
                    Manager.master_password
                )
            );
            
            // If a verified file write occurred
            if(example_writes){
                    // Load the Manager for the first time.
                    Manager.reload();
                    //Close the ReturningUserPane
                    self.lookup('Application').set('pane',false);
            }
                // if their TagOS instance isn't broken they should never see this.  
                // TagOS journaling and LocalFAT caching ensure local writes always succeed.
                // ...but just in case...
            else{
                self.$named("PasswordMessage").html("").text("I was unable to write to your filesystem. Something is seriously wrong. Try restarting your TagOS instance.").addClass("fgred");
            }
        }
    }

    
    
    <div class="center padded fgblue" name="PasswordMessage">
        <div class="evenbigger">Welcome, new user!
        <div>Make up a new password.  
        <div class="smaller">
            This password will encrypt all your account info, so <a href="https:\/\/xkcd.com\/936" target="_blank">choose wisely</a>.
        
    <input type="password" name="master_password" class="width75">
    
    <div>Confirm password:
    <input type="password" name="confirm_password" class="width75">
    
    <div>
    <input type="button" class="button" __click__="self.root.setNewPassword()" value="Set Password">


<script id="ReturningUserPane" type="text/nametag">
    
    /* This pane is what the user sees if there is Data saved in thier password directory
    *  i.e. they are a returning user.
    */

    // We use this function to test the first file in the Passwords folder.  
    // If it successfully decrypts we remove the pane and load the Manager
    // If it fails we inform the user (s)he should try again.
    unlockPasswords:function(){
        
        var app = self.lookup("Application");
        
        // get the value from the password field
        var master_password = self.$named("master_password").val();        
        // if the field wasn't empty (ie. the user did enter a password)
        if(master_password){
            
            // Get a reference to the Manager, which is the main interface for the program
            var Manager = app.api.named("Manager");
            
            // Get a fatcd object of the password files directory
            var passwordscd = self.root.directory.cd("/Passwords");
            
            // Get a list of the password files in the directory ?? limit this to .password  files
            var password_file_list = passwordscd.files();
    
            // Get the path (a string) of the Password files folder.
            var decrypt_success = Manager.decryptStringToObj(passwordscd.read(password_file_list[0]), master_password);
    
            if(decrypt_success){
                // Set the master password on the Manager.  this only exists in memory and is cleared when the application is closed.
                Manager.master_password = master_password;
                
                //Tell the user their passwords matched.  They should not see this message for very long, if at all, so it's one word
                self.$named("PasswordMessage").html("").text("Success!").addClass("big fggreen");
                
                // Load the Manager for the first time.
                Manager.reload();
                //Close the ReturningUserPane
                self.lookup('Application').set('pane',false);
            }
            else{
                // Inform the user the password was wrong
                self.$named("PasswordMessage").text("Your password seems wrong.  Please try again.").addClass("fgred");
            }
        }
    }
    
    <div class="center padded" name="PasswordMessage">
        Welcome back! Please enter your master password.
    
    <input type="password" name="master_password" class="width75">

    <div>
        <input type="button" 
               class="button" 
               __click__="self.root.unlockPasswords()" 
               value="Unlock My Data">

    
<script id="Manager" type="text/nametag">
    
    /* The Manager contains the filelist and the inspector
    *  It is also the container of our methods for encryption and decryption
    */
    
    // The manager is not loaded until either the NewUserPane or the ReturningUserPane .reload()s it
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
    // Returns false if decryption fails, and logs error to console
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
            Nametag.Debugger.error(err);
        }
        return false;
    }

    <view name="ListButtons" class="abs" 
        width="%%{self.parent.width;;value*.33}"
        height="%%{self.parent.height}">
        
        /* This tag contains a couple buttons for manipulating list items.
        */
        
        // This is our main method for saving password file data.  If fields are empty it chooses defaults.
        saveEntry:function(filename, entry){
            
            var app = self.lookup("Application");
            entry = entry || {};
            filename = (filename || TrustOS.uuid(7) +".password");
            
            self.directory.cd("Passwords").write(filename, 
                app.api.named("Manager").encryptObjToString({
                    title:entry.title || "New Title " + self.named("PasswordList").items.length,
                    url:entry.url || "",
                    username:entry.username || "",
                    email:entry.email || "",
                    password:entry.password || "",
                    notes:entry.notes || ""
            }, app.api.named("Manager").master_password));
        },
        
        deleteEntry:function(filename){
            var filename = self.lookup('Application').api.named('PasswordList').selection.data.item;
            self.directory.remove("Passwords/"+filename);
        }
        
        <input type="button" 
               class="button floatleft" 
               value="Add" 
               __click__="self.parent.saveEntry()">
               
        <input type="button" 
               class="button floatright" 
               value="Remove" 
               __click__="self.parent.deleteEntry()">
        
        <view name="PasswordList" class="rel scrollable" 
              width="%%{self.parent.width}"
              height="%%{self.parent.height ;; value-self.offsetTop}">
        
            filelist:self.root.directory.cd('Passwords'),
            selectable:"lightblue, vertLightBlueGradient shadowed, fgblack bottombordered",
            keyselectable:true,
            selectfirst:true,
            multiselectable:false,
            selectnew:true,
            unselectable:true,

            // In __loadingtem__ we have an opportunity to modify the data used to make the element before it is made.
            // This is the natural place to operate on data via decryption
            __loadingitem__:function(data){
                var filedata = self.root.decryptStringToObj(
                    self.root.directory.read("Passwords/"+data.item), 
                    self.lookup("Application").api.named("Manager").master_password
                );
                
                copy(filedata,data); // copy(src, dest)
                return data;
            },
            
            // Reload the inspector with the new item data when a list item is selected: the archetypical inspector pattern
            __selection__:function(elem){
                self.root.named('PasswordInspector').reload(elem.data);
            }
            
            <view class="padded">
                <div> [=title=]
        
    <view name="PasswordInspector" class="abs"
        left="%%{self.parent.width;;value*0.33}" 
        width="%%{self.parent.width;;value*0.66}"
        height="%%{self.parent.height}"
        onHeight="%%{self.width, self.height, self.__load__ ;; !self.isReset && self.updateInputSizes(self.width+3, self.height-6)}">
        
        // Here we grab all the input fields and the textarea and perform our resize, which will be called in the hitch above
        updateInputSizes:function(width, height){
            var notes = self.$named('notes');
            $(self).find("input[type='field']").width(width);
            notes.width(width).height(height-notes[0].offsetTop);
        },
        
        autoload:false,
         
        updateEntry:function(){
        
            var app = self.lookup("Application");
            // marshal data from the inspector feilds
            var data = {
                title: self.$named("title").val(), 
                username: self.$named("username").val(),
                password: self.$named("password").val(),
                url: self.$named("url").val(),
                email: self.$named("email").val(),
                notes: self.$named("notes").val()
            };
            
            // Get the corresponding filename from the selected list item the inspector is displaying
            var filename = app.api.named("PasswordList").selection.data.item;
            
            // Save a file under the same name using the gathered data, 
            app.api.named("ListButtons").saveEntry(filename, data);
        },       
        
        __loaded__:function(){
            self.$named('notes').val(self.data.notes);
        }
        
        <div class="right width100">
            <input type="button" 
                   class="button"
                   value="Update Entry" 
                   __click__="self.parent.updateEntry()">

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
            
<script id="ExportPlaintext" type="text/nametag">

    __ready__:function(){
        self.$child('displayarea').text(
                "'"+FormatJSON(self.lookup('Application').api.named('PasswordList').dataFromItems())+"'"
            );
    }
    
    <textarea name="displayarea" class="width100 height100">
            
            