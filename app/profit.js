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
    let Id_student = ""
    app.get("/profit/:Id_student", function(req, res){
        if (req.session.username) {
            Id_student = req.params.Id_student;
            pool.query("SELECT \
            profit.Id_profit, \
            DATE_FORMAT(profit.date_profit, '%d.%m.%Y') AS date_profit, \
            profit.amount, \
            profit.type_profit, \
            students.Id_student \
            FROM \
            profit \
            Inner Join students ON students.Id_student = profit.Id_student WHERE students.Id_student = ?",  [Id_student], function(err, data) {
                    if (err) return console.log(err);
                    pool.query("SELECT pib FROM students WHERE Id_student = ?", [Id_student], function(err, data2) {
                        if(err) return console.log(err);
                
                
                        res.render("profit.hbs", {
                            profit: data,
                            zagolovok: zagolovok,
                            pib_s: data2[0].pib
                        });
                    });
                    
                })
        } else {
            res.redirect("/");
        }
        
    });

    app.get("/profit_c", function(req, res){
        if (req.session.username && global.prava=='admin') {
            pool.query("SELECT\n" +
                "students.Id_student,\n" +
                "students.pib\n"+
                "FROM\n" +
                "students WHERE Id_student = ?\n", [Id_student], function(err, data) {
                if(err) return console.log(err);
                res.render("profit_c.hbs", {
                    student: data[0],
                    zagolovok: zagolovok
                });
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

    app.post("/profit_c", urlencodedParser, function(req, res) {
        if (req.session.username && global.prava=='admin') {
            if(!req.body) return res.sendStatus(400);
            const Id_student = req.body.Id_student;
            const date_profit = req.body.date_profit;
            const amount = req.body.amount;
            const type_profit = req.body.type_profit;
            pool.query("INSERT INTO profit (Id_student, date_profit, amount, type_profit) VALUES (?,?,?,?)",
            [Id_student, date_profit, amount, type_profit], function(err, data) {
                if(err) return console.log(err);
                res.redirect(`/profit/${Id_student}`);
            });
        } else {
            res.redirect("/visiting");
        }
        
    });

    app.post("/profit_d/:Id_profit", function(req, res){
        if (req.session.username && global.prava=='admin') {
            const Id_profit = req.params.Id_profit;
    
            pool.query("DELETE FROM profit WHERE Id_profit=?", [Id_profit], function(err, data){
                if(err) return console.log(err);
                res.redirect(`/profit/${Id_student}`);
        
            });
        } else {
            res.redirect("/visiting");
        }
    
    });

}