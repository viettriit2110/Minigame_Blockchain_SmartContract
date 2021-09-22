var Hocvien = require("../models/Hocvien")

module.exports = function(app){
    app.get("/",function(req,res){
        // var Teo = new Hocvien({
        //     Email:"a",
        //     HoTen:"b",
        //     SoDT:"a",
        //     ThanhToan:false,
        //     Vi:"c",
        //     Ngay:Date.now()
        // });
        // res.json(Teo);
        res.render("layout");
    });

    app.post("/dangky",function(req,res){
        if(!req.body.Email || !req.body.HoTen || !req.body.SoDT){
            res.json({ketqua:0, maloi:"thieu tham so truyen len"});
        }else{
            var hocvienMoi = new Hocvien({
                Email:req.body.Email,
                HoTen:req.body.HoTen,
                SoDt:req.body.SoDT,
                ThanhToan:false,
                Vi:"",
                Ngay:Date.now()
            });
            hocvienMoi.save(function(err){
                if(err){
                    console.log(err);
                    res.json({ketqua:0, maloi:"loi"});
                }else{
                    res.json({ketqua:1, maloi:hocvienMoi});
                }

            });
        }
    })
}