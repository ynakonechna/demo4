const mysql = require("mysql2");
const express = require("express");
const bodyParser = require("body-parser");
const hbs = require("hbs");
const expressHbs = require("express-handlebars");
const path = require('path')
const app = express();
const urlencodedParser = bodyParser.urlencoded({extended: false});

zagolovok=global.zagolovok
pool=global.pool

module.exports = function(app) {

    app.get("/visiting", function(req, res){
        if (req.session.username) {
            let current_date = new Date();
            let yesterday_day = new Date(); 

            current_date.setDate(current_date.getDate()); 
            yesterday_day.setDate(yesterday_day.getDate() - 1); 

            pool.query("SELECT \
                visiting.Id_visiting, \
                visiting.Id_student, \
                visiting.data_visitor, \
                DATE_FORMAT(visiting.time_e, '%d.%m.%Y') AS time_e, \
                visiting.exit_entrance, \
                students.pib \
                FROM \
                visiting \
                Left Join students ON visiting.Id_student = students.Id_student \
                WHERE \
                visiting.time_e >=  ? AND \
                visiting.time_e <= ? ORDER BY time_e DESC", [yesterday_day.toJSON(), current_date.toJSON()], function(err, data) {
                if (err) return console.log(err);

                res.render("visiting.hbs", {
                    zagolovok: zagolovok,
                    visiting: data,
                    data_pochatku: current_date,
                    data_zakinchennya: yesterday_day
                });
            })
        } else {
            res.redirect("/");
        }
    });
    app.post("/visiting/data", urlencodedParser, function(req, res){
        if (req.session.username) {
            let data_pochatku = req.body.data_pochatku;
            let data_zakinchennya = req.body.data_zakinchennya;
    
            pool.query("SELECT \
                visiting.Id_visiting, \
                visiting.Id_student, \
                visiting.data_visitor, \
                DATE_FORMAT(visiting.time_e, '%d.%m.%Y') AS time_e, \
                visiting.exit_entrance, \
                students.pib \
                FROM \
                visiting \
                Left Join students ON visiting.Id_student = students.Id_student \
                WHERE \
                visiting.time_e >=  ? AND \
                visiting.time_e <= ? ORDER BY time_e DESC", [data_pochatku, data_zakinchennya], function(err, data) {
                if (err) return console.log(err);
    
                res.render("visiting.hbs", {
                    zagolovok: zagolovok,
                    visiting: data,
                    data_pochatku: data_pochatku,
                    data_zakinchennya: data_zakinchennya
                });
            })
        } else {
            res.redirect("/");
        }
       
    });

    app.post("/visiting_d/:Id_visiting", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_visiting = req.params.Id_visiting;
    
            pool.query("DELETE FROM visiting WHERE Id_visiting=?", [Id_visiting], function(err, data){
                if(err) return console.log(err);
                res.redirect('/visiting');
        
            });
        } else {
            res.redirect("/visiting");
        }
    
    });

    app.post("/visiting_c", urlencodedParser, function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_student = req.body.Id_student;
            const data_visitor = req.body.data_visitor;
            const exit_entrance = req.body.exit_entrance;
            let current_date = new Date().toJSON();

            let bool_exit_entrance = false

            if (exit_entrance === "on") {
                bool_exit_entrance = true;
            }

            if (Id_student == "") {
                pool.query("INSERT INTO `visiting` (`data_visitor`, `time_e`, `exit_entrance`) VALUES (?,?,?)", [data_visitor, current_date, bool_exit_entrance],function(err, data){
                    if(err) return console.log(err);
                    res.redirect('/visiting');
                });

            } else {
                pool.query("INSERT INTO `visiting` (`Id_student`, `data_visitor`, `time_e`, `exit_entrance`)  VALUES (?,?,?,?)", [Id_student, data_visitor, current_date, bool_exit_entrance], function(err, data){
                    if(err) return console.log(err);
                    res.redirect('/visiting');
                });
            }
        } else {
            res.redirect("/visiting");
        }
            
    });

}