var express = require("express");
var app = express();
app.use(express.static("public"));
app.set("view engine","ejs");
app.set("views","./views");
app.use("/scripts",express.static(__dirname+"/node_modules/web3.js-browser/build/"))

var server = require("http").Server(app);
var io = require("socket.io")(server);
app.listen(process.env.PORT || 3000);

var bodyParer = require("body-parser");
app.use(bodyParer.urlencoded({extended:false}));


const mongoose = require('mongoose');
mongoose.connect('...',function(err){ // link mongodb
    if(err){
        console.log("mogo connected error!"+err);
    }
    else{
        console.log("ket noi thanh cong!");
    }
});

require("./controllers/game")(app);
